----------------------------------------------------------------------------------------------------
-- (c)2011 Altera Corporation. All rights reserved.
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
-- design file available, Altera expressly does not recommEND, suggest or
-- require that this reference design file be used in combination with any
-- other product not provided by Altera.

----------------------------------------------------------------------------------------------------
-- File          : SuperliteII_Demo.vhd (V3 version)
-- Author		 : Peter Schepers
----------------------------------------------------------------------------------------------------
--
-- SuperliteII_Demo : 		- See documentation for details
----------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.package_delaytype.all; -- package that define "Delay_Array" type
 
entity SuperliteII_Demo is
GENERIC
	(
		NUMBER_OF_LANES				: integer := 4;	
		LANE_IDENTITY					: boolean := true;	
		SIMPLEX							: boolean := false; 	-- When enabled, does not perform any handshaking with remote side.			
		SIMULATION						: boolean := false	
	);
PORT(
	RefClock								: in std_logic;	
	MgmtClk								: in std_logic;
	Enable_Core							: in std_logic;
	XCVR_TX								: OUT STD_LOGIC_VECTOR ((NUMBER_OF_LANES - 1) DOWNTO 0);
	XCVR_RX								: IN STD_LOGIC_VECTOR ((NUMBER_OF_LANES - 1) DOWNTO 0);      
	Control_Reg							: in std_logic_vector(15 DOWNTO 0);
	Control2_Reg						: in std_logic_vector(15 DOWNTO 0);
	reconfig_reset          		: in  std_logic; 
	reconfig_write          		: in  std_logic; 
	reconfig_read           		: in  std_logic; 
	reconfig_address        		: in  std_logic_vector(15 DOWNTO 0)  := (others => '0'); 
	reconfig_writedata      		: in  std_logic_vector(31 DOWNTO 0)  := (others => '0'); 
	reconfig_readdata       		: out std_logic_vector(31 DOWNTO 0);   
	reconfig_waitrequest    		: out  std_logic;
	reconfig_pll_reset          	: in  std_logic; 
	reconfig_pll_write          	: in  std_logic; 
	reconfig_pll_read           	: in  std_logic; 
	reconfig_pll_address        	: in  std_logic_vector(15 DOWNTO 0)  := (others => '0'); 
	reconfig_pll_writedata      	: in  std_logic_vector(31 DOWNTO 0)  := (others => '0'); 
	reconfig_pll_readdata       	: out std_logic_vector(31 DOWNTO 0);   
	reconfig_pll_waitrequest    	: out  std_logic;
	Channel_Reg							: out std_logic_vector(17 DOWNTO 0);
	Counter_1ms_Reg					: out std_logic_vector(31 DOWNTO 0);
	ErrorCount_Reg						: out std_logic_vector(15 DOWNTO 0);
	Bitrate_Reg							: out std_logic_vector(31 DOWNTO 0);
	DataClock_Reg						: out std_logic_vector(31 DOWNTO 0);
	DataOut_Clock_Reg					: out std_logic_vector(31 DOWNTO 0);
	Latency_Max_Reg					: out std_logic_vector(7 DOWNTO 0);
	Latency_Min_Reg					: out std_logic_vector(7 DOWNTO 0);
	Delay_Reg							: out std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
	Delay_Reg_2							: out std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
	Lane_identifier					: buffer Bit8_ArrayType
	);
END SuperliteII_Demo;	


architecture rtl of SuperliteII_Demo is

COMPONENT Reset_Synchro
port
	(
	Clk			: in std_logic;
	Reset_in		: in std_logic;
	Reset_out	: out std_logic
	);
END COMPONENT;

COMPONENT CountGenerate 
PORT(
	coreclk  	: in std_logic;
	Enable		: in std_logic;
	StartValue 	: in std_logic_vector(15 DOWNTO 0);	
	Reset	 		: in std_logic;
	Inserterror : in std_logic;
	Counterout 	: out std_logic_vector(15 DOWNTO 0);
	Valid			: out std_logic
	);
END COMPONENT;	

COMPONENT CountVerify
PORT(
	Clock  				: in std_logic;
	Reset	 				: in std_logic;
	ResetErrorCount 	: in std_logic;
	DataIn 				: in std_logic_vector(15 DOWNTO 0);
	Enable				: in std_logic;	
	CountLocked			: out std_logic;
	Errorcount_Q 		: out std_logic_vector(15 DOWNTO 0);
	Count_Pattern_Q	: out std_logic_vector(15 DOWNTO 0)
	);
END COMPONENT;		


COMPONENT PrbsGenerate_60bit 
PORT(
	coreclk  	: in std_logic;
	Enable		: in std_logic;
	StartValue	: in std_logic_vector(59 DOWNTO 0);
	Reset	 		: in std_logic;
	Inserterror : in std_logic;
	Prbsout 		: out std_logic_vector(59 DOWNTO 0);
	Valid			: out std_logic
	);
END COMPONENT;	
		

COMPONENT PrbsVerify_60bit 
PORT(
	RxClock  			: in std_logic;
	Enable				: in std_logic;
	Reset	 				: in std_logic;
	ResetErrorCount 	: in std_logic;
	DataIn 				: in std_logic_vector(59 DOWNTO 0);
	PrbsLocked			: out std_logic;
	Errorcount_Q 		: out std_logic_vector(15 DOWNTO 0);
	next_prbs_Q			: out std_logic_vector(59 DOWNTO 0)
	);
END COMPONENT;	


