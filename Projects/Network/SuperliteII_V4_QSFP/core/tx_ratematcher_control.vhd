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
-- This reference design file is being provided on an "as-is basis" and as an
-- accommodation and therefore all warranties, representations or guarantees of
-- any kind (whether express, implied or statutory) including, without
-- limitation, warranties of merchantability, non-infringement, or fitness for
-- a particular purpose, are specifically disclaimed.  By making this reference
-- design file available, Altera expressly does not recommend, suggest or
-- require that this reference design file be used in combination with any
-- other product not provided by Altera.
----------------------------------------------------------------------------------------------------
-- File          : Tx_Ratematcher_Control.vhd
-- Author		 : Peter Schepers
----------------------------------------------------------------------------------------------------
--
-- SuperLite Tx Module : 	- Contains the control logic to control the ratematcher.
--							- Instantiates the Tx_Ratematcher FIFO (32 words deep, single clocked FIFO version)
----------------------------------------------------------------------------------------------------

-- Lane Alignment coding
-- B7				B6					         B5		B4		B3		B2 	B1						B0
-- Lane Ident	Latency Count Tx			7C		7C		7C		7C		FD or 5C or 7C		7C

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
 
entity Tx_Ratematcher_Control is
GENERIC
	(
		READ_LENGTH_SIM	 	: std_logic_vector(15 downto 0) := X"0100"; -- Every 256 clock cycles insert idle (this is the values used for simulation purposes).
		READ_LENGTH			 	: std_logic_vector(15 downto 0) := X"0400"; -- Every 1024 clock cycles insert idle (note this value can be increased to increase efficiency).
		IDLE_LENGTH				: std_logic_vector(3 downto 0)  := X"7";	
		NUMBER_OF_LANES		: integer := 4;	  									-- Number of lanes
		LANEWIDTH				: integer := 64;										-- LANEWIDTH for transceiver	
		LANE_IDENTITY			: boolean := true;	
		SIMULATION				: boolean := false
		
	);
PORT(
	data_in								: in std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);
	data_in_valid						: in std_logic;			 
	data_in_ready						: out std_logic;			-- signal out going down once every READ_LENGTH cycles for IDLE_LENGTH period.
	clk									: in std_logic;													
	Reset									: in std_logic;			-- Synchronous Reset				
	LaneAligned							: in std_logic; 			-- LaneAligned status 
	XOFF									: in std_logic; 			-- XOFF input to sent out XOFF to the remote device for the remote to stop sending traffic (100 Mhz Clock domain)	
	Stop_Traffic						: in std_logic;			-- Used to stop sending traffic locally (when XOFF is received from remote side) (clocked by clk (coreclk))
	Tx_Data								: out std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);
	Tx_Data_Valid						: out std_logic;			-- Always Enabled in this case (as it is /66)	
	Tx_Ctrlenable						: out std_logic_vector(((NUMBER_OF_LANES * (LANEWIDTH/8))-1) downto 0);
	full_Tx_Ratematcher				: out std_logic;
	empty_Tx_Ratematcher				: out std_logic;
	almost_empty_Tx_Ratematcher	: buffer std_logic;
	almost_full_Tx_Ratematcher		: out std_logic;
	usedw_Tx_Ratematcher				: out std_logic_vector(2 downto 0);
	Latency_Count_Tx					: in std_logic_vector(7 downto 0)  -- Used to measure latency (synchronous to clk)
	);
END Tx_Ratematcher_Control;	

architecture rtl of Tx_Ratematcher_Control is

component tx_ratematcher is
	port (
		data         : in  std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);
		wrreq        : in  std_logic                      := 'X';             -- wrreq
		rdreq        : in  std_logic                      := 'X';             -- rdreq
		clock        : in  std_logic                      := 'X';             -- clk
		sclr         : in  std_logic                      := 'X';             -- sclr
		q            : out std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);
		usedw        : out std_logic_vector(2 downto 0);                      -- usedw
		full         : out std_logic;                                         -- full
		empty        : out std_logic;                                         -- empty
		almost_full  : out std_logic;                                         -- almost_full
		almost_empty : out std_logic                                          -- almost_empty
	);
end component tx_ratematcher;

component Synchro is
port
	(
	Clk			: in std_logic;
	data_in		: in std_logic;
	data_out		: out std_logic
	);
END component;	
	

signal Tx_Valid					:  std_logic;	

