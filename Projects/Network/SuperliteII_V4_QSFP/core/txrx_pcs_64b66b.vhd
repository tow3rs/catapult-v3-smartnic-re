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
-- design file available, Altera expressly does not recommend, suggest or
-- require that this reference design file be used in combination with any
-- other product not provided by Altera.
----------------------------------------------------------------------------------------------------
-- Author		 : Peter Schepers (pscheper)
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
entity txrx_pcs_64b66b is
GENERIC
	(
		NUMBER_OF_LANES	: integer := 4;	  	-- NUMBER_OF_LANES
		LANEWIDTH			: integer := 64;		-- LANEWIDTH for transceiver			
		SIMULATION			: boolean := false
	);
PORT(
		Reset						: IN STD_LOGIC;
		
		Serial_Loop				: IN STD_LOGIC_VECTOR ((NUMBER_OF_LANES - 1) downto 0);
		reconfig_mgmt_clk		: in std_logic; 
		RefClock					: IN STD_LOGIC;
		tx_coreclk				: IN STD_LOGIC; -- divide by 66 clock (tonnect to tx_clkout externally)
		tx_ctrlenable			: IN STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
		tx_datain				: IN STD_LOGIC_VECTOR (((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);
		tx_datain_valid		: IN STD_LOGIC;	
		pll_locked				: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		tx_clkout				: OUT STD_LOGIC; -- divide by 66 clock
		tx_dataout				: OUT STD_LOGIC_VECTOR ((NUMBER_OF_LANES - 1) downto 0);		
		rx_datain				: IN STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) DOWNTO 0); 
	   rx_fifo_rd_en			: in 	STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) DOWNTO 0); 
		rx_enh_fifo_pempty	: out STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) DOWNTO 0);		
		rx_clkout				: OUT STD_LOGIC; -- recovered clock
		rx_ctrldetect			: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
		rx_dataout				: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0); -- Synchronous with rx_clkout
		rx_disperr				: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
		rx_errdetect			: OUT STD_LOGIC_VECTOR (((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
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
		reconfig_address        : in  std_logic_vector(15 downto 0)  := (others => '0'); 
		reconfig_writedata      : in  std_logic_vector(31 downto 0)  := (others => '0'); 
		reconfig_readdata       : out std_logic_vector(31 downto 0);   
		reconfig_waitrequest    : out  std_logic;
		
		-- transmit PLL reconfiguration interface	
		reconfig_pll_reset          : in  std_logic; 
		reconfig_pll_write          : in  std_logic; 
		reconfig_pll_read           : in  std_logic; 
		reconfig_pll_address        : in  std_logic_vector(15 downto 0)  := (others => '0'); 
		reconfig_pll_writedata      : in  std_logic_vector(31 downto 0)  := (others => '0'); 
		reconfig_pll_readdata       : out std_logic_vector(31 downto 0);   
		reconfig_pll_waitrequest    : out  std_logic 	
		
	);
END txrx_pcs_64b66b;		


architecture rtl of txrx_pcs_64b66b is


component Encoder_64b66b is
PORT(
	Clk  				: in std_logic;
	Enable			: in std_logic;
	Reset	 			: in std_logic;
	kin				: in std_logic_vector(7 downto 0);
	din				: in std_logic_vector(63 downto 0);
	dout	 			: out std_logic_vector(65 downto 0);	
	dout_valid 		: out std_logic;
	encoder_error	: out std_logic
	);
END component;
 
component Decoder_66b64b is
PORT(
	Clk  					: in std_logic;
	Enable				: in std_logic;
	Reset	 				: in std_logic;
	din					: in std_logic_vector(65 downto 0);
	rx_enh_blk_lock 	: in std_logic;
	dout	 				: out std_logic_vector(63 downto 0);
	kout					: out std_logic_vector(7 downto 0);	
	valid 				: out std_logic;
	Aligned				: out std_logic	
	);
END component; 

	
component Reset_Synchro
port
	(
	Clk			: in std_logic;
	Reset_in	: in std_logic;
	Reset_out	: out std_logic
	);
END component; 

component Measure_RunLength is
PORT(
	Clock  				: in std_logic;
	Reset	 				: in std_logic;
	DataIn 				: in std_logic_vector(65 downto 0);
	Max_Runlength		: out std_logic_vector(8 downto 0)
	);
END component; 
	

			
-- MODIFICATION 
-- Component needs to match the required number of lanes
	component xcvr_superlite_ii is
		port (
			tx_analogreset          : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- tx_analogreset
			tx_digitalreset         : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- tx_digitalreset
			rx_analogreset          : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- rx_analogreset
			rx_digitalreset         : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- rx_digitalreset
			tx_cal_busy             : out std_logic_vector(3 downto 0);                      -- tx_cal_busy
			rx_cal_busy             : out std_logic_vector(3 downto 0);                      -- rx_cal_busy
			tx_serial_clk0          : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- clk
			rx_cdr_refclk0          : in  std_logic                      := 'X';             -- clk
			tx_serial_data          : out std_logic_vector(3 downto 0);                      -- tx_serial_data
			rx_serial_data          : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- rx_serial_data
			rx_seriallpbken         : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- rx_seriallpbken
			rx_set_locktodata       : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- rx_set_locktodata
			rx_set_locktoref        : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- rx_set_locktoref
			rx_is_lockedtoref       : out std_logic_vector(3 downto 0);                      -- rx_is_lockedtoref
			rx_is_lockedtodata      : out std_logic_vector(3 downto 0);                      -- rx_is_lockedtodata
			tx_coreclkin            : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- clk
			rx_coreclkin            : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- clk
			tx_clkout               : out std_logic_vector(3 downto 0);                      -- clk
			rx_clkout               : out std_logic_vector(3 downto 0);                      -- clk
			tx_pma_clkout           : out std_logic_vector(3 downto 0);                      -- clk
			tx_pma_div_clkout       : out std_logic_vector(3 downto 0);                      -- clk
			rx_pma_div_clkout       : out std_logic_vector(3 downto 0);                      -- clk
			tx_parallel_data        : in  std_logic_vector(255 downto 0) := (others => 'X'); -- tx_parallel_data
			tx_control              : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- tx_control
			unused_tx_parallel_data : in  std_logic_vector(255 downto 0) := (others => 'X'); -- unused_tx_parallel_data
			unused_tx_control       : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- unused_tx_control
			rx_parallel_data        : out std_logic_vector(255 downto 0);                    -- rx_parallel_data
			rx_control              : out std_logic_vector(7 downto 0);                      -- rx_control
			unused_rx_parallel_data : out std_logic_vector(255 downto 0);                    -- unused_rx_parallel_data
			unused_rx_control       : out std_logic_vector(71 downto 0);                     -- unused_rx_control
			tx_enh_data_valid       : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- tx_enh_data_valid
			rx_enh_fifo_rd_en       : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- rx_enh_fifo_rd_en
			rx_enh_fifo_full        : out std_logic_vector(3 downto 0);                      -- rx_enh_fifo_full
			rx_enh_fifo_pfull       : out std_logic_vector(3 downto 0);                      -- rx_enh_fifo_pfull
			rx_enh_fifo_empty       : out std_logic_vector(3 downto 0);                      -- rx_enh_fifo_empty
			rx_enh_fifo_pempty      : out std_logic_vector(3 downto 0);                      -- rx_enh_fifo_pempty
			rx_enh_blk_lock         : out std_logic_vector(3 downto 0);                      -- rx_enh_blk_lock
			reconfig_clk            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- clk
			reconfig_reset          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- reset
			reconfig_write          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- write
			reconfig_read           : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- read
			reconfig_address        : in  std_logic_vector(11 downto 0)  := (others => 'X'); -- address
			reconfig_writedata      : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- writedata
			reconfig_readdata       : out std_logic_vector(31 downto 0);                     -- readdata
			reconfig_waitrequest    : out std_logic_vector(0 downto 0)                       -- waitrequest
		);
	end component xcvr_superlite_ii;

	component xcvr_reset_controller is
		port (
			clock              : in  std_logic                    := 'X';             -- clk
			pll_cal_busy       : in  std_logic_vector(0 downto 0) := (others => 'X'); -- pll_cal_busy
			pll_locked         : in  std_logic_vector(0 downto 0) := (others => 'X'); -- pll_locked
			pll_powerdown      : out std_logic_vector(0 downto 0);                    -- pll_powerdown
			pll_select         : in  std_logic_vector(0 downto 0) := (others => 'X'); -- pll_select
			reset              : in  std_logic                    := 'X';             -- reset
			rx_analogreset     : out std_logic_vector(3 downto 0);                    -- rx_analogreset
			rx_cal_busy        : in  std_logic_vector(3 downto 0) := (others => 'X'); -- rx_cal_busy
			rx_digitalreset    : out std_logic_vector(3 downto 0);                    -- rx_digitalreset
			rx_is_lockedtodata : in  std_logic_vector(3 downto 0) := (others => 'X'); -- rx_is_lockedtodata
			rx_ready           : out std_logic_vector(3 downto 0);                    -- rx_ready
			tx_analogreset     : out std_logic_vector(3 downto 0);                    -- tx_analogreset
			tx_cal_busy        : in  std_logic_vector(3 downto 0) := (others => 'X'); -- tx_cal_busy
			tx_digitalreset    : out std_logic_vector(3 downto 0);                    -- tx_digitalreset
			tx_ready           : out std_logic_vector(3 downto 0)                     -- tx_ready
		);
	end component xcvr_reset_controller;

	
	component xcvr_pll is
		port (
			mcgb_rst              : in  std_logic                     := 'X';             -- mcgb_rst
			mcgb_serial_clk       : out std_logic;                                        -- clk
			pll_cal_busy          : out std_logic;                                        -- pll_cal_busy
			pll_locked            : out std_logic;                                        -- pll_locked
			pll_powerdown         : in  std_logic                     := 'X';             -- pll_powerdown
			pll_refclk0           : in  std_logic                     := 'X';             -- clk
			reconfig_write0       : in  std_logic                     := 'X';             -- write
			reconfig_read0        : in  std_logic                     := 'X';             -- read
			reconfig_address0     : in  std_logic_vector(9 downto 0)  := (others => 'X'); -- address
			reconfig_writedata0   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			reconfig_readdata0    : out std_logic_vector(31 downto 0);                    -- readdata
			reconfig_waitrequest0 : out std_logic;                                        -- waitrequest
			reconfig_clk0         : in  std_logic                     := 'X';             -- clk
			reconfig_reset0       : in  std_logic                     := 'X';             -- reset
			tx_serial_clk         : out std_logic                                         -- clk
		);
	end component xcvr_pll;

	
	component Synchro is
	port
		(
		Clk			: in std_logic;
		data_in		: in std_logic;
		data_out		: out std_logic
		);
	end component Synchro;

	
CONSTANT DATAWIDTH	 				: integer := 66;

type Bit6Type is array (0 to (NUMBER_OF_LANES-1)) of std_logic_vector(5 downto 0);
type Bit9Type is array (0 to (NUMBER_OF_LANES-1)) of std_logic_vector(8 downto 0);
type Bit6_Type is array (0 to 1) of std_logic_vector(5 downto 0);

signal tx_encoded						: std_logic_vector(((NUMBER_OF_LANES * DATAWIDTH)-1) downto 0);
signal tx_buffered					: std_logic_vector(((NUMBER_OF_LANES * DATAWIDTH)-1) downto 0);
signal tx_data_gearbox				: std_logic_vector(((NUMBER_OF_LANES * 40)-1) downto 0);
signal valid_encoded					: std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);

attribute syn_keep 					: boolean;

signal Reset_Rx						: std_logic;
signal tx_coreclk_i					: std_logic_vector((NUMBER_OF_LANES-1) downto 0); 
signal rx_coreclk_i					: std_logic_vector((NUMBER_OF_LANES-1) downto 0); 
signal rx_unaligned					: std_logic_vector(((NUMBER_OF_LANES * DATAWIDTH)-1) downto 0);
signal rx_bitslipped					: std_logic_vector(((NUMBER_OF_LANES * DATAWIDTH)-1) downto 0);
signal rx_data_gearbox				: std_logic_vector(((NUMBER_OF_LANES * DATAWIDTH)-1) downto 0);
signal rx_data_buffered 			: std_logic_vector(((NUMBER_OF_LANES * DATAWIDTH)-1) downto 0);
signal rx_data			 				: std_logic_vector(((NUMBER_OF_LANES * DATAWIDTH)-1) downto 0);
signal rx_aligned						: std_logic_vector(((NUMBER_OF_LANES * DATAWIDTH)-1) downto 0);
signal rx_valid_decoder				: std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
signal rx_clkout_i					: std_logic_vector((NUMBER_OF_LANES-1) downto 0); 
			
signal Bitslip							: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal AlignChanged					:Bit6Type;
signal RxError							: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal Reset_Tx						: std_logic;
signal Reset_Tx_i						: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal tx_clk							: std_logic;
signal txpll_locked					: std_logic;
signal Enable_Tx 						: std_logic_vector((NUMBER_OF_LANES-1) downto 0);

signal rx_data_gearbox_valid 		: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal rx_data_buffered_valid 	: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal rx_data_valid 				: std_logic_vector((NUMBER_OF_LANES-1) downto 0);

signal txpll_locked_Q				: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal txpll_locked_Q1				: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal txpll_locked_Q2				: std_logic_vector((NUMBER_OF_LANES-1) downto 0);
signal tx_ready_Q						: std_logic;
signal tx_ready_Q1					: std_logic;
signal tx_ready_Q2					: std_logic;
signal rx_ready_Q						: std_logic;
signal rx_ready_Q1					: std_logic;
signal rx_ready_Q2					: std_logic;
signal pll_locked_i					: std_logic_vector(0 downto 0);
	
signal PowerOnReset 					: std_logic;
signal ResetCount						: std_logic_vector(5 downto 0) := (OTHERS => '0');
	
signal rx_analogreset				: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
signal tx_analogreset				: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
signal rx_digitalreset				: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
signal tx_digitalreset				: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
	
signal rx_digitalreset_i			: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
signal tx_digitalreset_i			: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
signal tx_cal_busy        	 	 	: std_logic_vector((NUMBER_OF_LANES - 1) downto 0);
signal rx_cal_busy        		 	: std_logic_vector((NUMBER_OF_LANES - 1) downto 0);
signal tx_ready_i					 	: std_logic_vector((NUMBER_OF_LANES - 1) downto 0);
signal rx_ready_i					 	: std_logic_vector((NUMBER_OF_LANES - 1) downto 0);
signal tx_parallel_data			 	: std_logic_vector(((NUMBER_OF_LANES * 64)-1) downto 0);
signal rx_parallel_data			 	: std_logic_vector(((NUMBER_OF_LANES * 64)-1) downto 0);
signal tx_10g_control			 	: std_logic_vector(((NUMBER_OF_LANES * 2)-1) downto 0);
signal rx_10g_control			 	: std_logic_vector(((NUMBER_OF_LANES * 2)-1) downto 0);
signal pll_powerdown				 	: std_logic_vector(0 downto 0);
signal pll_powerdown_c			 	: std_logic_vector((NUMBER_OF_LANES - 1) downto 0);
signal rx_freqlocked_i			 	: std_logic_vector((NUMBER_OF_LANES - 1) downto 0);
signal ZEROES						 	: std_logic_vector((NUMBER_OF_LANES - 1) downto 0);
signal ONES							 	: std_logic_vector((NUMBER_OF_LANES - 1) downto 0);
signal pll_tx_outclk				 	: std_logic;

signal force_xcvr_reset_rx		 	: std_logic;

signal reset_rx_count			 	: std_logic_vector(3 downto 0);
signal RunLength					 	: Bit9Type;
signal xcvr_reset_tx_reset_in	 	: std_logic;
signal pll_tx_locked 			 	: std_logic;
signal pll_tx_locked_Q 			 	: std_logic;
signal pll_tx_locked_Q1			 	: std_logic;
signal pll_tx_locked_Q2 		 	: std_logic;
	
signal tx_pma_div_clkout		 	: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
signal xcvr_tx_bonding_clocks			: std_logic_vector(((NUMBER_OF_LANES * 6)-1) downto 0);
signal tx_serial_clk_pll		 	: std_logic_vector (0 downto 0);
signal tx_serial_clk				 	: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
signal tx_cal_busy_combined	 	: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
	
signal pll_cal_busy				 	: std_logic_vector (0 downto 0);
signal rx_fifo_full   			 	: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
signal rx_fifo_pfull   			 	: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
signal rx_fifo_empty   			 	: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);