COMPONENT superliteii_txrx_module 
GENERIC
	(
		READ_LENGTH_SIM			: std_logic_vector(15 DOWNTO 0) := X"0100"; -- Every 256 clock cycles insert idle (this is the value used for simulation purposes).
		READ_LENGTH					: std_logic_vector(15 DOWNTO 0) := X"0400"; -- Every 1024 clock cycles insert idle (note this value can be increased to increase efficiency).
		IDLE_LENGTH					: std_logic_vector(3 DOWNTO 0)  := X"7";	  -- Lenght of idle + alignment characters inserted every READ_LENGTH period
		NUMBER_OF_LANES			: integer := 10;	  	-- NUMBER_OF_LANES
		LANEWIDTH					: integer := 64;		-- LANEWIDTH for transceiver
		LANE_IDENTITY				: boolean := true;
		SIMPLEX						: boolean := false; 	-- When enabled, does not perform any handshaking with remote side.			
		SIMULATION					: boolean := false	
	);		
PORT(		
	Reset								: in std_logic;						-- Reset generated on MgmtClk domain
	RefClock							: in std_logic; 						-- RefClock Transceiver 
	MgmtClk							: in std_logic;						-- Required as reconfig clock and calibration clock
			
	-- Tx Path		
	DataIn							: in std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
	DataIn_Valid					: in std_logic; 					-- Only write WHEN DataIn_valid is high	
	XOFF								: in std_logic;		-- XOFF input to sent out XOFF to the remote device for the remote to stop sENDing traffic (100 Mhz Clock domain)
	DataClock						: in std_logic;		-- Must be a copy of the TxCoreClock
	DataIn_ready					: out std_logic;		-- Asserted WHEN Tx module can accept new data
			
	Reset_Tx							: buffer std_logic; -- Reset Synchronized to TxCoreClock domain
	TxCoreClock						: buffer std_logic;
	
	
	-- High speed serial data outputs	
	XCVR_TX							: out std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 	  	
	
	-- Status SIGNALs	
	tx_ready							: buffer std_logic;

   -- Rx Path	
	ForceAlign						: in std_logic;	-- Force the Rx_Path to re-align
	Reset_Rx							: buffer std_logic;
	
	-- High speed serial input data lanes
	XCVR_RX							: in std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 
   Serial_Loop						: in std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0);
	
	-- Parallel Data Output (with Valid SIGNAL) and clock
	DataOut							: out std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
	DataOut_Valid					: out std_logic; 
	DataOut_Clock					: buffer std_logic;  -- Based on the recovered clock
			
	-- Transceiver reconfiguration interface	
	reconfig_reset          	: in  std_logic; 
	reconfig_write          	: in  std_logic; 
	reconfig_read           	: in  std_logic; 
	reconfig_address        	: in  std_logic_vector(15 DOWNTO 0)  := (others => '0'); 
	reconfig_writedata      	: in  std_logic_vector(31 DOWNTO 0)  := (others => '0'); 
	reconfig_readdata       	: out std_logic_vector(31 DOWNTO 0);   
	reconfig_waitrequest    	: out  std_logic;
	
	-- Tx PLL reconfiguration interface	
	reconfig_pll_reset       	: in  std_logic; 
	reconfig_pll_write       	: in  std_logic; 
	reconfig_pll_read        	: in  std_logic; 
	reconfig_pll_address     	: in  std_logic_vector(15 DOWNTO 0)  := (others => '0'); 
	reconfig_pll_writedata   	: in  std_logic_vector(31 DOWNTO 0)  := (others => '0'); 
	reconfig_pll_readdata    	: out std_logic_vector(31 DOWNTO 0);   
	reconfig_pll_waitrequest 	: out  std_logic;
  
	-- Status SIGNALs	
	rx_freqlocked					: buffer std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 	
   rx_ready							: buffer std_logic;	
	Reset_Rx_Path					: buffer std_logic;
	WordAligned						: buffer std_logic;
	LaneAligned						: buffer std_logic;
	Linkup							: buffer std_logic;
	XOFF_Received					: buffer std_logic;	
	Rx_Error							: buffer std_logic;	
	decoder_error					: out std_logic;	
	Error_Deskew					: out std_logic;
	Delay								: buffer Delay_Array;
	Lane_identifier				: buffer Bit8_ArrayType;
	Latency							: buffer std_logic_vector(7 DOWNTO 0)
	
	);
END COMPONENT;

COMPONENT alt_a10_temp_sense 
port
(
	clk 			: in std_logic;
	degrees_c 	: out std_logic_vector(7 DOWNTO 0);
	degrees_f 	: out std_logic_vector(7 DOWNTO 0)
);
END COMPONENT;

COMPONENT Synchro 
port
	(
	Clk			: in std_logic;
	data_in		: in std_logic;
	data_out		: out std_logic
	);
END COMPONENT;

COMPONENT hyper_pipe is
GENERIC
	(
	DWIDTH 		: integer := 1;
	NUM_PIPES 	: integer := 1
	);
port	
(
	clk									: in std_logic;
	din									: in std_logic_vector((DWIDTH-1) DOWNTO 0);
	dout									: out std_logic_vector((DWIDTH-1) DOWNTO 0)
);
END COMPONENT;


CONSTANT CLK50M						: std_logic_vector(19 DOWNTO 0) := X"0C350" ; 
CONSTANT CLK100M						: std_logic_vector(19 DOWNTO 0) := X"186A0" ;