type   TxState	 is (Tx_ResetFifo,Train_Data,Train_Control,Train_Align,WriteOnly,ReadAndWrite,ReadOnly,Stop_Sending_Data);
signal Tx_FifoState	: TxState;

type 	Bit8_ArrayType	is array (0 to (NUMBER_OF_LANES - 1)) of std_logic_vector (7 downto 0);


signal Ready_Tx_Ratematcher	: std_logic;
signal data_in_ready_min1   	: std_logic;
signal data_in_ready_min2   	: std_logic;

signal Reset_tx_Ratematcher		: std_logic;
signal RdEna_Tx_Ratematcher 		: std_logic;
signal wrfull 							: std_logic;
signal data_out 						: std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);

signal IdleLength	 					: std_logic_vector(3 downto 0);
signal ReadLength						: std_logic_vector(15 downto 0);
signal DataCounter					: std_logic_vector(3 downto 0);
signal IdleCounter					: std_logic_vector(2 downto 0);

signal XOFF_clk						: std_logic;
signal Stop_Traffic_clk				: std_logic;
signal LaneAligned_clk				: std_logic;
signal count							: std_logic_vector(4 downto 0);
signal pulse_pause_data				: std_logic;
signal count_pause_data				: std_logic_vector(15 downto 0);
signal RdEna_Tx_Ratematcher_i		: std_logic;
signal Tx_Data_Valid_min1			: std_logic;
signal Lane_identifier				: Bit8_ArrayType;

begin

-----------------------------------------------------------------------------------------------------------
--	Synchronize input signals from other clock domain to clk domain 
-----------------------------------------------------------------------------------------------------------	

Syncho_inst1 : Synchro
PORT MAP
(
	Clk			=> clk,
	data_in		=> XOFF,				-- Generated on Management clock
	data_out		=> XOFF_clk	
);

Syncho_inst2 : Synchro
PORT MAP
(
	Clk			=> clk,
	data_in		=> Stop_Traffic, -- Generated on recovered clock domain
	data_out		=> Stop_Traffic_clk
);

Syncho_inst3 : Synchro
PORT MAP
(
	Clk			=> clk,
	data_in		=> LaneAligned, 	-- Generated on recovered clock domain.
	data_out		=> LaneAligned_clk
);


-----------------------------------------------------------------------------------------------------------
--	Instantiate Tx_Ratematcher
-----------------------------------------------------------------------------------------------------------	

Tx_Ratematcher_inst : Tx_Ratematcher PORT MAP (
		data	 			=> data_in,
		wrreq	 			=> data_in_valid,
		rdreq	 			=> RdEna_Tx_Ratematcher,
		clock	 			=> clk,
		sclr	 			=> Reset, 
		q	 	 			=> data_out,
		usedw				=> usedw_Tx_Ratematcher,		
		empty	 			=> empty_Tx_Ratematcher ,
		full	 			=> full_TX_Ratematcher, 
		almost_full		=> almost_full_Tx_Ratematcher,
		almost_empty	=> almost_empty_Tx_Ratematcher
	);

	
