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

entity Decoder_66b64b is
PORT(
	Clk  			: in std_logic;
	Enable			: in std_logic;
	Reset	 		: in std_logic;
	din				: in std_logic_vector(65 downto 0);
	rx_enh_blk_lock : in std_logic;
	dout	 		: out std_logic_vector(63 downto 0);
	kout			: out std_logic_vector(7 downto 0);	
	valid 			: out std_logic;
	Aligned			: out std_logic	
	);
END Decoder_66b64b;	


-- upper 2 bits are for framing 
-- bit[65:64] : "01" => data
--				"10" => control
--				"00" => not valid (used to detect framing)

architecture rtl of Decoder_66b64b is

CONSTANT TRESSHOLD_ALIGMENT_DEASSERT 	: unsigned(3 downto 0) := X"3";
CONSTANT LATENCY 						: unsigned(4 downto 0) := "10010";

signal count_Frame_OK 			: unsigned(5 downto 0);		
signal count_Frame_NotOK		: unsigned(5 downto 0);
signal slipcounter				: unsigned(6 downto 0);
signal Align					: std_logic;
signal Bitslip_i				: std_logic;
signal Bitslip_Qmin2				: std_logic;
signal Bitslip_Qmin1				: std_logic;
signal AlignChanged				: std_logic_vector(6 downto 0);

signal dout_min1					: std_logic_vector(63 downto 0);
signal kout_min1					: std_logic_vector(7 downto 0);
signal din_q						: std_logic_vector(65 downto 0);
signal Reset_q						: std_logic;

begin
	

-----------------------------------------------------------------------------------------------------------
--	Align on valid 64/66 frame
-----------------------------------------------------------------------------------------------------------	

	process(Clk)
	begin

	if rising_edge(Clk) then
		
		if (Reset = '1') then
				Align 				<= '0';
		else		

			if Enable = '1' then
	
	
				if rx_enh_blk_lock = '1' then
					Align <= '1';
					
					assert(Align = '1')
					report "==========================================================================================================> Lane Aligned ..." 		severity note;

				else				
					Align <= '0';
				end if;
							

			end if;
			
		end if;
	end if;
	end process;
	
Aligned <= Align;


-----------------------------------------------------------------------------------------------------------
--	Generate dout and kout (combinatorial)
-----------------------------------------------------------------------------------------------------------	

valid <= Enable;
dout(63 downto 0) <= din(63 downto 0);
kout <= X"FF" when (din(65 downto 64) = "10") else X"00";

			
end;