CONSTANT SAMPLES_50MHZ				: std_logic_vector(31 DOWNTO 0) :=	X"02FAF080"; -- (50 Mhz clock is 50E6 samples in one second)
CONSTANT SAMPLES_50MHZ_TIMES_5	: std_logic_vector(31 DOWNTO 0) :=	X"0EE6B280"; 
CONSTANT SAMPLES_100MHZ				: std_logic_vector(31 DOWNTO 0) :=	X"05F5E100"; -- (50 Mhz clock is 50E6 samples in one second)
CONSTANT SAMPLES_100MHZ_TIMES_5	: std_logic_vector(31 DOWNTO 0) :=	X"1DCD6500"; 


COMPONENT measure_refclk 
GENERIC
	(
		CYC_MEASURE_CLK_IN_1_SEC	:  std_logic_vector(31 DOWNTO 0) := SAMPLES_50MHZ 
	);
port
	(
	RefClock								: in	std_logic;
	Enable								: in std_logic;
	Measure_Clk							: in 	std_logic;
	reset									: in	std_logic;
	RefClock_Measure					: out  std_logic_vector(31 DOWNTO 0) -- Synchronized to Measure_Clk
	);
END COMPONENT;

COMPONENT counter_1ms 
GENERIC
	(
		BITRATE		: std_logic_vector(19 DOWNTO 0) :=	CLK50M
	);
port
	(
	RefClock			: in	std_logic;
	reset				: in	std_logic;
	count_1ms		: buffer std_logic_vector(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT fpll is
	port (
		hssi_pll_cascade_clk 			: out std_logic;         
		pll_cal_busy         			: out std_logic;         
		pll_locked           			: out std_logic;         
		pll_powerdown        			: in  std_logic := 'X'; 
		pll_refclk0          			: in  std_logic := 'X'   
	);			
END COMPONENT fpll;				
			
CONSTANT NUMBER_OF_QUADS				: integer := 1; 										  --Number of Quads
CONSTANT LANEWIDTH 						: integer := 64;
CONSTANT REFCLOCKMULTIPLIER 			: std_logic_vector(7 DOWNTO 0) := "01000010"; -- Multiplier of the Reference clock to reach bitrate per lane (66)

type Bit60Type is array (0 to (NUMBER_OF_LANES-1)) of std_logic_vector(59 DOWNTO 0);
type Bit4Type is array  (0 to (NUMBER_OF_LANES-1)) of std_logic_vector(3 DOWNTO 0);
type Bit16Type is array (0 to (NUMBER_OF_LANES-1)) of std_logic_vector(15 DOWNTO 0);
type Bit32Type is array (0 to (NUMBER_OF_LANES-1)) of std_logic_vector(31 DOWNTO 0);

SIGNAL TxData 								: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
			
SIGNAL Reset 								: std_logic;
SIGNAL ResetErrorCount					: std_logic;
			
SIGNAL inserterror 						: std_logic;
SIGNAL CountLocked 						: std_logic;
SIGNAL PrbsLocked 						: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);
			
			
SIGNAL Locked 								: std_logic;
			
SIGNAL pll_locked 						: std_logic_vector(0 DOWNTO 0);
			
SIGNAL Data_Out_Rx						: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
			
SIGNAL DataOut_Aligned 					: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
SIGNAL Ctrl_Aligned						: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL Byte_Aligned						: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL Word_Aligned						: std_logic_vector((NUMBER_OF_LANES - 1) DOWNTO 0);

SIGNAL ErrorCount 						: std_logic_vector(15 DOWNTO 0);	
SIGNAL ErrorCount_part1 				: std_logic_vector(15 DOWNTO 0);	
SIGNAL ErrorCount_part2 				: std_logic_vector(15 DOWNTO 0);	
SIGNAL ErrorCount_part3 				: std_logic_vector(15 DOWNTO 0);
SIGNAL ErrorCount_CountPattern 		: std_logic_vector(15 DOWNTO 0);
SIGNAL Errorcount_PrbsPattern	 		: Bit16Type;

SIGNAL CounterOut							: std_logic_vector(((NUMBER_OF_LANES * 4)-1) DOWNTO 0);
SIGNAL Prbsout								: Bit60Type;
SIGNAL DataIn_Tx							: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) DOWNTO 0);
SIGNAL ResetErrorCountChannel			: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL PowerOnReset 						: std_logic;
SIGNAL ResetCount							: std_logic_vector(5 DOWNTO 0) := (OTHERS => '0');
SIGNAL count_pattern_Q 					: std_logic_vector(15 DOWNTO 0);
SIGNAL next_prbs_Q						: std_logic_vector(31 DOWNTO 0);
SIGNAL ChannelOk							: std_logic;
SIGNAL rx_freqlocked						: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_freqlocked_Q					: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_freqlocked_Q1					: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_freqlocked_Q2					: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL rx_freqlocked_combined			: std_logic;
SIGNAL Reset_I								: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL Count								: std_logic;
SIGNAL Enable_Rx							: std_logic;
SIGNAL Aligned								: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
		
SIGNAL Reset_Counter_1ms				: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL Reset_CountGenerate				: std_logic_vector ((NUMBER_OF_LANES - 1) DOWNTO 0);
SIGNAL Reset_DataVerify					: std_logic;
		
