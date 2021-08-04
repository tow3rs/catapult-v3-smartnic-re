----------------------------------------------------------------------------------------------------
-- (c)2007 Altera Corporation. All rights reserved.
--
-- Altera products are protected under numerous U.S. and foreign patents,
-- maskwork rights, copyrights and other intellectual property laws.
--
-- This reference design file, and your use thereof, is subject to and governed
-- by the terms and conditions of the applicable Altera Reference Design License
-- Agreement (either as signed by you or found at www.altera.com).  By using
-- this reference design file, you indicate your acceptance of such terms and
-- conditions between you and Altera Corporation.  In the event that you do not
-- agree with such terms and conditions, you may not use the reference design
-- file and please promptly destroy any copies you have made.
--
-- This reference design file is being provided on an "as-is" basis and as an
-- accommodation and therefore all warranties, representations or guarantees of
-- any kind (whether express, implied or statutory) including, without
-- limitation, warranties of merchantability, non-infringement, or fitness for
-- a particular purpose, are specifically disclaimed.  By making this reference
-- design file available, Altera expressly does not recommend, suggest or
-- require that this reference design file be used in combination with any
-- other product not provided by Altera.
----------------------------------------------------------------------------------------------------
-- File          : superliteii_txrx_module.vhd
-- Author		 : Peter Schepers
----------------------------------------------------------------------------------------------------
-- Contains :
-- superliteii_txrx_module V4 : 	
--										- Instantiates 64b66b encoder/decoder + scrambling
--										- Deskew the lanes using RX FIFO inside the transceiver
--										- Detects lane identifier (if LANE_IDENTIFIER is true), in case set to false : backwards compatible with V3 and before
--
--
-- Native PHY and reset controller. 
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.package_delaytype.all; -- package that define "Delay_Array" type
 
entity superliteii_txrx_module is
GENERIC
	(
		READ_LENGTH_SIM	: std_logic_vector(15 DOWNTO 0) := X"0100"; -- Every 256 clock cycles insert idle (this is the value used for simulation purposes).
		READ_LENGTH			: std_logic_vector(15 DOWNTO 0) := X"0400"; -- Every 1024 clock cycles insert idle (note this value can be increased to increase efficiency).
		IDLE_LENGTH			: std_logic_vector(3 DOWNTO 0)  := X"7";	  -- Lenght of idle + alignment characters inserted every READ_LENGTH period
		NUMBER_OF_LANES	: integer := 4;	  	-- NUMBER_OF_LANES
		LANEWIDTH			: integer := 64;		-- LANEWIDTH for transceiver
		LANE_IDENTITY		: boolean := true;	
		SIMPLEX				: boolean := false; 	-- When enabled, does not perform any handshaking with remote side.		
		SIMULATION			: boolean := false	
	);
