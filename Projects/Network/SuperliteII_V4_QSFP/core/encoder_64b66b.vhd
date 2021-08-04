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

entity Encoder_64b66b is
PORT(
	Clk  			: in std_logic;
	Enable			: in std_logic;
	Reset	 		: in std_logic;
	kin				: in std_logic_vector(7 downto 0);
	din				: in std_logic_vector(63 downto 0);
	dout	 		: out std_logic_vector(65 downto 0);	
	dout_valid 		: out std_logic;
	encoder_error	: out std_logic
	);
END Encoder_64b66b;	


-- upper 2 bits are for framing 
-- bit[65:64] : "01" => data
--				"10" => control
--				"00" => not valid (used to detect framing)

architecture rtl of Encoder_64b66b is


signal tx_data 				: std_logic_vector(65 downto 0);
signal CountPattern 			: std_logic_vector(63 downto 0);
signal Enable_scrambler		: std_logic;


begin


-----------------------------------------------------------------------------------------------------------
-- Combinatorial
-----------------------------------------------------------------------------------------------------------	
	
tx_data 		<= ("01" & din) when (kin = X"00" and Enable = '1') else ("10" & din) when (kin = X"FF" and Enable = '1') else (others => '0');
dout_valid 	<= '1' when Enable = '1' else '0';
dout 			<= tx_data;

			
end;