-----------------------------------------------------------------------------------------------------------
-- Generate pause_data pulse that goes low every READ_LENGTH clock cycles for a period of IDLE clocks.
-----------------------------------------------------------------------------------------------------------	
	
	process (clk)
	begin
		if clk'event and clk = '1' then
			if Reset = '1' then
				count_pause_data <= (OTHERS => '0');
				pulse_pause_data <= '0';
				data_in_ready <= '0';
				RdEna_Tx_Ratematcher <= '0';
			else

			if (SIMULATION = true ) then 
				if (count_pause_data = READ_LENGTH_SIM-1) then
					count_pause_data <= (OTHERS => '0');
					pulse_pause_data <= '0';
				elsif (count_pause_data < IDLE_LENGTH-1) then 
					pulse_pause_data <= '0';
					count_pause_data <= count_pause_data + 1;
				else
					pulse_pause_data <= '1';
					count_pause_data <= count_pause_data + 1;	
			   end if;
				
				-- Generate data_in_ready pulse and RdEna_Tx_Ratematcher (must be the same as it is a SC fifo, no ratematching done (despite the name)
				data_in_ready <= pulse_pause_data and not(Stop_Traffic_clk);
				if almost_empty_Tx_Ratematcher = '0' then 
					RdEna_Tx_Ratematcher <= pulse_pause_data and not (Stop_Traffic_clk);
				else
					RdEna_Tx_Ratematcher <= '0';
					-- At this point idle characters need to be generated.
				end if;
			else
				if (count_pause_data = READ_LENGTH-1) then
					count_pause_data <= (OTHERS => '0');
					pulse_pause_data <= '0';
				elsif (count_pause_data < IDLE_LENGTH-1) then 
					pulse_pause_data <= '0';
					count_pause_data <= count_pause_data + 1;
				else
					pulse_pause_data <= '1';
					count_pause_data <= count_pause_data + 1;	
			   end if;
				
				-- Generate data_in_ready pulse and RdEna_Tx_Ratematcher (must be the same as it is a SC fifo, no ratematching done (despite the name)
				data_in_ready <= pulse_pause_data and not(Stop_Traffic_clk);
				if almost_empty_Tx_Ratematcher = '0' then 
					RdEna_Tx_Ratematcher <= pulse_pause_data and not (Stop_Traffic_clk);	
				else
					RdEna_Tx_Ratematcher <= '0';
					-- At this point idle characters need to be generated.
				end if;
			end if;	
				
		end if;
	 end if;
	end process;


	process (clk)
	begin
		if clk'event and clk = '1' then
			if Reset = '1' then
				Ready_Tx_Ratematcher 	<= '0';
				Tx_Valid			 	 		<= '0';
				Tx_CtrlEnable		 		<= (OTHERS => '1');
				Tx_Data_Valid_min1		<= '0';
				Tx_Data_Valid				<= '0';
				FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
					Tx_Data((LANEWIDTH*(I+1)-1) downto (LANEWIDTH*I)) <= X"AAAAAAAAAAAAAAAA"; --Idle
				END LOOP;	
			else	
						FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP	
							if (LANE_IDENTITY) then 
								Lane_identifier(I) <= conv_std_logic_vector(i, 8);
							else
								Lane_identifier(I) <= X"7C"; -- this is for backwards compatibility 
							end if;
						END LOOP;

				Tx_Data_Valid_min1 <= '1'; 
				Tx_Data_Valid <= Tx_Data_Valid_min1;
								
					if ((count_pause_data > 0) and  (count_pause_data < IDLE_LENGTH)) then --2 clock cycles later than the generation of pulse_pause_data	
						FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
							Tx_Data((LANEWIDTH*(I+1)-1) downto (LANEWIDTH*I)) <= X"1C1C1C1C1C1C1CBC"; -- K28.5 contained in lowest byte
						END LOOP;
						Tx_CtrlEnable <= (OTHERS => '1');
					elsif count_pause_data = IDLE_LENGTH then --2 clock cycles later than the generation of pulse_pause_data
						if (LaneAligned_clk = '1' and XOFF_clk = '0') then
								FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
									Tx_Data((LANEWIDTH*(I+1)-1) downto (LANEWIDTH*I)) <= Lane_identifier(I) & Latency_Count_Tx & X"7C7C7C7CFD7C"; -- Alignment character with LaneAligned achieved no XOFF -- K29.7/K28.3
								END LOOP;
								Tx_CtrlEnable <= (OTHERS => '1');
						elsif (LaneAligned_clk = '1' and XOFF_clk = '1') then
								FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
									Tx_Data((LANEWIDTH*(I+1)-1) downto (LANEWIDTH*I)) <= Lane_identifier(I) & Latency_Count_Tx & X"7C7C7C7C5C7C"; -- Alignment character with LaneAligned achieved and XOFF active - K28.2/K28.3
								END LOOP;
								Tx_CtrlEnable <= (OTHERS => '1');
						else
								FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
									Tx_Data((LANEWIDTH*(I+1)-1) downto (LANEWIDTH*I)) <= Lane_identifier(I) & Latency_Count_Tx & X"7C7C7C7C7C7C"; -- Alignment character
								END LOOP;
								Tx_CtrlEnable <= (OTHERS => '1');
						end if;						

					else 
						if RdEna_Tx_Ratematcher = '0' then -- change invalid data to idle characters.
							FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
								Tx_Data((LANEWIDTH*(I+1)-1) downto (LANEWIDTH*I)) <= X"AAAAAAAAAAAAAAAA"; -- Used as idle character to make it distinctive from 1CBC
							END LOOP;
							Tx_CtrlEnable <= (OTHERS => '1');
						 else
							Tx_Data <= data_out;
							Tx_CtrlEnable <= (OTHERS => '0');
						end if;
					end if;

			end if;
		end if;
 end process;
					
end;