PORT(
	Reset							: in std_logic;						-- Reset generated on MgmtClk domain
	
	RefClock						: in std_logic; 						-- RefClock Transceiver 
	MgmtClk						: in std_logic;						-- Required as reconfig clock and calibration clock
	
	-- Tx Path
	DataIn						: in std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
	DataIn_Valid				: in std_logic; 					-- Only write when DataIn_valid is high	
	XOFF							: in std_logic;		-- XOFF input to sent out XOFF to the remote device for the remote to stop sending traffic (100 Mhz Clock domain)
	DataClock					: in std_logic;			-- Must be a copy of the TxCoreClock
	DataIn_ready				: out std_logic;		-- Asserted when Tx module can accept new data
	
	Reset_Tx						: buffer std_logic; -- Reset Synchronized to TxCoreClock domain
	TxCoreClock					: buffer std_logic;	
	
	-- High speed serial data outputs	
	XCVR_TX					: out std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 	  	
	
	-- Status SIGNALs	
	tx_ready						: buffer std_logic;

   -- Rx Path	
	ForceAlign					: in std_logic;	-- Force the Rx_Path to re-align
	Reset_Rx						: buffer std_logic;
	
	-- High speed serial input data lanes
	XCVR_RX						: in std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 
   Serial_Loop					: in std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 
	
	-- Parallel Data Output (with Valid SIGNAL) and clock
	DataOut						: out std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
	DataOut_Valid				: out std_logic; 
	DataOut_Clock				: buffer std_logic;  -- Based on the recovered clock
			
	-- Transceiver reconfiguration interface	
	reconfig_reset          : in  std_logic; 
	reconfig_write          : in  std_logic; 
	reconfig_read           : in  std_logic; 
	reconfig_address        : in  std_logic_vector(15 DOWNTO 0)  := (others => '0'); 
	reconfig_writedata      : in  std_logic_vector(31 DOWNTO 0)  := (others => '0'); 
	reconfig_readdata       : out std_logic_vector(31 DOWNTO 0);   
	reconfig_waitrequest    : out  std_logic;
	
	-- Tx PLL reconfiguration interface	
	reconfig_pll_reset          : in  std_logic; 
	reconfig_pll_write          : in  std_logic; 
	reconfig_pll_read           : in  std_logic; 
	reconfig_pll_address        : in  std_logic_vector(15 DOWNTO 0)  := (others => '0'); 
	reconfig_pll_writedata      : in  std_logic_vector(31 DOWNTO 0)  := (others => '0'); 
	reconfig_pll_readdata       : out std_logic_vector(31 DOWNTO 0);   
	reconfig_pll_waitrequest    : out  std_logic;
  
	-- Status SIGNALs	
	rx_freqlocked				: buffer std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 	
   rx_ready						: buffer std_logic;	
	Reset_Rx_Path				: buffer std_logic;
	WordAligned					: buffer std_logic;
	LaneAligned					: buffer std_logic;	
	Linkup						: buffer std_logic;
	XOFF_Received				: buffer std_logic;	
	Rx_Error						: buffer std_logic;
	decoder_error				: out std_logic;	
	Error_Deskew				: out std_logic;
	Delay							: buffer Delay_Array;
	Lane_identifier			: buffer Bit8_ArrayType;
	Latency						: buffer std_logic_vector(7 DOWNTO 0)	
	);
END superliteii_txrx_module;


architecture rtl of superliteii_txrx_module is

component Synchro is
port
	(
	Clk			: in std_logic;
	data_in		: in std_logic;
	data_out		: out std_logic
	);
end component;


component Reset_Synchro
port
	(
	Clk			: in std_logic;
	Reset_in	: in std_logic;
	Reset_out	: out std_logic
	);
end component;

component Tx_Ratematcher_Control
GENERIC
	(
		READ_LENGTH_SIM	 	: std_logic_vector(15 DOWNTO 0) := X"0100"; -- Every 256 clock cycles insert idle (this is the value used for simulation purposes).
		READ_LENGTH			 	: std_logic_vector(15 DOWNTO 0) := X"0400"; -- Every 1024 clock cycles insert idle (note this value can be increased to increase efficiency).
		IDLE_LENGTH				: std_logic_vector(3 DOWNTO 0)  := X"7";		
		NUMBER_OF_LANES		: integer := 4;	  									-- Number of lanes
		LANEWIDTH				: integer := 64;		-- LANEWIDTH for transceiver
		LANE_IDENTITY			: boolean := true;	
		SIMULATION				: boolean := false
		
	);
PORT(
	data_in								: in std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
	data_in_valid						: in std_logic;				-- should be in sync with data_in_ready 		 
	data_in_ready						: out std_logic;			-- SIGNAL out going down once every READ_LENGTH cycles for IDLE_LENGTH period.
	clk									: in std_logic;													
	Reset									: in std_logic;			-- Synchronous Reset				
   LaneAligned							: in std_logic; 			-- LaneAligned status (clocked by DataOut_Clock)
   XOFF									: in std_logic; 			-- XOFF input to sent out XOFF to the remote device for the remote to stop sending traffic (100 Mhz Clock domain)	
	Stop_Traffic						: in std_logic;			-- Used to stop sending traffic locally (when XOFF is received from remote side) (clocked by Dataout_Clock)
	Tx_Data								: out std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
	Tx_Data_Valid						: out std_logic;			-- Always Enabled in this case (as it is /66)	
	Tx_Ctrlenable						: out std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) DOWNTO 0);
	full_Tx_Ratematcher				: out std_logic;
	empty_Tx_Ratematcher				: out std_logic;
	almost_empty_Tx_Ratematcher	: buffer std_logic;
	almost_full_Tx_Ratematcher		: out std_logic;
	usedw_Tx_Ratematcher				: out std_logic_vector(2 DOWNTO 0);
	Latency_Count_Tx					: in std_logic_vector(7 DOWNTO 0)  -- Used to measure latency (synchronous to clk)
	);
