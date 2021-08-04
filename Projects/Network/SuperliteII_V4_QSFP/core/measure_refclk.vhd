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

entity measure_refclk is
GENERIC
	(
		CYC_MEASURE_CLK_IN_1_SEC	: std_logic_vector(31 downto 0) :=	X"02FAF080"  -- (50 Mhz clock is 50E6 samples in one second)
	);
port
	(
	RefClock				: in	std_logic;
	Enable				: in std_logic;
	Measure_Clk				: in 	std_logic;
	reset					: in	std_logic;
	Valid					: out 	std_logic;					 -- Synchronized to Measure_Clk
	RefClock_Measure		: out  std_logic_vector(31 downto 0) -- Synchronized to Measure_Clk
	);
end;

architecture rtl of measure_refclk is

component Reset_Synchro is
port
	(
	Clk			: in std_logic;
	Reset_in	: in std_logic;
	Reset_out	: out std_logic
	);
end component;


signal count_Measure_Clk	:std_logic_vector(33 downto 0);
signal count_RefClock		:std_logic_vector(31 downto 0);
signal Refclock_Measure_min2		:std_logic_vector(31 downto 0);
signal Refclock_Measure_min1		:std_logic_vector(31 downto 0);
signal Gate					:std_logic;
signal Gate_min2			:std_logic;
signal Gate_min1			:std_logic;
signal Gate_min0			:std_logic;
signal Latch				:std_logic;
signal Latch_min2			:std_logic;
signal Latch_min1			:std_logic;
signal Latch_min0			:std_logic;
signal reset_RefClock	:std_logic;

begin

	process(Measure_Clk,reset)
	begin
		if reset = '1' then
			count_Measure_Clk 		<= (OTHERS => '0');
			Gate 							<= '0';
			RefClock_Measure_min2 	<= (OTHERS => '0');
			RefClock_Measure_min1	<= (OTHERS => '0');
			RefClock_Measure 			<= (OTHERS => '0');
			Valid							<= '0';
			Latch							<= '0';
		elsif rising_edge(Measure_Clk) then
			if count_Measure_Clk = (CYC_MEASURE_CLK_IN_1_SEC-2) then
				Latch <= '1';
				count_Measure_Clk <= count_Measure_Clk + 1;
			elsif count_Measure_Clk = (CYC_MEASURE_CLK_IN_1_SEC-1) then
				count_Measure_Clk <= (OTHERS => '0');
				Gate <= not Gate;
				Latch <= '0';
			else
				count_Measure_Clk <= count_Measure_Clk + 1;
				Latch <= '0';
			end if;
			if (Latch = '1') and (Gate = '1') then
				Valid <= '1';
				Refclock_Measure_min2 <= count_RefClock;
				RefClock_Measure_min1 <= RefClock_Measure_min2;
				RefClock_Measure	  <= RefClock_Measure_min1;
			else
				Valid <= '0';
			end if;
		end if;
	end process;


Reset_Synchro_inst :  Reset_Synchro
port map
	(
	Clk			=> RefClock,
	Reset_in		=> reset,
	Reset_out	=> reset_RefClock
	);


	process(RefClock,reset_RefClock)
	begin
		if reset_RefClock = '1' then
			count_RefClock 		<= (OTHERS => '0');
			Gate_min2			<= '0';
			Gate_min1			<= '0';
			Gate_min0			<= '0';

		elsif rising_edge(RefClock) then
			Gate_min2 <= Gate;
			Gate_min1 <= Gate_min2;
			Gate_min0 <= Gate_min1;
			if (Enable = '1') then
				if (Gate_min0 = '1') then
					count_RefClock <= count_RefClock + 1;
				else
					count_RefClock <= (OTHERS => '0');
				end if;
			end if;

		end if;
	end process;

end;