SIGNAL DataClock							: STD_LOGIC;
SIGNAL DataOut_Clock						: std_logic;
SIGNAL data_valid							: STD_LOGIC ;
SIGNAL RefClock_Measure					: std_logic_vector(31 DOWNTO 0);
SIGNAL DataClock_Measure				: std_logic_vector(31 DOWNTO 0);
SIGNAL DataOut_Clock_Measure			: std_logic_vector(31 DOWNTO 0);
SIGNAL ResetCounter_1ms					: std_logic;
SIGNAL ClkData								: std_logic;
SIGNAL locked_pll							: std_logic;
SIGNAL Reset_Tx							: std_logic;
SIGNAL Reset_Rx							: std_logic;
SIGNAL TxCoreClock						: std_logic;
SIGNAL RxCoreClock						: std_logic;
SIGNAL wrfull_Tx_Ratematcher			: std_logic;
SIGNAL ResetErrorCount_I				: std_logic;
SIGNAL WordAligned						: std_logic;
SIGNAL LaneAligned						: std_logic;
SIGNAL Reset_Rx_Path						: std_logic;
SIGNAL Reset_DataGenerate				: std_logic;
SIGNAL Reset_TxRxModule					: std_logic;
SIGNAL LaneAlignment_Changed			: std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0);
SIGNAL LaneAlignment_Changed_All		: std_logic;

SIGNAL Force_Realign						: std_logic;

SIGNAL PrbsDataIn							: Bit60Type;
SIGNAL StartValue							: Bit60Type;
SIGNAL CountVerifyDataIn				: Bit4Type;
SIGNAL CountVerifyDataIn_combined 	: std_logic_vector(15 DOWNTO 0);
SIGNAL Serial_Loop						: std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0);
SIGNAL tx_clkout_ALTGX					: std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0);
SIGNAL locked_pll_Q						: std_logic;
SIGNAL locked_pll_Q1						: std_logic;
SIGNAL locked_pll_Q2						: std_logic;
SIGNAL locked_pll_R						: std_logic;
SIGNAL locked_pll_R1						: std_logic;
SIGNAL locked_pll_R2						: std_logic;
SIGNAL pll_locked_Q						: std_logic;
SIGNAL pll_locked_Q1						: std_logic;
SIGNAL pll_locked_Q2						: std_logic;
SIGNAL pll_locked_R						: std_logic;
SIGNAL pll_locked_R1						: std_logic;
SIGNAL pll_locked_R2						: std_logic;
SIGNAL decoder_error						: std_logic;
		
SIGNAL Debug_Measure						: std_logic_vector(31 DOWNTO 0);
		
SIGNAL ForceAlign							: std_logic;
SIGNAL RefClockdiv2						: std_logic;
SIGNAL Ones 								: std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 
SIGNAL busy									: std_logic;

		
SIGNAL reconfig_reset_poweron			: std_logic;	
SIGNAL reconfig_reset_i					: std_logic;
SIGNAL reconfig_pll_reset_i			: std_logic;
	
	
SIGNAL Error_Deskew 						: std_logic;
SIGNAL Delay								: Delay_Array;
SIGNAL Error_pcfifo						: std_logic;
SIGNAL Measure_diff 						: std_logic_vector(((NUMBER_OF_LANES * 4)-1) DOWNTO 0);
SIGNAL DataIn_Valid						: std_logic;
SIGNAL DataIn_Valid_min1				: std_logic;
SIGNAL Valid_Counter						: std_logic_vector(7 DOWNTO 0);
SIGNAL Reset_in1		 					: std_logic;
			
			
SIGNAL DataIn_ready						: std_logic;
			
SIGNAL Latency_Max						: std_logic_vector(((NUMBER_OF_LANES * 2)-1) DOWNTO 0);
SIGNAL Latency_Min						: std_logic_vector(((NUMBER_OF_LANES * 2)-1) DOWNTO 0);
SIGNAL Measure_diff_Q					: std_logic_vector(((NUMBER_OF_LANES * 2)-1) DOWNTO 0);
SIGNAL count_latency						: std_logic_vector(6 DOWNTO 0);
SIGNAL count_no_match					: std_logic_vector(6 DOWNTO 0);
SIGNAL no_match							: std_logic;
SIGNAL Reset_in3							: std_logic;
			
SIGNAL Linkup								: std_logic;
SIGNAL XOFF									: std_logic;
SIGNAL XOFF_Received						: std_logic;
SIGNAL Rx_Error							: std_logic;
SIGNAL CounterOut_min2					: std_logic_vector(((NUMBER_OF_LANES * 4)-1) DOWNTO 0);
SIGNAL CounterOut_min1					: std_logic_vector(((NUMBER_OF_LANES * 4)-1) DOWNTO 0);
SIGNAL CounterOut_Q						: std_logic_vector(((NUMBER_OF_LANES * 4)-1) DOWNTO 0);
SIGNAL data_gate							: std_logic;
SIGNAL data_gate_min1					: std_logic;
SIGNAL gate_counter						: std_logic_vector(7 DOWNTO 0);
SIGNAL DataIn_ready_final				: std_logic;	
SIGNAL throttle_data						: std_logic;
SIGNAL throttle_data_mgmt  			: std_logic;
SIGNAL Latency								: std_logic_vector(7 DOWNTO 0);
SIGNAL Channel_Reg_i						: std_logic_vector(17 DOWNTO 0);
SIGNAL Clk312Mhz  						: std_logic;

BEGIN

-- Reset : Control_Reg(15)
-- 1 : Reset
-- 0 : No Reset

-- InsertError : Control_Reg(14)
-- 1 : InsertError
-- 0 : NoError

-- ResetErrorCount : Control_Reg(13)
-- 1 : ResetErrorcount active
-- 0 : No Reset