signal fifo_error	 					: std_logic;

attribute syn_keep of fifo_error : signal is true;
signal decoder_error_i 				: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);

signal rx_enh_blk_lock			 	: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
signal rx_enh_blk_lock_sync	 	: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);

begin



-----------------------------------------------------------------------------------------------------------
--	Create Reset_TX 
-----------------------------------------------------------------------------------------------------------	

process(tx_coreclk,Reset) -- Note that externally the user should connect tx_coreclk to tx_clkout
begin
	if Reset = '1' then
		Reset_Tx	 				<= '1';
		tx_ready_Q				<= '0';
		tx_ready_Q1				<= '0';
		tx_ready_Q2				<= '0';				
	elsif rising_edge(tx_coreclk) then
		tx_ready_Q				<= tx_ready;				-- Synchronize to tx_coreclk clock domain
		tx_ready_Q1				<= tx_ready_Q;	
		tx_ready_Q2				<= tx_ready_Q1;	
			
		if (tx_ready_Q2 = '1')   then
			Reset_Tx	 			<= '0';
		else
			Reset_Tx 			<= '1';
		end if;
	end if;
end process;


-----------------------------------------------------------------------------------------------------------
--	Instantiate very basic 64B/66B encoder (fully combinatorial)
-----------------------------------------------------------------------------------------------------------	

