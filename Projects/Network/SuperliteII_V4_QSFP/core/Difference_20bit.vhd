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

entity Difference_20bit is
PORT(
	InputA 				: in std_logic_vector(19 downto 0);
	InputB	 			: in std_logic_vector(19 downto 0);
	Clock				: in std_logic;
	Reset				: in std_logic;
	Enable				: in std_logic;
	Difference			: out std_logic_vector(4 downto 0)
	);
END Difference_20bit;		


architecture rtl of Difference_20bit is


signal Difference1				: std_logic_vector(4 downto 0);
signal Difference2				: std_logic_vector(4 downto 0);
signal Difference3				: std_logic_vector(4 downto 0);
signal Difference4				: std_logic_vector(4 downto 0);

begin
	
Process(Clock,Reset)
variable K,L,M,N,P: std_logic_vector(4 downto 0);
Begin
	if (Reset = '1') then
			Difference1 <= (OTHERS => '0');
			Difference2 <= (OTHERS => '0');
			Difference3 <= (OTHERS => '0');
			Difference4 <= (OTHERS => '0');	
			Difference  <= (OTHERS => '0');
	elsif Clock'event AND Clock = '1' then
			if Enable = '1' then
				K:=(OTHERS => '0');
				L:=(OTHERS => '0');
				M:=(OTHERS => '0');
				N:=(OTHERS => '0');
				
				for I in 0 to 4 loop
					if InputA(I)/=InputB(I) then
						K:=K+1;
					end if;
				end loop;
				for I in 5 to 9 loop
					if InputA(I)/=InputB(I) then
						L:=L+1;
					end if;
				end loop;			
				for I in 10 to 14 loop
					if InputA(I)/=InputB(I) then
						M:=M+1;
					end if;
				end loop;			
				for I in 15 to 19 loop
					if InputA(I)/=InputB(I) then
						N:=N+1;
					end if;
				end loop;					

				Difference1 <= K;
				Difference2 <= L;				
				Difference3 <= M;
				Difference4 <= N;
				
				Difference  <= Difference1 + Difference2 + Difference3 + Difference4 ;
			end if;
	end if;			
End Process;

			
end;
