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

entity Synchro is
port
	(
	Clk			: in std_logic;
	data_in		: in std_logic;
	data_out		: out std_logic
	);
end;


architecture rtl of Synchro is

signal Synchro_reg : std_logic_vector(2 downto 0) := (OTHERS => '0');

begin

process(Clk)
begin
if rising_edge(Clk) then
		Synchro_reg		<= Synchro_Reg(1 downto 0) & (data_in);
		data_out			<= Synchro_Reg(2);
end if;
end process;

end;