Generate_Encoder64b66b:
FOR I IN 0 to NUMBER_OF_LANES-1 GENERATE
Encoder_64b66b_inst : Encoder_64b66b
PORT MAP 
	(
		Clk				=> tx_coreclk,		-- Note that externally the user should connect tx_coreclk to tx_clkout
		Reset	  			=> Reset_Tx,	
		Enable			=> tx_datain_valid,
		kin				=> tx_ctrlenable((8*(I+1)-1) downto (8*I)),
		din				=> tx_datain((64*(I+1)-1) downto (64*I)),
		dout				=> tx_encoded((66*(I+1)-1) downto (66*I)),
		dout_valid		=> valid_encoded(I),
		encoder_error	=> encoder_error(I)
	);
END GENERATE;

-----------------------------------------------------------------------------------------------------------
--	Instantiate ATX PLL
-----------------------------------------------------------------------------------------------------------	

xcvr_pll_inst : xcvr_pll PORT MAP (
		mcgb_rst              	=> Reset,
		mcgb_serial_clk    		=> tx_serial_clk_pll(0),
		pll_powerdown 				=> pll_powerdown(0),
		pll_refclk0   				=> RefClock,
		tx_serial_clk 				=> open,
		pll_locked					=> pll_locked_i(0),
		pll_cal_busy  				=> pll_cal_busy(0) ,
		reconfig_clk0        	=> reconfig_mgmt_clk,
		reconfig_reset0       	=> reconfig_pll_reset,
		reconfig_write0       	=> reconfig_pll_write,
		reconfig_read0        	=> reconfig_pll_read,
		reconfig_address0       => reconfig_pll_address(9 downto 0),
		reconfig_writedata0     => reconfig_pll_writedata,
		reconfig_readdata0      => reconfig_pll_readdata,
		reconfig_waitrequest0 	=> reconfig_pll_waitrequest	
	);
	
	