-- Force_Realign : Control_Reg(12)
-- 1 : Force Realign
-- 0 : Nothing

-- XOFF : Control_Reg(11)
-- 1 : Sent out XOFF to the remote side to stop sENDing traffic
-- 0 : XON.

-- Throttle Data : Control_Reg(10)
-- 1 : Throttle Data (i.e. data valid only sent 50% of the time, this is to test the data_in_valid works properly)
-- 0 : no throttling of data, maximum throughput.

 
-- Serial Loop : Control2_Reg(3..0)
-- 1 : Serial Loopback enabled
-- 0 : No action


----------------------------------------------------------------------------------------
-- PowerOnReset
----------------------------------------------------------------------------------------


PROCESS(MgmtClk)
BEGIN
	IF MgmtClk'event and MgmtClk = '1' THEN
			IF ResetCount = "111111" THEN
				PowerOnReset <= '0';
			ELSE
				PowerOnReset <= '1';
			  	ResetCount <= ResetCount + 1;
			END if;
	END if;
END PROCESS;

----------------------------------------------------------------------------------------
-- Control bits
----------------------------------------------------------------------------------------

inserterror					<= Control_Reg(14);
ResetErrorCount 			<= Control_Reg(13);
Force_Realign				<= Control_Reg(12);
XOFF							<= Control_Reg(11);
throttle_data_mgmt		<= Control_Reg(10);
Serial_Loop					<= Control2_Reg((NUMBER_OF_LANES-1) DOWNTO 0); 


Synchro_inst : Synchro
port map
	(
	Clk			=> ClkData,
	data_in		=> throttle_data_mgmt,
	data_out		=> throttle_data
	);

----------------------------------------------------------------------------------------
-- Data Clock is the clock from the transceiver (Divide by 66)
----------------------------------------------------------------------------------------

ClkData 		<= TxCoreClock;

----------------------------------------------------------------------------------------
-- Create Reset
----------------------------------------------------------------------------------------

PROCESS(MgmtClk,PowerOnReset)
BEGIN
	IF PowerOnReset = '1' THEN
		Reset 				<= '1';
		reconfig_reset_poweron 	<= '1';			
	ELSIF MgmtClk'event and MgmtClk = '1' THEN

		IF (Enable_Core = '1') and (Control_Reg(15) = '0')	THEN	
			Reset	 			<= '0';
			reconfig_reset_poweron	<= '0';				
		ELSE
			Reset 			<= '1';
		END if;
	END if;
END PROCESS;

----------------------------------------------------------------------------------------
-- Create reconfig_reset such it is de-asserted at the same time as Reset (Which is used for the reset controller).
----------------------------------------------------------------------------------------

reconfig_reset_i 	<= reconfig_reset or reconfig_reset_poweron;
reconfig_pll_reset_i 	<= reconfig_pll_reset or reconfig_reset_poweron;


----------------------------------------------------------------------------------------
-- Create Reset_DataGenerate
----------------------------------------------------------------------------------------

PROCESS(ClkData,Reset)
BEGIN
	IF Reset = '1' THEN
		Reset_DataGenerate	 <= '1';
		pll_locked_R		 <= '0';
		pll_locked_R1		 <= '0';
		pll_locked_R2		 <= '0';		
	ELSIF rising_edge(ClkData) THEN
	
		pll_locked_R			<= pll_locked(0);
		pll_locked_R1			<= pll_locked_R;	
	   pll_locked_R2			<= pll_locked_R1;	
		IF (pll_locked_R2 = '1')  THEN
			Reset_DataGenerate	 		<= '0';
		ELSE
			Reset_DataGenerate 			<= '1';
		END if;
	END if;
END PROCESS;

----------------------------------------------------------------------------------------
-- For Test Purposes, create Additional data valid SIGNAL that goes down periodically
----------------------------------------------------------------------------------------

PROCESS(ClkData,Reset_DataGenerate)
BEGIN
	IF (Reset_DataGenerate = '1') THEN
		data_gate_min1	 		<= '0';
		data_gate		 		<= '0';
		gate_counter		  <= (OTHERS => '0');
	ELSIF rising_edge(ClkData) THEN	
		gate_counter <= gate_counter + 1;
		
		IF gate_counter < X"80" THEN
			data_gate_min1 <= '1';
		ELSE
			data_gate_min1 <= '0';
		END if;
		IF throttle_data = '1' THEN
			data_gate <= data_gate_min1;
		ELSE
			data_gate <= '1'; -- no throttling.
		END if;
	END if;
END PROCESS;

----------------------------------------------------------------------------------------
-- DataGenerators 
----------------------------------------------------------------------------------------

DataIn_ready_final <= DataIn_ready and data_gate;
	
CountGenerate_inst:CountGenerate PORT MAP(
	coreclk  		=> ClkData,
	Reset	 			=> Reset_DataGenerate,
	StartValue		=> (OTHERS => '0'),
	Enable			=> DataIn_ready_final,
	Inserterror 	=> '0', -- The counterpattern is used only to make sure the lanes are aligned.
	Counterout 		=> Counterout, 
	Valid				=> DataIn_valid
	);	

StartValue(0)		<= X"012345677654321";
StartValue(1)		<= X"111111111111111";
StartValue(2)		<= X"222222222222222";
StartValue(3)		<= X"333333333333333";
	

