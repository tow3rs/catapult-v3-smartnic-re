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

entity PrbsGenerate_60bit is
PORT(
	coreclk  	: in std_logic;
	Enable		: in std_logic;
	StartValue	: in std_logic_vector(59 downto 0);
	Reset	 		: in std_logic;
	Inserterror : in std_logic;
	Prbsout 		: out std_logic_vector(59 downto 0);
	Valid			: out std_logic
	);
END PrbsGenerate_60bit;	


architecture rtl of PrbsGenerate_60bit is


signal prbs 					: std_logic_vector(59 downto 0);
signal tx_data 				: std_logic_vector(59 downto 0);
signal tx_data_sig 			: std_logic_vector(59 downto 0);
signal detect_inserterror	: std_logic;
signal delayed_error    	: std_logic;
signal inserterror_Q			: std_logic;
signal Reset_Q					: std_logic;
signal Reset_CoreClk			: std_logic;
signal CountPattern 			: std_logic_vector(59 downto 0);


begin
	

-----------------------------------------------------------------------------------------------------------
-- PRBS 2^23-1 (parallel 60bit serializer) 
-----------------------------------------------------------------------------------------------------------	

	process(coreclk,Reset)
	begin
		if (Reset = '1') then
				prbs <= StartValue;
		elsif rising_edge(coreclk) then	
				if Enable = '1' then
					prbs(0) <= prbs(4) XOR prbs(9) XOR prbs(12) XOR prbs(22) ;
					prbs(1) <= prbs(0) XOR prbs(5) XOR prbs(10) XOR prbs(13) XOR prbs(18) ;
					prbs(2) <= prbs(1) XOR prbs(6) XOR prbs(11) XOR prbs(14) XOR prbs(19) ;
					prbs(3) <= prbs(2) XOR prbs(7) XOR prbs(12) XOR prbs(15) XOR prbs(20) ;
					prbs(4) <= prbs(3) XOR prbs(8) XOR prbs(13) XOR prbs(16) XOR prbs(21) ;
					prbs(5) <= prbs(4) XOR prbs(9) XOR prbs(14) XOR prbs(17) XOR prbs(22) ;
					prbs(6) <= prbs(0) XOR prbs(5) XOR prbs(10) XOR prbs(15) ;
					prbs(7) <= prbs(1) XOR prbs(6) XOR prbs(11) XOR prbs(16) ;
					prbs(8) <= prbs(2) XOR prbs(7) XOR prbs(12) XOR prbs(17) ;
					prbs(9) <= prbs(3) XOR prbs(8) XOR prbs(13) XOR prbs(18) ;
					prbs(10) <= prbs(4) XOR prbs(9) XOR prbs(14) XOR prbs(19) ;
					prbs(11) <= prbs(5) XOR prbs(10) XOR prbs(15) XOR prbs(20) ;
					prbs(12) <= prbs(6) XOR prbs(11) XOR prbs(16) XOR prbs(21) ;
					prbs(13) <= prbs(7) XOR prbs(12) XOR prbs(17) XOR prbs(22) ;
					prbs(14) <= prbs(0) XOR prbs(8) XOR prbs(13) ;
					prbs(15) <= prbs(1) XOR prbs(9) XOR prbs(14) ;
					prbs(16) <= prbs(2) XOR prbs(10) XOR prbs(15) ;
					prbs(17) <= prbs(3) XOR prbs(11) XOR prbs(16) ;
					prbs(18) <= prbs(4) XOR prbs(12) XOR prbs(17) ;
					prbs(19) <= prbs(5) XOR prbs(13) XOR prbs(18) ;
					prbs(20) <= prbs(6) XOR prbs(14) XOR prbs(19) ;
					prbs(21) <= prbs(7) XOR prbs(15) XOR prbs(20) ;
					prbs(22) <= prbs(8) XOR prbs(16) XOR prbs(21) ;
					prbs(23) <= prbs(9) XOR prbs(17) XOR prbs(22) ;
					prbs(24) <= prbs(0) XOR prbs(10) ;
					prbs(25) <= prbs(1) XOR prbs(11) ;
					prbs(26) <= prbs(2) XOR prbs(12) ;
					prbs(27) <= prbs(3) XOR prbs(13) ;
					prbs(28) <= prbs(4) XOR prbs(14) ;
					prbs(29) <= prbs(5) XOR prbs(15) ;
					prbs(30) <= prbs(6) XOR prbs(16) ;
					prbs(31) <= prbs(7) XOR prbs(17) ;
					prbs(32) <= prbs(8) XOR prbs(18) ;
					prbs(33) <= prbs(9) XOR prbs(19) ;
					prbs(34) <= prbs(10) XOR prbs(20) ;
					prbs(35) <= prbs(11) XOR prbs(21) ;
					prbs(36) <= prbs(12) XOR prbs(22) ;
					prbs(37) <= prbs(0) XOR prbs(13) XOR prbs(18) ;
					prbs(38) <= prbs(1) XOR prbs(14) XOR prbs(19) ;
					prbs(39) <= prbs(2) XOR prbs(15) XOR prbs(20) ;
					prbs(40) <= prbs(3) XOR prbs(16) XOR prbs(21) ;
					prbs(41) <= prbs(4) XOR prbs(17) XOR prbs(22) ;
					prbs(42) <= prbs(0) XOR prbs(5) ;
					prbs(43) <= prbs(1) XOR prbs(6) ;
					prbs(44) <= prbs(2) XOR prbs(7) ;
					prbs(45) <= prbs(3) XOR prbs(8) ;
					prbs(46) <= prbs(4) XOR prbs(9) ;
					prbs(47) <= prbs(5) XOR prbs(10) ;
					prbs(48) <= prbs(6) XOR prbs(11) ;
					prbs(49) <= prbs(7) XOR prbs(12) ;
					prbs(50) <= prbs(8) XOR prbs(13) ;
					prbs(51) <= prbs(9) XOR prbs(14) ;
					prbs(52) <= prbs(10) XOR prbs(15) ;
					prbs(53) <= prbs(11) XOR prbs(16) ;
					prbs(54) <= prbs(12) XOR prbs(17) ;
					prbs(55) <= prbs(13) XOR prbs(18) ;
					prbs(56) <= prbs(14) XOR prbs(19) ;
					prbs(57) <= prbs(15) XOR prbs(20) ;
					prbs(58) <= prbs(16) XOR prbs(21) ;
					prbs(59) <= prbs(17) XOR prbs(22) ;

				end if;
		end if;
	end process;

	process(coreclk,Reset)
	begin
		if (Reset = '1') then
				tx_data <= X"070707070707070";
				CountPattern <= (OTHERS => '0');	
				Valid <= '0';
				detect_inserterror <= '0';
				delayed_error <= '0';
				inserterror_q <= '0';
		elsif rising_edge(coreclk) then
					inserterror_q <= inserterror;
					if (inserterror_q /= inserterror) and (inserterror = '1') then
						detect_inserterror <= '1';
					else
						detect_inserterror <= '0';
					end if;
					
				if Enable = '1' then 
					CountPattern <= CountPattern + 1;

					if delayed_error = '1' then
						delayed_error <= '0';
					end if;					

					if detect_inserterror = '1' or delayed_error = '1' then 
						report "==========================================================================================================> Inserted one bit error in Tx data ..." severity note;																																	
						tx_data <= (not prbs(59)) & prbs(58 downto 0);			-- insert One biterror
					else
						tx_data <= prbs;
					end if;
					Valid <= '1';
				else
					if detect_inserterror = '1' then
						delayed_error <= '1';
					end if;					
					tx_data <= X"070707070707070";
					Valid <= '0';
				end if;
		end if;
	end process;	
	
Prbsout <= tx_data;		
			
end;