-----------------------------------------------------------------------------------------------------------
--	Create rx_coreclk and tx_clkout
-----------------------------------------------------------------------------------------------------------	

Generate_xcvr_rx_clocks:
FOR i IN 0 to NUMBER_OF_LANES-1 GENERATE
	tx_clkout		 				<= tx_pma_div_clkout(0);  -- This is /33 clock 
	tx_coreclk_i(I)				<= tx_pma_div_clkout(0)	;	
	rx_clkout		 				<= rx_clkout_i(0);  		-- This is /33 clock 
	rx_coreclk_i(I) 				<= rx_clkout_i(0)	; 		-- use lane 0 recovered clock to clock out all lanes
	tx_serial_clk(I) 				<= tx_serial_clk_pll(0);
	tx_cal_busy_combined(I) 	<= tx_cal_busy(I) or pll_cal_busy(0);	
END GENERATE;

-----------------------------------------------------------------------------------------------------------
--	Map tx_encoded to tx_parallel_data and tx_10g_control 
-----------------------------------------------------------------------------------------------------------	
Generate_Tx_data:
FOR i IN 0 to NUMBER_OF_LANES-1 GENERATE

tx_parallel_data((64*(I+1)-1) downto (64*I)) 	<= tx_encoded((66*(I+1)-3) downto (66*I));
tx_10g_control(0+(I*2)) <= tx_encoded(64 + 66*I);
tx_10g_control(1+(I*2)) <= tx_encoded(65 + 66*I);

