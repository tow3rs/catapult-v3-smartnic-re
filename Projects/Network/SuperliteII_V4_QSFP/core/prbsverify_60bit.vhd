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

entity PrbsVerify_60bit is
PORT(
	RxClock  			: in std_logic;
	Enable			: in std_logic;
	Reset	 			: in std_logic;
	ResetErrorCount 	: in std_logic;
	DataIn 				: in std_logic_vector(59 downto 0);
	PrbsLocked			: out std_logic;
	Errorcount_Q 		: out std_logic_vector(15 downto 0);
	next_prbs_Q			: out std_logic_vector(59 downto 0)
	);
END PrbsVerify_60bit;		

architecture rtl of PrbsVerify_60bit is

component Difference_20bit 
PORT(
	InputA 				: in std_logic_vector(19 downto 0);
	InputB	 			: in std_logic_vector(19 downto 0);
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


signal ResetErrorCount_process 	: std_logic;


signal next_prbs				: std_logic_vector(59 downto 0);
signal prbs2					: std_logic_vector(59 downto 0);

signal rcv_data 				: std_logic_vector(59 downto 0);

signal count 					: unsigned(7 downto 0);
signal count_no_match 			: unsigned(7 downto 0);

signal lock						: std_logic;
signal no_match					: std_logic;
signal no_match_W0				: std_logic;
signal no_match_W1				: std_logic;
signal no_match_W2				: std_logic;
signal no_match_W3				: std_logic;


signal detect_selectchannel 	: std_logic;

signal LSBRcvData 				: std_logic_vector(59 downto 0);

signal ErrorCount				: std_logic_vector(16 downto 0);
signal Difference_tot			: std_logic_vector(6 downto 0);

type 	Difference_Array_Type	is array (0 to 3) of std_logic_vector(4 downto 0);

signal Difference_Array			: Difference_Array_Type;
signal ResetErrorCount_i		: std_logic;
signal InputA						: std_logic_vector(19 downto 0);
signal InputB						: std_logic_vector(19 downto 0);


begin


	process(RxClock,Reset)
	begin
		if (Reset = '1') then
				prbs2 <= (OTHERS => '0');
				rcv_data <= (OTHERS => '0');
	
		elsif rising_edge(RxClock) then	
			if Enable = '1' then
			
				rcv_data	<= DataIn;
				LSBRcvData <= rcv_data;		-- reclock the data
		
				if lock = '1' then
					prbs2 <= next_prbs;
				else
					prbs2 <= LSBRcvData;
				end if;
			end if;
		end if;
	end process;


	process(RxClock,Reset)
	begin
		if (Reset = '1') then
				lock <= '0';
				no_match <= '1';
				no_match_W0 <= '1';
				no_match_W1 <= '1';
				no_match_W2 <= '1';
				no_match_W3 <= '1';

				count <= (OTHERS => '0');
		elsif rising_edge(RxClock) then
				if Enable = '1' then
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
						report "==========================================================================================================> PrbsLock achieved ..." 		severity note;							
						
					elsif count =  0 and count_no_match(7) = '1' then -- Receive 64 consecutive words not correct before declaring loss
						lock <= '0';
					else
						lock <= lock;
					end if;


					if (next_prbs(15 downto 0) /= LSBRcvData(15 downto 0)) then
						no_match_W0 <= '1';
					else
						no_match_W0 <= '0';
					end if;

					if (next_prbs(31 downto 16) /= LSBRcvData(31 downto 16))  then
						no_match_W1 <= '1';
					else
						no_match_W1 <= '0';
					end if;

					if (next_prbs(47 downto 32) /= LSBRcvData(47 downto 32))  then
						no_match_W2 <= '1';
					else
						no_match_W2 <= '0';
					end if;
					
					if (next_prbs(59 downto 48) /= LSBRcvData(59 downto 48))  then
						no_match_W3 <= '1';
					else
						no_match_W3 <= '0';
					end if;
					
					
					if (no_match_W0 = '1') or ( no_match_W1 = '1') or ( no_match_W2 = '1') or ( no_match_W3 = '1') then
						no_match <= '1';		-- One pipeline stage for performance
						if lock = '1' then
							report "==========================================================================================================> Found a data mis-match in last received word " severity note;
						end if;						
					else
						no_match <= '0';
					end if;
				end if;		
		end if;
	end process;

next_prbs(0) <= prbs2(4) XOR prbs2(9) XOR prbs2(12) XOR prbs2(22) ;
next_prbs(1) <= prbs2(0) XOR prbs2(5) XOR prbs2(10) XOR prbs2(13) XOR prbs2(18) ;
next_prbs(2) <= prbs2(1) XOR prbs2(6) XOR prbs2(11) XOR prbs2(14) XOR prbs2(19) ;
next_prbs(3) <= prbs2(2) XOR prbs2(7) XOR prbs2(12) XOR prbs2(15) XOR prbs2(20) ;
next_prbs(4) <= prbs2(3) XOR prbs2(8) XOR prbs2(13) XOR prbs2(16) XOR prbs2(21) ;
next_prbs(5) <= prbs2(4) XOR prbs2(9) XOR prbs2(14) XOR prbs2(17) XOR prbs2(22) ;
next_prbs(6) <= prbs2(0) XOR prbs2(5) XOR prbs2(10) XOR prbs2(15) ;
next_prbs(7) <= prbs2(1) XOR prbs2(6) XOR prbs2(11) XOR prbs2(16) ;
next_prbs(8) <= prbs2(2) XOR prbs2(7) XOR prbs2(12) XOR prbs2(17) ;
next_prbs(9) <= prbs2(3) XOR prbs2(8) XOR prbs2(13) XOR prbs2(18) ;
next_prbs(10) <= prbs2(4) XOR prbs2(9) XOR prbs2(14) XOR prbs2(19) ;
next_prbs(11) <= prbs2(5) XOR prbs2(10) XOR prbs2(15) XOR prbs2(20) ;
next_prbs(12) <= prbs2(6) XOR prbs2(11) XOR prbs2(16) XOR prbs2(21) ;
next_prbs(13) <= prbs2(7) XOR prbs2(12) XOR prbs2(17) XOR prbs2(22) ;
next_prbs(14) <= prbs2(0) XOR prbs2(8) XOR prbs2(13) ;
next_prbs(15) <= prbs2(1) XOR prbs2(9) XOR prbs2(14) ;
next_prbs(16) <= prbs2(2) XOR prbs2(10) XOR prbs2(15) ;
next_prbs(17) <= prbs2(3) XOR prbs2(11) XOR prbs2(16) ;
next_prbs(18) <= prbs2(4) XOR prbs2(12) XOR prbs2(17) ;
next_prbs(19) <= prbs2(5) XOR prbs2(13) XOR prbs2(18) ;
next_prbs(20) <= prbs2(6) XOR prbs2(14) XOR prbs2(19) ;
next_prbs(21) <= prbs2(7) XOR prbs2(15) XOR prbs2(20) ;
next_prbs(22) <= prbs2(8) XOR prbs2(16) XOR prbs2(21) ;
next_prbs(23) <= prbs2(9) XOR prbs2(17) XOR prbs2(22) ;
next_prbs(24) <= prbs2(0) XOR prbs2(10) ;
next_prbs(25) <= prbs2(1) XOR prbs2(11) ;
next_prbs(26) <= prbs2(2) XOR prbs2(12) ;
next_prbs(27) <= prbs2(3) XOR prbs2(13) ;
next_prbs(28) <= prbs2(4) XOR prbs2(14) ;
next_prbs(29) <= prbs2(5) XOR prbs2(15) ;
next_prbs(30) <= prbs2(6) XOR prbs2(16) ;
next_prbs(31) <= prbs2(7) XOR prbs2(17) ;
next_prbs(32) <= prbs2(8) XOR prbs2(18) ;
next_prbs(33) <= prbs2(9) XOR prbs2(19) ;
next_prbs(34) <= prbs2(10) XOR prbs2(20) ;
next_prbs(35) <= prbs2(11) XOR prbs2(21) ;
next_prbs(36) <= prbs2(12) XOR prbs2(22) ;
next_prbs(37) <= prbs2(0) XOR prbs2(13) XOR prbs2(18) ;
next_prbs(38) <= prbs2(1) XOR prbs2(14) XOR prbs2(19) ;
next_prbs(39) <= prbs2(2) XOR prbs2(15) XOR prbs2(20) ;
next_prbs(40) <= prbs2(3) XOR prbs2(16) XOR prbs2(21) ;
next_prbs(41) <= prbs2(4) XOR prbs2(17) XOR prbs2(22) ;
next_prbs(42) <= prbs2(0) XOR prbs2(5) ;
next_prbs(43) <= prbs2(1) XOR prbs2(6) ;
next_prbs(44) <= prbs2(2) XOR prbs2(7) ;
next_prbs(45) <= prbs2(3) XOR prbs2(8) ;
next_prbs(46) <= prbs2(4) XOR prbs2(9) ;
next_prbs(47) <= prbs2(5) XOR prbs2(10) ;
next_prbs(48) <= prbs2(6) XOR prbs2(11) ;
next_prbs(49) <= prbs2(7) XOR prbs2(12) ;
next_prbs(50) <= prbs2(8) XOR prbs2(13) ;
next_prbs(51) <= prbs2(9) XOR prbs2(14) ;
next_prbs(52) <= prbs2(10) XOR prbs2(15) ;
next_prbs(53) <= prbs2(11) XOR prbs2(16) ;
next_prbs(54) <= prbs2(12) XOR prbs2(17) ;
next_prbs(55) <= prbs2(13) XOR prbs2(18) ;
next_prbs(56) <= prbs2(14) XOR prbs2(19) ;
next_prbs(57) <= prbs2(15) XOR prbs2(20) ;
next_prbs(58) <= prbs2(16) XOR prbs2(21) ;
next_prbs(59) <= prbs2(17) XOR prbs2(22) ;

	


-----------------------------------------------------------------------------------------------------------
--	Synchronize ResetErrorCount
-----------------------------------------------------------------------------------------------------------	

ResetErrorCount_i <= ResetErrorCount or Reset;

Reset_Synchro_inst : Reset_Synchro
PORT MAP
	(
	Clk			=> RxClock,
	Reset_in		=> ResetErrorCount_i,
	Reset_out	=> ResetErrorCount_process
	);

Generate_Difference:
FOR i IN 0 to 2 GENERATE
DifferenceX_inst:Difference_20bit PORT MAP(
	InputA  		=> next_prbs((20*(I+1)-1) downto (20*I)),
	InputB		=> LSBRcvData((20*(I+1)-1) downto (20*I)),
	Clock			=> RxClock,
	Reset 		=> ResetErrorCount_process,
	Enable	 	=> Enable,
	Difference  => Difference_Array(i)
	);	
END GENERATE Generate_Difference;

	

Process(RxClock,ResetErrorCount_process)
Begin
	if (ResetErrorCount_process = '1') then
			ErrorCount  <= (OTHERS => '0');
			Difference_tot  <= (OTHERS => '0');
	elsif RxClock'event AND RxClock = '1' then
			if Enable = '1' then							
				Difference_tot  <= ("00" & Difference_Array(0)) + ("00" & Difference_Array(1)) + ("00" & Difference_Array(2)) ;
				if lock = '1' then
						if (Errorcount(16) = '1') then
								Errorcount <= (OTHERS => '1') ; -- saturate the counter to maximum
						else			
								ErrorCount <= ErrorCount + ("0000000000" & Difference_tot);
						end if;
				end if;
			end if; -- Validdata
	end if;			
End Process;

PrbsLocked <= lock;
ErrorCount_Q <= ErrorCount(15 downto 0);
			
end;