END component;	


component txrx_pcs_64b66b is
GENERIC
	(
		NUMBER_OF_LANES	: integer := 10;	  	-- NUMBER_OF_LANES
		LANEWIDTH			: integer := 64;		-- LANEWIDTH for transceiver			
		SIMULATION			: boolean := false
	);
PORT(
		Reset						: IN STD_LOGIC;
		
		Serial_Loop				: IN STD_LOGIC_VECTOR ((NUMBER_OF_LANES - 1) DOWNTO 0);
		reconfig_mgmt_clk		: in std_logic; 
		RefClock					: IN STD_LOGIC;
		tx_coreclk				: IN STD_LOGIC; -- divide by 66 clock (tonnect to tx_clkout externally)
		tx_ctrlenable			: IN STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) DOWNTO 0);
		tx_datain				: IN STD_LOGIC_VECTOR (((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
		tx_datain_valid		: IN STD_LOGIC;	
		pll_locked				: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		tx_clkout				: OUT STD_LOGIC; -- divide by 66 clock
		tx_dataout				: OUT STD_LOGIC_VECTOR ((NUMBER_OF_LANES - 1) DOWNTO 0);		
		rx_datain				: IN STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) DOWNTO 0); 
	   rx_fifo_rd_en			: in 	STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) DOWNTO 0); 
		rx_enh_fifo_pempty	: out STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) DOWNTO 0);				
		rx_clkout				: OUT STD_LOGIC; -- recovered clock
		rx_ctrldetect			: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) DOWNTO 0);
		rx_dataout				: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0); -- Synchronous with rx_clkout
		rx_disperr				: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) DOWNTO 0);
		rx_errdetect			: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) DOWNTO 0);
		rx_freqlocked			: OUT STD_LOGIC_VECTOR ((NUMBER_OF_LANES-1) DOWNTO 0);
		rx_valid					: OUT STD_LOGIC_VECTOR ((NUMBER_OF_LANES-1) DOWNTO 0);
		Aligned					: BUFFER STD_LOGIC_VECTOR ((NUMBER_OF_LANES-1) DOWNTO 0);
		encoder_error			: OUT STD_LOGIC_VECTOR ((NUMBER_OF_LANES-1) DOWNTO 0);
		decoder_error			: OUT STD_LOGIC_VECTOR ((NUMBER_OF_LANES-1) DOWNTO 0);	
		tx_ready					: BUFFER STD_LOGIC;
		rx_ready					: BUFFER STD_LOGIC;
		
		-- Transceiver reconfiguration interface	
		reconfig_reset          : in  std_logic; 
		reconfig_write          : in  std_logic; 
		reconfig_read           : in  std_logic; 
		reconfig_address        : in  std_logic_vector(15 DOWNTO 0)  := (others => '0'); 
		reconfig_writedata      : in  std_logic_vector(31 DOWNTO 0)  := (others => '0'); 
		reconfig_readdata       : out std_logic_vector(31 DOWNTO 0);   
		reconfig_waitrequest    : out  std_logic;
		
		-- transmit PLL reconfiguration interface	
		reconfig_pll_reset          : in  std_logic; 
		reconfig_pll_write          : in  std_logic; 
		reconfig_pll_read           : in  std_logic; 
		reconfig_pll_address        : in  std_logic_vector(15 DOWNTO 0)  := (others => '0'); 
		reconfig_pll_writedata      : in  std_logic_vector(31 DOWNTO 0)  := (others => '0'); 
		reconfig_pll_readdata       : out std_logic_vector(31 DOWNTO 0);   
		reconfig_pll_waitrequest    : out  std_logic		
	);