Generate_PrbsGenerate:
FOR I IN 0 to NUMBER_OF_LANES-1 GENERATE	
PrbsGenerate_inst:PrbsGenerate_60bit PORT MAP(
	coreclk  		=> ClkData,
	Reset	 			=> Reset_DataGenerate,
	StartValue		=> StartValue(I),
	Enable			=> DataIn_ready_final,
	Inserterror 	=> InsertError,
	Prbsout 			=> Prbsout(I),
	Valid				=> OPEN 						-- Should be synchronously with the counterdata
	);	
END GENERATE;

----------------------------------------------------------------------------------------
-- Map Counter and Prbs patterns to the 256 bit bus for the 4 lanes
-- Use 4 bits of counterpattern for 4 MSB (spread over the 4 lanes) and 60 lower bits for a PRBS-23 pattern
----------------------------------------------------------------------------------------

Generate_TxData:
FOR I IN 0 to NUMBER_OF_LANES-1 GENERATE
DataIn_Tx(63 + (64*I) DOWNTO 64*I) 		<=  CounterOut(3 + (4*I) DOWNTO 4*I)  & Prbsout(I);
END GENERATE;

		
fpll_inst : COMPONENT fpll
port map (
	hssi_pll_cascade_clk => Clk312Mhz, 		-- hssi_pll_cascade_clk.clk
	pll_cal_busy         => OPEN,         	-- pll_cal_busy.pll_cal_busy
	pll_locked           => OPEN,          -- pll_locked.pll_locked
	pll_powerdown        => OPEN,       	-- pll_powerdown.pll_powerdown
	pll_refclk0          => RefClock			-- pll_refclk0.clk
);


----------------------------------------------------------------------------------------
-- SuperliteII TXRX Module
----------------------------------------------------------------------------------------

superliteii_txrx_module_inst: superliteii_txrx_module 
GENERIC MAP
	(
		READ_LENGTH_SIM			=> X"0100",
		READ_LENGTH					=> X"0420",
		IDLE_LENGTH					=> X"7",	
		NUMBER_OF_LANES			=>  NUMBER_OF_LANES,	  	-- NUMBER_OF_LANES
		LANEWIDTH					=> LANEWIDTH,				-- LANEWIDTH for transceiver
		SIMPLEX						=> SIMPLEX,
		SIMULATION					=> SIMULATION
	)
PORT MAP(
	Reset								=> Reset,
			
	RefClock							=> Clk312Mhz, 	
	MgmtClk 							=> MgmtClk,	
			
	Serial_Loop						=> Serial_Loop,			
		
	-- Parallel Data input clocked with DataClock (coming from the transceiver)
	DataIn							=> DataIn_Tx,
	DataIn_Valid					=> DataIn_Valid, 
	DataClock						=> ClkData,	-- TxCoreClock
	DataIn_ready					=> DataIn_ready,
	XOFF								=> XOFF,	
	TxCoreClock						=> TxCoreClock, 
	
	-- High speed serial data outputs
	XCVR_TX							=> XCVR_TX,	
	
	-- Status SIGNALs
	tx_ready							=> pll_locked(0),
	
	ForceAlign						=> ForceAlign,			
	Reset_Rx							=> Reset_Rx,
	
	-- High speed serial input data lanes
	XCVR_RX							=> XCVR_RX, 
	
	-- Parallel Data Output (with Valid SIGNAL) and clock
	DataOut							=> Data_Out_Rx,
	DataOut_Valid					=> Enable_Rx,
	DataOut_Clock					=> DataOut_Clock,
			
	-- Status SIGNALs	
	rx_freqlocked					=> rx_freqlocked,
	rx_ready							=> OPEN,
	Reset_Rx_Path					=> Reset_Rx_Path,
	WordAligned						=> WordAligned,
	decoder_error					=> decoder_error,
	Error_Deskew					=> Error_Deskew,	
	LaneAligned						=> LaneAligned,
	Linkup							=> Linkup,
	XOFF_Received					=> XOFF_Received,	
	Rx_Error							=> Rx_Error,
	Delay								=> Delay,
	Lane_identifier				=> Lane_identifier,
	Latency							=> Latency,

	-- Transceiver reconfiguration interface	
	reconfig_reset		      	=> reconfig_reset_i,
	reconfig_write          	=> reconfig_write,
	reconfig_read           	=> reconfig_read,
	reconfig_address        	=> reconfig_address,
	reconfig_writedata      	=> reconfig_writedata,
	reconfig_readdata       	=> reconfig_readdata,
	reconfig_waitrequest    	=> reconfig_waitrequest,
	
	-- LC PLL reconfiguration interface	
	reconfig_pll_reset       	=> reconfig_pll_reset_i,
	reconfig_pll_write       	=> reconfig_pll_write,
	reconfig_pll_read        	=> reconfig_pll_read,
	reconfig_pll_address       => reconfig_pll_address,
	reconfig_pll_writedata     => reconfig_pll_writedata,
	reconfig_pll_readdata      => reconfig_pll_readdata,
	reconfig_pll_waitrequest 	=> reconfig_pll_waitrequest
	
	);

ForceAlign <= Force_Realign; -- synchronization to dataout_clock is done in superliteii_txrx_module

-----------------------------------------------------------------------------------------------------------
--	Synchronize to MgmtClk
-----------------------------------------------------------------------------------------------------------	

PROCESS(MgmtClk,Reset)	
BEGIN
	IF Reset = '1' THEN 					
		rx_freqlocked_Q 	<= (OTHERS => '0');
		rx_freqlocked_Q1 	<= (OTHERS => '0'); 
		rx_freqlocked_Q2 	<= (OTHERS => '0');			
		
		pll_locked_Q 		<=  '0';	
		pll_locked_Q1 		<=  '0';	
		pll_locked_Q2 		<=  '0';	
	ELSIF rising_edge(MgmtClk) THEN	