END GENERATE;


-----------------------------------------------------------------------------------------------------------
--	Instantiate Native PHY
-----------------------------------------------------------------------------------------------------------	

xcvr_txrx_inst : xcvr_superlite_ii PORT MAP(
	
		rx_seriallpbken     			=> Serial_Loop,		
		tx_analogreset					=> tx_analogreset,
		tx_digitalreset				=> tx_digitalreset,		
		rx_cdr_refclk0	     			=> RefClock,	
		tx_serial_data      			=> tx_dataout,                 
		rx_serial_data      			=> rx_datain,
		rx_analogreset					=> rx_analogreset,
		rx_digitalreset				=> rx_digitalreset,
		rx_set_locktodata  			=> (OTHERS => '0'), -- Automatic LTD Mode
		rx_set_locktoref   			=> (OTHERS => '0'),	
		rx_is_lockedtodata			=> rx_freqlocked_i,	
		tx_cal_busy        			=> tx_cal_busy,
		rx_cal_busy        			=> rx_cal_busy,
		tx_parallel_data				=> tx_parallel_data,
		rx_parallel_data				=> rx_parallel_data,
		tx_coreclkin   				=> tx_coreclk_i,
		rx_coreclkin   				=> rx_coreclk_i,
		rx_enh_fifo_rd_en  			=> rx_fifo_rd_en,
		rx_enh_fifo_full   			=> rx_fifo_full,
		rx_enh_fifo_pfull  			=> rx_fifo_pfull,
		rx_enh_fifo_empty  			=> rx_fifo_empty,
		rx_enh_fifo_pempty 			=> rx_enh_fifo_pempty,	
		tx_pma_clkout      			=> open, 
		tx_pma_div_clkout				=> tx_pma_div_clkout, -- divide by 33
		tx_clkout      				=> open, 
		rx_clkout      				=> open,
		rx_pma_div_clkout				=> rx_clkout_i, -- divide by 33
		tx_control     				=> tx_10g_control,
		rx_control     				=> rx_10g_control,
		rx_enh_blk_lock     			=> rx_enh_blk_lock,	
		tx_enh_data_valid   			=> (OTHERS => '1'),
		tx_serial_clk0					=> tx_serial_clk,	
 		unused_tx_parallel_data 	=> (OTHERS => '0'),
 		unused_rx_parallel_data 	=> open,	
		unused_tx_control				=> (OTHERS => '0'),
		unused_rx_control				=> open,		
		reconfig_clk(0)        		=> reconfig_mgmt_clk,
		reconfig_reset(0)       	=> reconfig_reset,
		reconfig_write(0)       	=> reconfig_write,
		reconfig_read(0)        	=> reconfig_read,
		reconfig_address        	=> reconfig_address(11 downto 0),
		reconfig_writedata      	=> reconfig_writedata,
		reconfig_readdata       	=> reconfig_readdata,
		reconfig_waitrequest(0) 	=> reconfig_waitrequest			
);

	
-----------------------------------------------------------------------------------------------------------
--	Demap Rx_data
-----------------------------------------------------------------------------------------------------------	