end component;


component Rx_Path_Deskew 
GENERIC
	(
		NUMBER_OF_LANES		: integer := 4;	  	-- NUMBER_OF_LANES
		LANE_IDENTITY			: boolean := true;				
		SIMPLEX					: boolean := false; 	-- When enabled, does not perform any handshaking with remote side.		
		LANEWIDTH				: integer := 64		-- LANEWIDTH for transceiver
	);
PORT(
	Clock						: in std_logic;							
	Reset						: in std_logic;
	Enable						: in std_logic;
	data_in						: in std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
	ctrl_in						: in std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0);  		
	data_out						: out std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
	rx_fifo_rd_en				: out STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) DOWNTO 0); 
	rx_enh_fifo_pempty		: in STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) DOWNTO 0);
	Valid_Data					: out std_logic;
	Error							: out std_logic;
	Force_Rx_Reset				: out std_logic;		-- This SIGNAL must be synchronized to the ClkMgmt domain externally and used to trigger the Reset of Receiver Reset Instance
	Lane_Aligned				: buffer std_logic;
	Linkup						: buffer std_logic;
	XOFF_Received				: buffer std_logic;	
	Rx_Error						: buffer std_logic;	
	Delay							: buffer Delay_Array;
	Lane_identifier			: buffer Bit8_ArrayType;
	Latency_Count_Rx			: buffer std_logic_vector(7 DOWNTO 0);
	Latency_Count_Rx_Valid	: buffer std_logic	
	);
END component;	


component hyper_pipe is
GENERIC
	(
	DWIDTH 	: integer := 1;
	NUM_PIPES : integer := 1
	);
port	
(
	clk				: in std_logic;
	din				: in std_logic_vector((DWIDTH-1) DOWNTO 0);
	dout				: out std_logic_vector((DWIDTH-1) DOWNTO 0)
);
end component;


type    Bit4_Type is array (0 to (NUMBER_OF_LANES - 1)) of std_logic_vector(3 DOWNTO 0);

SIGNAL tx_data 						: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
SIGNAL training_data					: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);

SIGNAL tx_ctrlenable					: std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) DOWNTO 0);
SIGNAL tx_ctrlenable_training		: std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) DOWNTO 0);

SIGNAL tx_coreclk						: std_logic;
SIGNAL tx_clkout						: std_logic;

SIGNAL pll_powerdown					: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL tx_cal_busy					: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL tx_ready_i						: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_ready_i						: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_cal_busy					: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);

SIGNAL Reset_in1						: std_logic;
SIGNAL Reset_in2						: std_logic;

SIGNAL count							: std_logic_vector(3 DOWNTO 0);

SIGNAL rx_cruclk						: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);

SIGNAL rx_errdetect					: std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) DOWNTO 0);
SIGNAL rx_ctrldetect 				: std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) DOWNTO 0);
SIGNAL rx_disperr						: std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) DOWNTO 0);

SIGNAL rx_out 							: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
SIGNAL rx_clkout						: std_logic;
SIGNAL rx_coreclk						: std_logic;


SIGNAL DataOut_Aligned 				: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
SIGNAL Ctrl_Aligned					: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL Word_Aligned					: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);
		
		
SIGNAL rx_freqlocked_Q				: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_freqlocked_Q1				: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_freqlocked_Q2				: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_freqlocked_Q3				: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL Freqlock_Achieved			: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_analogreset_i				: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_digitalreset_i			: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL tx_analogreset_i				: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL tx_digitalreset_i			: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL Reset_I							: std_logic;

SIGNAL Zeroes 							: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL Ones 							: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL Reset_Lanes					: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);

SIGNAL RxCoreClock					: std_logic;

SIGNAL ForceAlign_min2				: std_logic;
SIGNAL ForceAlign_min1				: std_logic;
SIGNAL ForceAlign_sync				: std_logic;

SIGNAL SecondAlignment_Found  	: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);