--	
		rx_freqlocked_Q <= rx_freqlocked;
		rx_freqlocked_Q1 <= rx_freqlocked_Q;
		rx_freqlocked_Q2 <= rx_freqlocked_Q1;  -- This is to synchronize Rx_Freqlocked to the phy_mgmt_clk domain
		
		pll_locked_Q	 <= pll_locked(0);
		pll_locked_Q1	 <= pll_locked_Q;		-- This is to synchronize Pll_Locked to the phy_mgmt_clk domain
		pll_locked_Q2	 <= pll_locked_Q1;
		
	END if;
END PROCESS;

-----------------------------------------------------------------------------------------------------------
--	Counter Verification Instantiation
-----------------------------------------------------------------------------------------------------------	

PROCESS(DataOut_Clock)
BEGIN
	IF rising_edge(DataOut_Clock) THEN
		IF Reset_Rx_Path = '1' THEN
			Reset_DataVerify  <= '1';
		ELSE
			IF (LaneAligned = '1') THEN
				Reset_DataVerify	 <= '0';
			ELSE
				Reset_DataVerify 	<= '1';
			END if;
		END if;
	END if;
END PROCESS;

-----------------------------------------------------------------------------------------------------------
--	Synchronize ResetErrorCount
-----------------------------------------------------------------------------------------------------------	

Reset_in1	<= Reset or ResetErrorCount; -- Both are generated on MgmtClk

Reset_Synchro_inst1 : Reset_Synchro
PORT MAP
	(
	Clk			=> DataOut_Clock,
	Reset_in		=> Reset_in1,
	Reset_out	=> ResetErrorCount_I 
	);

-----------------------------------------------------------------------------------------------------------
--	Re-order lanes according to received Lane_identifier
-----------------------------------------------------------------------------------------------------------		

Generate_reorder_lanes:
FOR I IN 0 to NUMBER_OF_LANES-1 GENERATE

PrbsDataIn(I) <= Data_Out_Rx(59 DOWNTO 0) WHEN Lane_Identifier(I) = X"00" ELSE
					  Data_Out_Rx(123 DOWNTO 64) WHEN Lane_Identifier(I) = X"01" ELSE
					  Data_Out_Rx(187 DOWNTO 128) WHEN Lane_Identifier(I) = X"02" ELSE	
					  Data_Out_Rx(251 DOWNTO 192);
					  
CountVerifyDataIn(I) <= Data_Out_Rx(63 DOWNTO 60) WHEN Lane_Identifier(I) = X"00" ELSE
							   Data_Out_Rx(127 DOWNTO 124) WHEN Lane_Identifier(I) = X"01" ELSE
								Data_Out_Rx(191 DOWNTO 188) WHEN Lane_Identifier(I) = X"02" ELSE
								Data_Out_Rx(255 DOWNTO 252);
								
CountVerifyDataIn_combined((3 + 4*I) DOWNTO (4*I)) <= CountVerifyDataIn(I);								
								
END generate Generate_reorder_lanes;

CountVerify_inst:CountVerify PORT MAP(
	Clock  				=> DataOut_Clock,
	Reset	 				=> Reset_DataVerify,
	ResetErrorCount 	=> ResetErrorCount_I,
	DataIn			   => CountVerifyDataIn_combined,	
	Enable				=> Enable_Rx,
	CountLocked			=> CountLocked,
	ErrorCount_Q  		=> Errorcount_CountPattern
	);	
		
Generate_PrbsVerify:
FOR I IN 0 to NUMBER_OF_LANES-1 GENERATE	
PrbsVerify_instX:PrbsVerify_60bit PORT MAP(
	RxClock  			=> DataOut_Clock,
	Reset	 				=> Reset_DataVerify,
	ResetErrorCount 	=> ResetErrorCount_I,
	DataIn				=> PrbsDataIn(I),	
	Enable				=> Enable_Rx,
	PrbsLocked			=> PrbsLocked(I),
	ErrorCount_Q  		=> Errorcount_PrbsPattern(I)
	);
END GENERATE;


-----------------------------------------------------------------------------------------------------------
--	1ms Counter Instantiation
-----------------------------------------------------------------------------------------------------------	

Counter_1ms_inst:counter_1ms 
GENERIC MAP
	(
		BITRATE	 =>	CLK100M  
	)
PORT MAP(
	RefClock 	=> MgmtClk,
	Reset 		=> Reset_in1,
	count_1ms	=> Counter_1ms_Reg -- every tick of the counter corresponds to 1ms/
	);

-----------------------------------------------------------------------------------------------------------
--	Measure RefClock 
-----------------------------------------------------------------------------------------------------------	

measure_refclk_inst : measure_refclk
GENERIC MAP
	(
		CYC_MEASURE_CLK_IN_1_SEC	=> SAMPLES_100MHZ
	)
port MAP(
	RefClock					=> RefClock,
	Enable					=> '1',	
	Measure_Clk				=> MgmtClk,
	reset						=> PowerOnReset,
	RefClock_Measure		=> RefClock_Measure
	);


-----------------------------------------------------------------------------------------------------------
--	Measure DataClock (to calculate throughput)
-----------------------------------------------------------------------------------------------------------	

measure_DataClock_inst : measure_refclk
GENERIC MAP
	(
		CYC_MEASURE_CLK_IN_1_SEC	=> SAMPLES_100MHZ
	)