Generate_Rx_data:
FOR i IN 0 to NUMBER_OF_LANES-1 GENERATE


rx_data((66*(I+1)-3) downto (66*I)) <= rx_parallel_data((64*(I+1)-1) downto (64*I)); 
rx_data(64 + 66*I) <= rx_10g_control(0+(I*2));
rx_data(65 + 66*I) <= rx_10g_control(1+(I*2));


END GENERATE;

	
----------------------------------------------------------------------------------------
-- Instantiate Reset Controller
----------------------------------------------------------------------------------------

xcvr_reset_controller_inst : xcvr_reset_controller
	port map(
		clock              	=> reconfig_mgmt_clk,
		reset              	=> Reset,
		pll_powerdown	      => pll_powerdown,
		tx_analogreset			=> tx_analogreset,
		tx_digitalreset		=> tx_digitalreset_i,	
		tx_ready           	=> tx_ready_i,
		pll_locked			   => pll_locked_i,
		pll_select         	=> (OTHERS => '0'),
		tx_cal_busy        	=> tx_cal_busy_combined,
		pll_cal_busy       	=> pll_cal_busy,
		rx_analogreset     	=> rx_analogreset,
		rx_cal_busy        	=> rx_cal_busy,
		rx_digitalreset    	=> rx_digitalreset_i,
		rx_is_lockedtodata 	=> rx_freqlocked_i,
		rx_ready           	=> rx_ready_i		
	);	
	