SIGNAL Reset_xcvr_rx				 	: std_logic;
SIGNAL Force_Rx_Reset			 	: std_logic;
SIGNAL force_xcvr_reset_rx		 	: std_logic;
SIGNAL reset_rx_count			 	: std_logic_vector(3 DOWNTO 0);	
SIGNAL rx_fifo_rd_en				 	: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_enh_fifo_pempty		 	: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);

SIGNAL rx_valid						: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL encoder_error					: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL decoder_error_i				: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);


SIGNAL DataOut_min1 					: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
SIGNAL DataOut_Valid_min1 			: std_logic; 
SIGNAL tx_data_valid					: std_logic;
SIGNAL pll_locked						: std_logic_vector(0 DOWNTO 0);


SIGNAL Latency_Count_Tx				: std_logic_vector(7 DOWNTO 0);
SIGNAL Latency_Count_Rx 			: std_logic_vector(7 DOWNTO 0);
SIGNAL Latency_Count_Tx_sync 		: std_logic_vector(7 DOWNTO 0);
SIGNAL Latency_Count_Rx_Valid		: std_logic;

begin

----------------------------------------------------------------------------------------
-- Generate Reset_Tx
----------------------------------------------------------------------------------------

Reset_in1 <= Reset OR not (tx_ready);		-- Both are generated on MgmtClk

Reset_Synchro_inst1 : Reset_Synchro
PORT MAP
	(
	Clk			=> DataClock,
	Reset_in		=> Reset_in1,
	Reset_out	=> Reset_Tx
	);

	
-----------------------------------------------------------------------------------------------------------
--	Generate Latency counter
-----------------------------------------------------------------------------------------------------------	

process(DataClock,Reset_Tx)
begin
	if Reset_Tx = '1' then
		Latency_Count_Tx	<= (OTHERS => '0');
	elsif rising_edge(DataClock) then
		Latency_Count_Tx <= Latency_Count_Tx + 1;
	end if;
end process;
	

----------------------------------------------------------------------------------------
-- Tx Ratematcher Control (Superlite II TX)
----------------------------------------------------------------------------------------

TxCoreClock <= tx_clkout;

Tx_Ratematcher_Control_inst: Tx_Ratematcher_Control 
	GENERIC MAP
	(
		READ_LENGTH_SIM			=> READ_LENGTH_SIM,
		READ_LENGTH				=> READ_LENGTH,
		IDLE_LENGTH				=> IDLE_LENGTH,		
		NUMBER_OF_LANES			=> NUMBER_OF_LANES,	  	-- NUMBER_OF_LANES
		LANEWIDTH				=> LANEWIDTH,		-- LANEWIDTH for transceiver
		LANE_IDENTITY			=> LANE_IDENTITY,
		SIMULATION				=> SIMULATION
		
	)
	PORT MAP( 
	data_in						=> DataIn, 
	data_in_valid				=> DataIn_valid,
	data_in_ready				=> DataIn_ready,	
	clk							=> TxCoreClock,			-- divide by 66 clock		
	Reset							=> Reset_Tx,
   LaneAligned					=> LaneAligned,
   XOFF							=> XOFF,
	Stop_Traffic				=> XOFF_Received,	
	Tx_Data						=> tx_data,
	Tx_Data_Valid				=> tx_data_valid,
	Tx_Ctrlenable				=> tx_ctrlenable,
	full_Tx_Ratematcher				=> open,
	empty_Tx_Ratematcher				=> open,
	almost_empty_Tx_Ratematcher	=> open,
	almost_full_Tx_Ratematcher		=> open,
	usedw_Tx_Ratematcher				=> open,
	Latency_Count_Tx			=> Latency_Count_Tx
	);

-----------------------------------------------------------------------------------------------------------
--	Generate Zeroes and Ones
-----------------------------------------------------------------------------------------------------------	
	
Generate_ZEROES_and_ONES:
FOR i IN 0 to NUMBER_OF_LANES-1 GENERATE
ONES(I) <= '1';
ZEROES(I) <= '0';
END GENERATE;
	
		
-----------------------------------------------------------------------------------------------------------
--	Instantiate TxRx PCS 64b66b
-----------------------------------------------------------------------------------------------------------	

