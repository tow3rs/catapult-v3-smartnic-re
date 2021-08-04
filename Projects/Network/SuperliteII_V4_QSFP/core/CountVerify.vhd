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

entity CountVerify is
PORT(
	Clock  				: in std_logic;
	Reset	 			: in std_logic;
	ResetErrorCount 	: in std_logic;
	DataIn 				: in std_logic_vector(15 downto 0);
	Enable				: in std_logic;	
	CountLocked			: out std_logic;
	Errorcount_Q 		: out std_logic_vector(15 downto 0);
	Count_Pattern_Q		: out std_logic_vector(15 downto 0)
	);
END CountVerify;		


architecture rtl of CountVerify is


component Difference 
PORT(
	InputA 				: in std_logic_vector(15 downto 0);
	InputB	 			: in std_logic_vector(15 downto 0);
	Clock				: in std_logic;
	Reset				: in std_logic;
	Enable				: in std_logic;
	Difference			: out std_logic_vector(4 downto 0)
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


signal Reset_combined	: std_logic;


signal count_pattern			: std_logic_vector(15 downto 0) := (OTHERS => '0');
signal rcv_data 				: std_logic_vector(15 downto 0);

signal count 					: unsigned(7 downto 0);
signal count_no_match 			: unsigned(7 downto 0);

signal lock						: std_logic;
signal no_match					: std_logic;
signal no_match_W0				: std_logic;
signal RcvData 				: std_logic_vector(15 downto 0);
signal RcvData_Q 			: std_logic_vector(15 downto 0);

signal ErrorCount				: std_logic_vector(16 downto 0);
signal Difference_tot			: std_logic_vector(6 downto 0);

type 	Difference_Array_Type	is array (0 to 3) of std_logic_vector(4 downto 0);

signal Difference_Array			: Difference_Array_Type;
signal Reset_combined_i 		: std_logic;



begin


	process(Clock,Reset)
	begin
		if (Reset = '1') then
				RcvData 	<= (OTHERS => '0');
				RcvData_Q 	<= (OTHERS => '0');	
		elsif rising_edge(Clock) then	

				if Enable = '1' then	
	
					RcvData <= DataIn;		-- reclock the data
					RcvData_Q <= RcvData; 
					
					if lock = '1' then
						count_pattern <= count_pattern + 1;
					else
						count_pattern <= RcvData;
					end if;
				end if;
		end if;
	end process;


	process(Clock,Reset)
	begin
		if (Reset = '1') then
				lock <= '0';
				no_match <= '1';
				no_match_W0 <= '1';
				count <= (OTHERS => '0');	
		elsif rising_edge(Clock) then
				if no_match = '1' then
					count <= (Others => '0');
					count_no_match <= count_no_match + 1;
				else
					count <= count + 1;
					count_no_match <=(Others => '0');
				end if;
				if count(7) = '1' and count_no_match = 0 then -- Receive 64 bits without any errors before declaring lock
					lock <= '1';
					assert(lock = '1')
					report "==========================================================================================================> CountLock achieved ..." 		severity note;							
						
				elsif count =  0 and count_no_match(7) = '1' then -- Receive 64 consecutive words not correct before declaring loss
					lock <= '0';
				else
					lock <= lock;
				end if;


				if (count_pattern(15 downto 0) /= RcvData_Q(15 downto 0))  or (RcvData(15 downto 0) /= (RcvData_Q(15 downto 0) + 1)) then
					no_match_W0 <= '1';
				else
					no_match_W0 <= '0';
				end if;

				if (no_match_W0 = '1')  then
					no_match <= '1';		-- One pipeline stage for performance
					if lock = '1' then
						report "==========================================================================================================> Found a data mis-match in last received word " severity note;
					end if;					
				else
					no_match <= '0';
				end if;			
		end if;
	end process;


-----------------------------------------------------------------------------------------------------------
--	Synchronize ResetErrorCount
-----------------------------------------------------------------------------------------------------------	

Reset_combined_i <= ResetErrorcount or Reset;

Reset_Synchro_inst : Reset_Synchro
PORT MAP
	(
	Clk			=> Clock,
	Reset_in		=> Reset_combined_i,
	Reset_out	=> Reset_combined
	);


DifferenceX_inst:Difference PORT MAP(
	InputA  		=> count_pattern,
	InputB		=> RcvData_Q,
	Clock			=> Clock,
	Reset 		=> Reset_combined,
	Enable	 	=> Enable,
	Difference  => Difference_Array(0)
	);	

	
Process(Clock,Reset_combined)
Begin
	if (Reset_combined = '1') then
			ErrorCount  <= (OTHERS => '0');
			Difference_tot  <= (OTHERS => '0');
			count_pattern_Q <= (OTHERS => '0');
	elsif Clock'event AND Clock = '1' then
			if Enable = '1' then	
							
				Difference_tot  <= ("00" & Difference_Array(0)) ;
				if lock = '1' then
						if (Errorcount(16) = '1') then
								Errorcount <= (OTHERS => '1') ; -- saturate the counter to maximum
						else			
								ErrorCount <= ErrorCount + ("0000000000" & Difference_tot);
						end if;
				end if;
				count_pattern_Q <=  count_pattern;
			end if; -- Validdata
	end if;			
End Process;

CountLocked <= lock;
ErrorCount_Q <= ErrorCount(15 downto 0);
			
end;