pll_locked(0) <=  pll_locked_i(0);
rx_freqlocked <= rx_freqlocked_i;	

-----------------------------------------------------------------------------------------------------------
--	Create combined rx_digitalreset that is the OR of all the different rx_digitalreset_i
--	Create combined rx_ready that is the AND of all individual rx_ready
-----------------------------------------------------------------------------------------------------------	

Generate_ZEROES_and_ONES:
FOR i IN 0 to NUMBER_OF_LANES-1 GENERATE
ZEROES(I) <= '0';
ONES(I) <= '1';
END GENERATE;
	
rx_digitalreset <= ZEROES when rx_digitalreset_i = ZEROES else ONES;
tx_digitalreset <= ZEROES when tx_digitalreset_i = ZEROES else ONES;
rx_ready	<= '1' when rx_ready_i = ONES else '0';
tx_ready	<= '1' when tx_ready_i = ONES else '0';

		
-- Keep everything in Reset until all channels are ready (indicated by rx_ready)

process(rx_coreclk_i(0),Reset)
begin
	if Reset = '1' then
		Reset_Rx				<= '1';
		rx_ready_Q 			<= '0';
		rx_ready_Q1			<= '0';
		rx_ready_Q2			<= '0';
		fifo_error 			<= '0';
	elsif rising_edge(rx_coreclk_i(0)) then
		rx_ready_Q	 		<= rx_ready;			-- Synchronize to rx_coreclk_i(0) clock domain
		rx_ready_Q1			<= rx_ready_Q;	
		rx_ready_Q2			<= rx_ready_Q1;				
		if (rx_ready_Q2 = '1')  then
			Reset_Rx		 		<= '0';
		else
			Reset_Rx	 			<= '1';
		end if;
		if ((decoder_error_i /= ZEROES)  or (rx_fifo_full /= ZEROES)) then
			fifo_error <= '1';
		else
			fifo_error <= '0';
		end if;

	end if;
end process;


-------------------------------------------------------------------------------------------------------------
----	66/64 module (checks for rx_enh_blk_lock) no additional clock.
-------------------------------------------------------------------------------------------------------------	
Generate_Decoder_66b64b:
FOR I IN 0 to NUMBER_OF_LANES-1 GENERATE

Synchro_inst : Synchro PORT MAP(
		Clk				=> rx_coreclk_i(0),
		data_in			=> rx_enh_blk_lock(I), -- asynchronous signal
		data_out			=> rx_enh_blk_lock_sync(I)
		);

	
Decoder_66b64b_inst : Decoder_66b64b PORT MAP(
	Clk  					=> rx_coreclk_i(0),
	Enable				=> '1',	
	Reset	 				=> Reset_Rx, 
	din					=> rx_data((66*(I+1)-1) downto (66*I)),
	rx_enh_blk_lock 	=> rx_enh_blk_lock_sync(I),
	dout	 				=> rx_dataout((64*(I+1)-1) downto (64*I)),
	kout					=> rx_ctrldetect((8*(I+1)-1) downto (8*I)),
	valid 				=> rx_valid(I),
	Aligned				=> Aligned(I)
	);
END GENERATE; 

decoder_error 	<= (OTHERS => '0');

rx_errdetect 	<= (OTHERS => '0');	
rx_disperr		<= (OTHERS => '0');

end;