tx_coreclk 		<= tx_clkout;  -- divide by 66 
DataOut_Clock 	<= rx_clkout;  -- Recovered clock


txrx_pcs_64b66b_inst : txrx_pcs_64b66b 
	GENERIC MAP
		(
		NUMBER_OF_LANES				=> NUMBER_OF_LANES,	  	-- NUMBER_OF_LANES
		LANEWIDTH						=> LANEWIDTH,		-- LANEWIDTH for transceiver
		SIMULATION						=> SIMULATION
		)		
	PORT MAP (		
		Reset								=> Reset,
				
		Serial_Loop						=> Serial_Loop,
		reconfig_mgmt_clk				=> MgmtClk,	
		RefClock		 					=> RefClock,
			
		tx_coreclk	 					=> tx_coreclk,
		tx_ctrlenable	 				=> tx_ctrlenable,
		tx_datain	 					=> tx_data,
		tx_datain_valid				=> tx_data_valid,
		pll_locked	 					=> pll_locked,
		tx_clkout	 					=> tx_clkout,
		tx_dataout	 					=> XCVR_TX,		
		rx_datain						=> XCVR_RX,
		rx_fifo_rd_en					=> rx_fifo_rd_en,
		rx_enh_fifo_pempty			=> rx_enh_fifo_pempty,	
		rx_clkout						=> rx_clkout,
		rx_ctrldetect					=> rx_ctrldetect,
		rx_dataout						=> rx_out,
		rx_disperr						=> rx_disperr,
		rx_errdetect					=> rx_errdetect,
		rx_freqlocked					=> rx_freqlocked,
		rx_valid							=> rx_valid,
		encoder_error					=> encoder_error,	
		decoder_error					=> decoder_error_i,	
		Aligned							=> Word_Aligned,
		tx_ready	 						=> tx_ready,
		rx_ready							=> rx_ready,
		reconfig_reset		     		=> reconfig_reset,
		reconfig_write          	=> reconfig_write,
		reconfig_read           	=> reconfig_read,
		reconfig_address        	=> reconfig_address,
		reconfig_writedata      	=> reconfig_writedata,
		reconfig_readdata       	=> reconfig_readdata,
		reconfig_waitrequest    	=> reconfig_waitrequest,
		reconfig_pll_reset       	=> reconfig_pll_reset,
		reconfig_pll_write       	=> reconfig_pll_write,
		reconfig_pll_read        	=> reconfig_pll_read,
		reconfig_pll_address       => reconfig_pll_address,
		reconfig_pll_writedata     => reconfig_pll_writedata,
		reconfig_pll_readdata      => reconfig_pll_readdata,
		reconfig_pll_waitrequest 	=> reconfig_pll_waitrequest		
	);

	
-----------------------------------------------------------------------------------------------------------
--	Generate Reset_I synchronously to DataOut_Clock
-----------------------------------------------------------------------------------------------------------	

Reset_in2 <= Reset or not (rx_ready); -- Both or generated on the clkmgmt clock domain.

Reset_Synchro_inst2 : Reset_Synchro
PORT MAP
	(
	Clk			=> DataOut_Clock,
	Reset_in		=> Reset_in2,
	Reset_out	=> Reset_I
	);

Reset_Rx <= Reset_I;	

-----------------------------------------------------------------------------------------------------------
--	Generate WordAligned and Reset_Rx_Path
-----------------------------------------------------------------------------------------------------------	


process(DataOut_Clock,Reset_Rx)
begin
	if Reset_Rx = '1' then
		WordAligned 	<= '0';
		Reset_Rx_Path 	<= '1';
		ForceAlign_min2  <= '0';
		ForceAlign_min1  <= '0';
		ForceAlign_sync	 <= '0';			
	elsif rising_edge(DataOut_Clock) then
	
		ForceAlign_min2 	<= ForceAlign;
		ForceAlign_min1	 	<= ForceAlign_min2;
		ForceAlign_sync		<= ForceAlign_min1;		-- Synchronize from Clk50 Mhz to rx_coreclk domain
		
		if Word_Aligned = Ones then
			WordAligned <= '1';
		else
			WordAligned <= '0';
		end if;
		if ((WordAligned = '1') and (ForceAlign_sync = '0')) then
			Reset_Rx_Path <= '0';
		else
			Reset_Rx_Path <= '1';
		end if;
	end if;
