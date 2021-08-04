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

entity CountGenerate is
PORT(
	coreclk  	: in std_logic;
	Enable	: in std_logic;
	StartValue : in std_logic_vector(15 downto 0);	
	Reset	 	: in std_logic;
	Inserterror : in std_logic;
	Counterout 	: out std_logic_vector(15 downto 0);
	Valid			: out std_logic
	);
END CountGenerate;	


architecture rtl of CountGenerate is


signal Counter 			: std_logic_vector(15 downto 0);
signal tx_data 			: std_logic_vector(15 downto 0);
signal detect_inserterror	: std_logic;
signal inserterror_Q	: std_logic;
signal delayed_error    : std_logic;
signal inserterror_Q1	: std_logic;
signal inserterror_Q2	: std_logic;
signal inserterror_Q3	: std_logic;

signal CountPattern 	: std_logic_vector(15 downto 0);


begin
	

	process(coreclk,Reset)
	begin
		if (Reset = '1') then
			tx_data <=  X"0707";
			CountPattern <= StartValue;
			delayed_error <= '0';
			inserterror_q1 <= '0';
			inserterror_q2 <= '0';
			inserterror_q3 <= '0';
			Valid <= '0';
		elsif rising_edge(coreclk) then
				inserterror_q1 <= inserterror;
				inserterror_q2 <= inserterror_q1;
				inserterror_q3 <= inserterror_q2;
					if (inserterror_q3 /= inserterror_q2) and (inserterror_q2 = '1') then
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
						tx_data <= CountPattern(15 downto 1) & (not CountPattern(0)); -- One biterror										
					else
						tx_data <= CountPattern;
					end if;
					Valid <= '1';
				else
					if detect_inserterror = '1' then
						delayed_error <= '1';
					end if;				
					Valid <= '0';
				end if;
		end if;
	end process;
	
	
Counterout <= tx_data;
		
			
end;