port MAP(
	RefClock					=> ClkData,
	Enable					=> '1',
	Measure_Clk				=> MgmtClk,
	reset						=> PowerOnReset,
	RefClock_Measure		=> DataClock_Measure
	);
	
-----------------------------------------------------------------------------------------------------------
--	Measure the received datarate (actual Datathroughput)
-----------------------------------------------------------------------------------------------------------	

measure_DataOut_Clock_inst : measure_refclk
GENERIC MAP
	(
		CYC_MEASURE_CLK_IN_1_SEC	=> SAMPLES_100MHZ
	)
port MAP(
	RefClock					=> DataOut_Clock,
	Enable					=> Enable_Rx,
	Measure_Clk				=> MgmtClk,
	reset						=> Reset_In1, -- synchronous to MgmtClk
	RefClock_Measure		=> DataOut_Clock_Measure
	);
	
	
-----------------------------------------------------------------------------------------------------------
--	Create ErrorCount, Locked and ChannelOK
-----------------------------------------------------------------------------------------------------------	
	
PROCESS(DataOut_Clock)
BEGIN

IF rising_edge(DataOut_Clock) THEN
	IF Reset_Rx_Path = '1' THEN
		ChannelOK	<= '0';
		ErrorCount	<= (OTHERS => '0');
		ErrorCount_part1 <= (OTHERS => '0');
		ErrorCount_part2 <= (OTHERS => '0');	
		ErrorCount_part3 <= (OTHERS => '0');			
		Locked		<= '0';
	ELSE
		ErrorCount_part1 	<= Errorcount_PrbsPattern(0) + Errorcount_PrbsPattern(1);
		ErrorCount_part2 	<=	Errorcount_PrbsPattern(2) + Errorcount_PrbsPattern(3);
		ErrorCount_part3	<= ErrorCount_CountPattern;
		ErrorCount(15 DOWNTO 0)		<= ErrorCount_part1 + ErrorCount_part2 +  ErrorCount_part3;					
		Locked							<= CountLocked and PrbsLocked(0) and PrbsLocked(1) and PrbsLocked(2) and PrbsLocked(3) ;
					
		IF ((Locked = '1') AND (Errorcount = X"0000000000000000")) THEN
			ChannelOK 	<= '1';
		ELSE
			ChannelOK 	<= '0';
		END if;		
	END if;
END if;
END PROCESS;

-----------------------------------------------------------------------------------------------------------
--	Create status registers and led output
-----------------------------------------------------------------------------------------------------------	

Generate_rx_freqlocked_combined:
FOR i IN 0 to NUMBER_OF_LANES-1 GENERATE
	Ones(I) <=  '1'; 		
END GENERATE;


rx_freqlocked_combined <= '1' WHEN rx_freqlocked_Q2 = Ones ELSE '0';

Channel_Reg_i(17 DOWNTO 10) <= REFCLOCKMULTIPLIER;
Channel_Reg_i(9) 	<= Locked; 
Channel_Reg_i(8) 	<= pll_locked_Q2;
Channel_Reg_i(7) 	<= LaneAligned;
Channel_Reg_i(6) 	<= rx_freqlocked_combined;
Channel_Reg_i(5) 	<= Linkup;
Channel_Reg_i(4) 	<= XOFF_Received;
Channel_Reg_i(3) 	<= ChannelOK;
Channel_Reg_i(2) 	<= Error_Deskew;
Channel_Reg_i(1) 	<= decoder_error;
Channel_Reg_i(0) 	<= WordAligned;	

-----------------------------------------------------------------------------------------------------------
--	Since Channel_Reg is combining SIGNALs from different clock domains, this needs to be synchronized to the MgmtClk.
-----------------------------------------------------------------------------------------------------------	

Channel_Reg_synchronize : hyper_pipe 
GENERIC MAP
	(
		DWIDTH	 =>	18,
		NUM_PIPES =>   3
	)
PORT MAP(
	clk			=> MgmtClk,
	din			=> Channel_Reg_i,	
	dout			=> Channel_Reg
	);	

-----------------------------------------------------------------------------------------------------------
--	Synchronize ErrorCount
-----------------------------------------------------------------------------------------------------------	

ErrorCount_synchronize : hyper_pipe 
GENERIC MAP
	(
		DWIDTH	 =>	16,
		NUM_PIPES =>   3
	)
PORT MAP(
	clk			=> MgmtClk,
	din			=> ErrorCount,	
	dout			=> ErrorCount_Reg
	);
	
-----------------------------------------------------------------------------------------------------------
--	Synchronize Latency
-----------------------------------------------------------------------------------------------------------	

Latency_synchronize : hyper_pipe 
GENERIC MAP
	(
		DWIDTH	 =>	8,
		NUM_PIPES =>   3
	)
PORT MAP(
	clk			=> MgmtClk,
	din			=> Latency,	
	dout			=> Latency_Max_Reg 
	);

Latency_Min_Reg <= (OTHERS => '0'); -- The design does not provide minimum latency

Bitrate_Reg 	<= RefClock_Measure ; 
DataClock_Reg	<= DataClock_Measure;
DataOut_Clock_Reg	<= DataOut_Clock_Measure;

Generate_DELAY_REG:
FOR i IN 0 to NUMBER_OF_LANES-1 GENERATE
	Delay_Reg((5*I)+4 DOWNTO (5*I)) <=  Delay(I); 		
END GENERATE;

Delay_Reg_2 <= (OTHERS => '0');
			
END;