end process;



DataOut_Aligned <= rx_out;

Generate_Ctrl_Aligned:
FOR i IN 0 to NUMBER_OF_LANES-1 GENERATE
	Ctrl_Aligned(I) <= rx_ctrldetect(I*8);
END GENERATE;


----------------------------------------------------------------------------------------
-- Rx Path Control (Deskew Lanes)
----------------------------------------------------------------------------------------


Rx_Path_inst: Rx_Path_Deskew 
	GENERIC MAP
	(
		NUMBER_OF_LANES		=> NUMBER_OF_LANES,	  	-- NUMBER_OF_LANES
		LANE_IDENTITY			=> LANE_IDENTITY,		
		SIMPLEX					=> SIMPLEX,
		LANEWIDTH				=> LANEWIDTH		-- LANEWIDTH for transceiver
	)
	PORT MAP( 
	Clock							=> DataOut_Clock,										
	Reset							=> Reset_Rx_Path,	
	Enable						=> '1',	
	data_in						=> DataOut_Aligned, 
	ctrl_in						=> Ctrl_Aligned,						
	data_out						=> DataOut_min1,
	rx_fifo_rd_en				=> rx_fifo_rd_en,
	rx_enh_fifo_pempty		=> rx_enh_fifo_pempty,
	Valid_Data					=> DataOut_Valid_min1,
	Error							=> Error_Deskew,
	Force_Rx_Reset				=> Force_Rx_Reset,	
	Lane_Aligned				=> LaneAligned,
	Linkup						=> Linkup,
	XOFF_Received				=> XOFF_Received,
	Rx_Error						=> Rx_Error,	
	Delay							=> Delay,
	Lane_Identifier			=> Lane_Identifier,
	Latency_Count_Rx			=> Latency_Count_Rx,
	Latency_Count_Rx_Valid	=> Latency_Count_Rx_Valid	
	);

decoder_error <= '0' when (decoder_error_i = ZEROES) else '1';

----------------------------------------------------------------------------------------
-- Add additional register stage for hyperflex retiming
----------------------------------------------------------------------------------------


process(DataOut_Clock)
begin
 if rising_edge(DataOut_Clock) then
			DataOut 			<= DataOut_min1;
			DataOut_Valid 	<= DataOut_Valid_min1;
 end if;
end process;


-----------------------------------------------------------------------------------------------------------
--	Resynchronize Latency_Local_Count on DataClock to DataOut_Clock
-- Note that ideally this should be implemented with a phase comp (DC fifo) as a bus is being synchronized
-- Testing in hardware revealed however this never fails (even when doing 10K's of resets)
-- Max Delay constraint is added on the bus to make sure the delay differences between the bits are minimal.
-----------------------------------------------------------------------------------------------------------	

Latency_Local_Count_synchronize : hyper_pipe 
GENERIC MAP
	(
		DWIDTH	 =>	8,
		NUM_PIPES =>   3
	)
PORT MAP(
	clk			=> DataOut_Clock,
	din			=> Latency_Count_Tx,	
	dout			=> Latency_Count_Tx_sync
	);	

	
-----------------------------------------------------------------------------------------------------------
--	Calculate Latency (only valid when in serial loopback or external loopbacked to itself)
-----------------------------------------------------------------------------------------------------------	
	
process(DataOut_Clock)
begin				
	if rising_edge(DataOut_Clock) then
		if Reset_Rx_Path = '1' then
			Latency			 <= (OTHERS => '0');
		else

			if Latency_Count_Rx_Valid = '1' then
				Latency <=  (Latency_Count_Tx_sync - Latency_Count_Rx) + IDLE_LENGTH + 1 ; -- Based on actual simulated latency
			end if;
		end if;
	end if;
end process;

			
end;

