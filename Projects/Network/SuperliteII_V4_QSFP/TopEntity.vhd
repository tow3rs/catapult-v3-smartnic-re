-- Catapult V3 SmartNICs (10AXF40GAA)
-- 4 Channel Superlite II V4 Demo Design V20.1.1 (B720)
-- 4 Bidirectional Channels (Tx+Rx) at 10.3125 / 10.9375 / 12.5000 Gbps  (64b66b encoded), mapped to QSFP+ Module
-- Contains handshaking between Rx and Tx as well as Flow Control (XON/XOFF).
-- Uses RxFifo inside the transceivers to do the deskew
-- Using Native Phy Basic Enhanced PCS Mode
-- This version uses more embedded features of the enhanced PCS
-- 	=> Use Rx Block sync instead of bitslip 
--		=> Enables low latency mode (significant latency reduction)
-- 	=> Uses scrambler + descrambler of the Enhanced PCS instead of user generated scrambler/descrambler.
--
-- Last Update : March 3rd, 2021
-- Author : Peter Schepers (peter.schepers@intel.com)
-- Tow3rs : Port to Catapult V3 SmartNICs [08/02/2021]

-- Note V4 version is based on V3 but uses additional encoding to detect the lane identifiers to reorder the datalanes at reception 
-- (can be configured through parameter LANE_IDENTITY (if set to false it works IN V3 mode for backwards compatibility)

-- Added GENERIC parameter SIMPLEX which when set to true does not perform handshaking with the remote side and allows SIMPLEX operation (even when using Duplex transceiver).
-- When SIMPLEX is true Linkup will be declared when LaneAligned is achieved locally.

-- To enable ODI acceleration :
-- 
-- modify file .\core\xcvr_superlite_ii\synth\xcvr_superlite_ii.v
-- 		.dbg_odi_soft_logic_enable                                              (1), //MODIFIED
--
-- or
--
-- quartus.ini: add "altera_xcvr_native_a10_enable_odi_acc=1"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use work.package_delaytype.all; -- package that define "Delay_Array" type

LIBRARY work;

ENTITY TopEntity IS 
GENERIC
(
	VERSION				: std_logic_vector(31 DOWNTO 0)  := X"08022101";
	NUMBER_OF_LINKS	: integer 								:= 1;
	NUMBER_OF_LANES	: integer 								:= 4;  		-- NUMBER_OF_LANES_PER_LINK
	LANE_IDENTITY		: boolean 								:= true;		-- for backwards compatibility (false => backwards compatible with V3)
	SIMPLEX				: boolean 								:= false; 	-- When enabled, does not perform any handshaking with remote side.			
	SIMULATION			: boolean 								:= false	
);
PORT
(
	----------- CLOCKS --------------
	clk_u59		: IN STD_LOGIC;		 -- 100 Mhz
	clk_y3		: IN STD_LOGIC;		 -- 266.667 Mhz
	clk_y4		: IN STD_LOGIC;		 -- 266.667 Mhz
	clk_y5		: IN STD_LOGIC;		 -- 644.53125 Mhz
	clk_y6		: IN STD_LOGIC;		 -- 156.250 Mhz / 644.53125 Mhz
	clk_pcie1 	: IN STD_LOGIC;		 -- 100 Mhz
	clk_pcie2 	: IN STD_LOGIC;		 -- 100 Mhz
	
	----------- QSFP---------------
	qsfp_tx		: OUT std_logic_vector(3 DOWNTO 0);
	qsfp_rx 		: IN std_logic_vector(3 DOWNTO 0);
	modprsl 		: IN  STD_LOGIC;
	 
	------------ LEDS ---------------
	leds 			: OUT std_logic_vector(8 DOWNTO 0);
	
	--------- I2C Channel 1 ---------
	sda_ch1		: INOUT std_logic;
	scl_ch1		: INOUT std_logic
);
END TopEntity;


ARCHITECTURE rtl OF TopEntity IS 

COMPONENT alt_a10_temp_sense 
port
(
	clk 			: IN std_logic;
	degrees_c 	: OUT std_logic_vector(7 DOWNTO 0);
	degrees_f 	: OUT std_logic_vector(7 DOWNTO 0)
);
end COMPONENT;

COMPONENT SuperliteII_Demo 
GENERIC
	(
		NUMBER_OF_LANES	: integer := 4;	
		LANE_IDENTITY		: boolean := true; 	-- for backwards compatibility (false => backwards compatible with V3)
		SIMPLEX				: boolean := false; 	-- When enabled, does not perform any handshaking with remote side.			
		SIMULATION			: boolean := false	
	);
PORT(
	RefClock							: IN std_logic;
	MgmtClk							: IN std_logic;
	Enable_Core						: IN std_logic;
	XCVR_TX							: OUT STD_LOGIC_VECTOR ((NUMBER_OF_LANES - 1) DOWNTO 0);
	XCVR_RX							: IN STD_LOGIC_VECTOR ((NUMBER_OF_LANES - 1) DOWNTO 0);     
	Control_Reg						: IN std_logic_vector(15 DOWNTO 0);
	Control2_Reg					: IN std_logic_vector(15 DOWNTO 0);
	reconfig_reset          	: IN  std_logic; 
	reconfig_write          	: IN  std_logic; 
	reconfig_read           	: IN  std_logic; 
	reconfig_address        	: IN  std_logic_vector(15 DOWNTO 0)  := (OTHERS => '0'); 
	reconfig_writedata      	: IN  std_logic_vector(31 DOWNTO 0)  := (OTHERS => '0'); 
	reconfig_readdata       	: OUT std_logic_vector(31 DOWNTO 0);   
	reconfig_waitrequest    	: OUT  std_logic;
	reconfig_pll_reset      	: IN  std_logic; 
	reconfig_pll_write      	: IN  std_logic; 
	reconfig_pll_read       	: IN  std_logic; 
	reconfig_pll_address    	: IN  std_logic_vector(15 DOWNTO 0)  := (OTHERS => '0'); 
	reconfig_pll_writedata  	: IN  std_logic_vector(31 DOWNTO 0)  := (OTHERS => '0'); 
	reconfig_pll_readdata   	: OUT std_logic_vector(31 DOWNTO 0);   
	reconfig_pll_waitrequest	: OUT  std_logic;
	Channel_Reg						: OUT std_logic_vector(17 DOWNTO 0);
	Counter_1ms_Reg				: OUT std_logic_vector(31 DOWNTO 0);
	ErrorCount_Reg					: OUT std_logic_vector(15 DOWNTO 0);
	Bitrate_Reg						: OUT std_logic_vector(31 DOWNTO 0);
	DataClock_Reg					: OUT std_logic_vector(31 DOWNTO 0);
	DataOut_Clock_Reg				: OUT std_logic_vector(31 DOWNTO 0);
	Latency_Max_Reg				: OUT std_logic_vector(7 DOWNTO 0);
	Latency_Min_Reg				: OUT std_logic_vector(7 DOWNTO 0);	
	Delay_Reg						: OUT std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
	Delay_Reg_2						: OUT std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
	Lane_identifier				: buffer Bit8_ArrayType
	);
END COMPONENT;
	
COMPONENT controller is
	port (
		in_port_to_the_BitErrorCount_Reg             : IN  std_logic_vector(15 DOWNTO 0) := (OTHERS => 'X'); -- export
		in_port_to_the_Bitrate_Reg                   : IN  std_logic_vector(31 DOWNTO 0) := (OTHERS => 'X'); -- export
		in_port_to_the_Channel_Reg                   : IN  std_logic_vector(31 DOWNTO 0) := (OTHERS => 'X'); -- export
		OUT_port_from_the_Control2_Reg               : OUT std_logic_vector(15 DOWNTO 0);                    -- export
		OUT_port_from_the_Control_Reg                : OUT std_logic_vector(15 DOWNTO 0);                    -- export
		count_reset_reg_export                       : IN  std_logic_vector(31 DOWNTO 0) := (OTHERS => 'X'); -- export
		in_port_to_the_Counter_1ms_Reg               : IN  std_logic_vector(31 DOWNTO 0) := (OTHERS => 'X'); -- export
		dataclock_reg_export                         : IN  std_logic_vector(31 DOWNTO 0) := (OTHERS => 'X'); -- export
		dataOUT_clock_reg_export                     : IN  std_logic_vector(31 DOWNTO 0) := (OTHERS => 'X'); -- export
		delay_reg_export                             : IN  std_logic_vector(31 DOWNTO 0) := (OTHERS => 'X'); -- export
		delay_reg_2_export                           : IN  std_logic_vector(31 DOWNTO 0) := (OTHERS => 'X'); -- export
		lane_identifier_0_external_connection_export : IN  std_logic_vector(7 DOWNTO 0)  := (OTHERS => 'X'); -- export
		lane_identifier_1_external_connection_export : IN  std_logic_vector(7 DOWNTO 0)  := (OTHERS => 'X'); -- export
		lane_identifier_2_external_connection_export : IN  std_logic_vector(7 DOWNTO 0)  := (OTHERS => 'X'); -- export
		lane_identifier_3_external_connection_export : IN  std_logic_vector(7 DOWNTO 0)  := (OTHERS => 'X'); -- export
		latency_max_reg_export                       : IN  std_logic_vector(7 DOWNTO 0)  := (OTHERS => 'X'); -- export
		latency_min_reg_export                       : IN  std_logic_vector(7 DOWNTO 0)  := (OTHERS => 'X'); -- export
		temperature_reg_export                       : IN  std_logic_vector(7 DOWNTO 0)  := (OTHERS => 'X'); -- export
		version_external_connection_export           : IN  std_logic_vector(31 DOWNTO 0) := (OTHERS => 'X'); -- export
		clk                                          : IN  std_logic                     := 'X';             -- clk
		reset_n                                      : IN  std_logic                     := 'X';             -- reset_n
		s0_address_from_the_reconfig_mgmt            : OUT std_logic_vector(15 DOWNTO 0);                    -- address
		s0_read_from_the_reconfig_mgmt               : OUT std_logic;                                        -- read
		s0_readdata_to_the_reconfig_mgmt             : IN  std_logic_vector(31 DOWNTO 0) := (OTHERS => 'X'); -- readdata
		s0_write_from_the_reconfig_mgmt              : OUT std_logic;                                        -- write
		s0_writedata_from_the_reconfig_mgmt          : OUT std_logic_vector(31 DOWNTO 0);                    -- writedata
		s0_waitrequest_to_the_reconfig_mgmt          : IN  std_logic                     := 'X';             -- waitrequest
		reset_reset_from_the_reconfig_mgmt           : OUT std_logic;                                        -- reset
		reconfig_mgmt_pll_s0_address                 : OUT std_logic_vector(15 DOWNTO 0);                    -- address
		reconfig_mgmt_pll_s0_read                    : OUT std_logic;                                        -- read
		reconfig_mgmt_pll_s0_readdata                : IN  std_logic_vector(31 DOWNTO 0) := (OTHERS => 'X'); -- readdata
		reconfig_mgmt_pll_s0_write                   : OUT std_logic;                                        -- write
		reconfig_mgmt_pll_s0_writedata               : OUT std_logic_vector(31 DOWNTO 0);                    -- writedata
		reconfig_mgmt_pll_s0_waitrequest             : IN  std_logic                     := 'X';             -- waitrequest
		reconfig_mgmt_pll_reset_reset                : OUT std_logic;                                        -- reset
		i2c_0_i2c_serial_sda_in             			: IN  std_logic                     := 'X';             -- sda_in
		i2c_0_i2c_serial_scl_in             			: IN  std_logic                     := 'X';             -- scl_in
		i2c_0_i2c_serial_sda_oe             			: OUT std_logic;                                        -- sda_oe
		i2c_0_i2c_serial_scl_oe             			: OUT std_logic                                         -- scl_oe
	);
end COMPONENT controller;

SIGNAL BitErrorCount_Reg 			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL Bitrate_Reg 					: STD_LOGIC_VECTOR(31 DOWNTO 0);
  
SIGNAL Channel_Reg 					: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Clk100Mhz 						: STD_LOGIC;
SIGNAL Control2_Reg_CPU				: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL Control_Reg_CPU 				: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL Counter_1ms_Reg 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL DataClock_Reg					: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL DataOut_Clock_Reg 			: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Latency_Max_Reg 				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Latency_Min_Reg 				: STD_LOGIC_VECTOR(7 DOWNTO 0);
  
SIGNAL Delay_Reg 						: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Delay_Reg_2 					: STD_LOGIC_VECTOR(31 DOWNTO 0);			
  
SIGNAL reconfig_address				: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL reconfig_pll_address 		: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL reconfig_pll_read 			: STD_LOGIC;
SIGNAL reconfig_pll_readdata 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL reconfig_pll_reset 			: STD_LOGIC;
SIGNAL reconfig_pll_waitrequest 	: STD_LOGIC;
SIGNAL reconfig_pll_write 			: STD_LOGIC;
SIGNAL reconfig_pll_writedata		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL reconfig_read					: STD_LOGIC;
SIGNAL reconfig_readdata 			: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL reconfig_reset 				: STD_LOGIC;
SIGNAL reconfig_waitrequest 		: STD_LOGIC;
SIGNAL reconfig_write 				: STD_LOGIC;
SIGNAL reconfig_writedata 			: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL RefClock 						: STD_LOGIC;
SIGNAL Temperature 					: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Lane_identifier 				: Bit8_ArrayType;
 
SIGNAL scl_oe							: std_logic;
SIGNAL sda_oe							: std_logic;
SIGNAL scl_in							: std_logic;
SIGNAL sda_in							: std_logic;

BEGIN 

RefClock 	<= clk_y5;
Clk100Mhz 	<= clk_u59;

Channel_Reg(18) <= not modprsl;  -- QSFP cable plugged

leds(0) <= Channel_Reg(18);		-- QSFP cable plugged
leds(1) <= Channel_Reg(5);			-- Link up
leds(2) <= Channel_Reg(9);			-- Locked
leds(3) <= Channel_Reg(8);			-- PLL locked
leds(4) <= Channel_Reg(7);			-- Lane aligned
leds(5) <= Channel_Reg(0);			-- Word aligned
leds(6) <= Channel_Reg(6);			-- RX Freq locked
leds(7) <= Control2_Reg_CPU(4);	-- Selected bitrate
leds(8) <= Control2_Reg_CPU(5);	-- Selected bitrate

scl_ch1 <= '0' when scl_oe = '1' else 'Z';
sda_ch1 <= '0' when sda_oe = '1' else 'Z';
scl_in  <= scl_ch1;
sda_in  <= sda_ch1;	
		
----------------------------------------------------------------------------------------
-- Instantiate Superlite_Demo
----------------------------------------------------------------------------------------

Generate_Superlite_II_Instances:
FOR i IN 0 to (NUMBER_OF_LINKS-1) GENERATE
instx : SuperliteII_Demo
GENERIC MAP
	(
		NUMBER_OF_LANES			=> NUMBER_OF_LANES,	
		LANE_IDENTITY				=> LANE_IDENTITY,
		SIMPLEX						=> SIMPLEX,
		SIMULATION					=> SIMULATION
	)
PORT MAP(	
	RefClock 						=> RefClock,
	MgmtClk 							=> Clk100Mhz,
	Enable_Core 					=> '1',
	
	XCVR_RX 							=> qsfp_rx,
	XCVR_TX 							=> qsfp_tx,
			
	Control_Reg 					=> Control_Reg_CPU,
	Control2_Reg 					=> Control2_Reg_CPU,
	
	reconfig_reset 				=> reconfig_reset,
	reconfig_write 				=> reconfig_write,
	reconfig_writedata 			=> reconfig_writedata,		 
	reconfig_read 					=> reconfig_read,
	reconfig_readdata 			=> reconfig_readdata,		 
	reconfig_address 				=> reconfig_address,
	reconfig_waitrequest 		=> reconfig_waitrequest,
		
	reconfig_pll_reset 			=> reconfig_pll_reset,
	reconfig_pll_write 			=> reconfig_pll_write,
	reconfig_pll_writedata 		=> reconfig_pll_writedata,		 
	reconfig_pll_read 			=> reconfig_pll_read,	
	reconfig_pll_readdata 		=> reconfig_pll_readdata,		 
	reconfig_pll_address 		=> reconfig_pll_address,
	reconfig_pll_waitrequest 	=> reconfig_pll_waitrequest,
	
	Bitrate_Reg 					=> Bitrate_Reg,
	Channel_Reg 					=> Channel_Reg(17 DOWNTO 0),
	Counter_1ms_Reg 				=> Counter_1ms_Reg,
	DataClock_Reg 					=> DataClock_Reg,
	DataOut_Clock_Reg				=> DataOut_Clock_Reg,
	ErrorCount_Reg 				=> BitErrorCount_Reg,
	Latency_Max_Reg 				=> Latency_Max_Reg,	 
	Latency_Min_Reg 				=> Latency_Min_Reg,
	Delay_Reg						=> Delay_Reg,
	Delay_Reg_2						=> Delay_Reg_2,
	Lane_identifier				=> Lane_identifier
);

end generate;

----------------------------------------------------------------------------------------
-- Instantiate Qsys system with Nios II
----------------------------------------------------------------------------------------


controller_inst : COMPONENT controller
port map (
	in_port_to_the_BitErrorCount_Reg    				=> BitErrorCount_Reg,    		-- 	biterrorcount_reg.export
	in_port_to_the_Bitrate_Reg          				=> Bitrate_Reg,          		-- 	      bitrate_reg.export
	in_port_to_the_Channel_Reg          				=> Channel_Reg,          		-- 	      channel_reg.export
	clk                                 				=> Clk100Mhz,            		-- 	       clk_clk_in.clk
	reset_n                             				=> '1',                  		-- 	 clk_clk_in_reset.reset_n
	OUT_port_from_the_Control2_Reg      				=> Control2_Reg_CPU,     		-- 	     control2_reg.export
	OUT_port_from_the_Control_Reg       				=> Control_Reg_CPU,      		-- 	      control_reg.export
	in_port_to_the_Counter_1ms_Reg      				=> Counter_1ms_Reg,      		-- 	  counter_1ms_reg.export
	dataclock_reg_export                				=> DataClock_Reg,        		-- 	    dataclock_reg.export
	dataOUT_clock_reg_export            				=> DataOut_Clock_Reg,    		-- 	dataOUT_clock_reg.export
	delay_reg_export                    				=> Delay_Reg,
	delay_reg_2_export                  				=> Delay_Reg_2,

	lane_identifier_0_external_connection_export    => Lane_identifier(0),
	lane_identifier_1_external_connection_export  	=> Lane_identifier(1),
	lane_identifier_2_external_connection_export    => Lane_identifier(2),
	lane_identifier_3_external_connection_export    => Lane_identifier(3),

	latency_max_reg_export              				=> Latency_Max_Reg,
	latency_min_reg_export              				=> Latency_Min_Reg,			
	reset_reset_from_the_reconfig_mgmt  				=> reconfig_reset,				--    reconfig_mgmt_reset.reset			
	s0_address_from_the_reconfig_mgmt   				=> reconfig_address,   			--        reconfig_mgmt_0.address
	s0_read_from_the_reconfig_mgmt      				=> reconfig_read,      			--                       .read
	s0_readdata_to_the_reconfig_mgmt    				=> reconfig_readdata,    		--                       .readdata
	s0_write_from_the_reconfig_mgmt     				=> reconfig_write,     			--                       .write
	s0_writedata_from_the_reconfig_mgmt 				=> reconfig_writedata, 			--                       .writedata
	s0_waitrequest_to_the_reconfig_mgmt 				=> reconfig_waitrequest, 		--                       .waitrequest
	reconfig_mgmt_pll_reset_reset        				=> reconfig_pll_reset,			-- 	reconfig_mgmt_pll_reset.reset
	reconfig_mgmt_pll_s0_address         				=> reconfig_pll_address,		--    reconfig_mgmt_pll_s0.address
	reconfig_mgmt_pll_s0_read            				=> reconfig_pll_read,			--                       .read
	reconfig_mgmt_pll_s0_readdata        				=> reconfig_pll_readdata,		--                       .readdata
	reconfig_mgmt_pll_s0_write           				=> reconfig_pll_write,			--                       .write
	reconfig_mgmt_pll_s0_writedata       				=> reconfig_pll_writedata,		--                       .writedata
	reconfig_mgmt_pll_s0_waitrequest     				=> reconfig_pll_waitrequest,	--                       .waitrequest
	temperature_reg_export              				=> Temperature,               --		temperature_reg.export
 	version_external_connection_export					=> VERSION,
	i2c_0_i2c_serial_sda_in             				=> sda_in,             			--		i2c_0_i2c_serial.sda_in
	i2c_0_i2c_serial_scl_in             				=> scl_in,             			--							 .scl_in
	i2c_0_i2c_serial_sda_oe             				=> sda_oe,             			--							 .sda_oe
	i2c_0_i2c_serial_scl_oe             				=> scl_oe            			--							 .scl_oe
);

-----------------------------------------------------------------------------------------------------------
--	Instantiate Temperature sensing for Arria 10
-----------------------------------------------------------------------------------------------------------	


alt_a10_temp_sense_inst : alt_a10_temp_sense
port map
(
	clk 			=> Clk100Mhz,
	degrees_c 	=> Temperature,
	degrees_f   => open
);


END rtl;
