----------------------------------------------------------------------------------------------------
-- (c)2007 Altera Corporation. All rights reserved.
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
-- File          : rx_path_deskew.vhd
-- Author		 : Peter Schepers
----------------------------------------------------------------------------------------------------
--
-- Rx_Path_Deskew : 			
--							- Deskews the lanes using embedded FIFO's inside the Transceiver.
----------------------------------------------------------------------------------------------------

-- Lane Alignment coding (receive)
-- B7				B6					         B5		B4		B3		B2 	B1						B0
-- Lane Ident	Latency Count Rx			7C		7C		7C		7C		FD or 5C or 7C		7C


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.package_delaytype.all; -- package that define "Delay_Array" type

 
entity Rx_Path_Deskew is
GENERIC
	(
		NUMBER_OF_LANES		: integer := 4;	  	-- NUMBER_OF_LANES
		LANE_IDENTITY			: boolean := true;		
		SIMPLEX					: boolean := false; 	-- When enabled, does not perform any handshaking with remote side.
		LANEWIDTH				: integer := 64		-- LANEWIDTH for transceiver
	);
PORT(
	Clock							: in std_logic;							
	Reset							: in std_logic;
	Enable						: in std_logic;
	data_in						: in std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);
	ctrl_in						: in std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0);  		
	data_out						: out std_logic_vector(((NUMBER_OF_LANES * LANEWIDTH)-1) downto 0);
	rx_fifo_rd_en				: out STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) DOWNTO 0); 	
	rx_enh_fifo_pempty		: in  STD_LOGIC_VECTOR((NUMBER_OF_LANES-1) DOWNTO 0); 
	Valid_Data					: out std_logic;
	Error							: out std_logic;
	Force_Rx_Reset				: out std_logic;		-- Not used
	Lane_Aligned				: buffer std_logic;
	Linkup						: buffer std_logic;
	XOFF_Received				: buffer std_logic;
	Rx_Error						: buffer std_logic;
	Delay							: buffer Delay_Array;
	Lane_identifier			: buffer Bit8_ArrayType;
	Latency_Count_Rx			: buffer std_logic_vector(7 downto 0);
	Latency_Count_Rx_Valid	: buffer std_logic
	);
END Rx_Path_Deskew;	

	
architecture rtl of Rx_Path_Deskew is

type  DelayStateType is (ResetState, SkipFirstIdle, WaitForFifoFill, WaitForControl,WaitForLaneAligned,CheckDelay,WaitForControl_Validation,WaitForLaneAligned_Validation,CheckDelay_Validation,Success,ErrorState);
type   Rx_State_type	 is (Idle,Normal,XOFF_Received_from_Remote,Remote_Side_Aligned,Rx_State_Error);


signal DelayState 				: DelayStateType;
signal RX_State					: Rx_State_type;

signal Zeroes 						: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);
signal Ones 						: std_logic_vector ((NUMBER_OF_LANES - 1) downto 0);

signal Lane_Aligned_assertion	: std_logic;
signal Found_Alignment_Lane 	: std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 

signal countstate					: std_logic_vector(7 downto 0);
signal Delay_Combined			: std_logic_vector(((NUMBER_OF_LANES*5)-1) DOWNTO 0); 
signal Zeroes_5times				: std_logic_vector(((NUMBER_OF_LANES*5)-1) DOWNTO 0) := (OTHERS => '0');
signal ctrl_out					: std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 
	
	
signal Reset_dupA1 				: std_logic;
signal Reset_dupA2 				: std_logic;
signal Lane_Aligned_min1		: std_logic;


signal rx_fifo_rd_en_r			: std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 
signal rx_enh_fifo_pempty_r 	: std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0); 
signal Found_Control				: std_logic_vector((NUMBER_OF_LANES-1) DOWNTO 0);  

begin

Generate_ZEROES_and_ONES:
FOR i IN 0 to NUMBER_OF_LANES-1 GENERATE
Ones(I) <= '1';
Zeroes(I) <= '0';
END GENERATE;

Generate_ZEROES_3times:
FOR i IN 0 to (NUMBER_OF_LANES*5)-1 GENERATE
Zeroes_5times(I) <= '0';
END GENERATE;

		
-----------------------------------------------------------------------------------------------------------
--	Delay Statemachine
-----------------------------------------------------------------------------------------------------------	

process (Clock)
	begin
		if Clock'event and Clock = '1' then
					Reset_dupA1 <= Reset;
					Reset_dupA2 <= Reset_dupA1;
					
			if Reset_dupA2 = '1' then
					DelayState <= ResetState;
			else
			

				
				CASE DelayState	 IS
		         
					WHEN ResetState    		=> DelayState <= SkipFirstIdle;
					
					WHEN SkipFirstIdle		=> if (Found_Control = Zeroes) then 			-- If the statemachine comes out of reset at the time an Idle is received it can go wrong, to prevent this wait until Idle is gone.
															DelayState <= WaitForFifoFill;
														end if;
									
					WHEN WaitForFifoFill		=>  
														 if rx_enh_fifo_pempty_r = Zeroes then														 
															DelayState <= WaitForControl;
														 end if;
					
					WHEN WaitForControl 		=>  
														 if (Found_Control /= Zeroes) then -- Find first control character on one of the lines.
															DelayState <= WaitForLaneAligned;
														 end if;
														 
														 
					WHEN WaitForLaneAligned	=>	 if (Found_Alignment_Lane = Ones) then
															  DelayState <= CheckDelay;
														 end if;														 


					WHEN CheckDelay			=> if Delay_Combined = Zeroes_5times then -- check if Delay is 0 on all lanes , otherwise go back to WaitForControl
																DelayState <= Success;
														else
																DelayState <= WaitForControl;
														end if;														

					WHEN Success				=> if ctrl_in(0) = '1' and data_in(7 downto 0) = X"BC"  then -- Wait to start checking for the alignment until first control character is received on lane 0
															DelayState <= WaitForControl_Validation ;
														 end if;

					WHEN WaitForControl_Validation 		=>  if ctrl_in(0) = '1' and data_in(7 downto 0) = X"BC"  then -- Wait to start checking for the alignment until first control character is received on lane 0
															DelayState <= WaitForLaneAligned_Validation;
														 end if;
														 

					WHEN WaitForLaneAligned_Validation	=>	 if (Found_Alignment_Lane = Ones) then
															  DelayState <= CheckDelay_Validation;
														 end if;														 


					WHEN CheckDelay_Validation			=> if Delay_Combined = Zeroes_5times then -- check if Delay is 0 on all lanes , otherwise there has been a misalignment and should go to the errorstate
																DelayState <= Success;
														else
																DelayState <= ErrorState;
														end if;	
																	
					WHEN ErrorState			=> 
														DelayState <= ErrorState;	

					When OTHERS					=> DelayState <= ErrorState;
				end case;
				
			end if;		
	
		end if;
end process;

-----------------------------------------------------------------------------------------------------------
-- Reclock rx_enh_fifo_pempty as there is a long delay on this path.
-----------------------------------------------------------------------------------------------------------	


process(Clock)
begin
	   if Clock'event and Clock = '1' then
			FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
				rx_enh_fifo_pempty_r(I)				<= rx_enh_fifo_pempty(I);
			END LOOP;
		end if;
end process;


process (Clock)
	begin

		if Clock'event and Clock = '1' then
		
		if Reset_dupA2 = '1' then
			FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
				Delay(I) <= (OTHERS => '1');
			END LOOP;
			ctrl_out							<= (OTHERS => '0');
			Lane_Aligned_min1 					<= '0';
			Lane_Aligned					<= '0';
			Lane_Aligned_assertion 		<= '0';
			Error								<= '0';
			countstate						<= (OTHERS => '0');
			Force_Rx_Reset					<= '0';
			Latency_Count_Rx				<= (OTHERS => '0');
			Latency_Count_Rx_Valid		<= '0';			

			FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
				rx_fifo_rd_en_r(I)				<= not rx_enh_fifo_pempty_r(I);
			END LOOP;
			
			FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
				Found_Alignment_Lane(I) <= '0';
				if (LANE_IDENTITY) then
					Lane_identifier(I)	<= conv_std_logic_vector(I,8);
				else
					Lane_identifier(I)	<= (OTHERS => '0');
				end if;
			END LOOP;

			FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
				Found_Control(I) <= '0';
			END LOOP;

		else
		


			  Lane_Aligned <= Lane_Aligned_min1; -- add additional fifo

				FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP				
						if ctrl_in(I) = '1' and data_in( (15 + (LANEWIDTH*I))  downto (0 + (LANEWIDTH*I)) ) = X"1CBC"   then
								Found_Control(I) <= '1';
						else
								Found_Control(I) <= '0';								
						end if;
				 END LOOP;			  

			  
		     CASE DelayState	 IS
		         
					WHEN ResetState    		=> 
														FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
															Delay(I) <= (OTHERS => '1');
														END LOOP;
														ctrl_out							<= (OTHERS => '0');
														Lane_Aligned_min1 					<= '0';
														Lane_Aligned_assertion 		<= '0';
														Error								<= '0';
														countstate						<= (OTHERS => '0');
														Force_Rx_Reset					<= '0';
														FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
															rx_fifo_rd_en_r(I)				<= not rx_enh_fifo_pempty_r(I);
														END LOOP;
														FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
															Found_Alignment_Lane(I) <= '0';
														END LOOP;					


				   WHEN SkipFirstIdle		=> FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
															rx_fifo_rd_en_r(I)				<= not rx_enh_fifo_pempty_r(I);
														END LOOP;				 

					WHEN WaitForFifoFill    =>  rx_fifo_rd_en_r					<= (OTHERS => '0');														
					
					WHEN WaitForControl 		=>  FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP	
															rx_fifo_rd_en_r(I) <= '1';	
															 END LOOP;	
														
														-- Reset the delay
														FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
															Delay(I) <= (OTHERS => '1');
														END LOOP;														
															 
														


					WHEN WaitForLaneAligned	=>	 FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP				
																if ctrl_in(I) = '1' and data_in((LANEWIDTH*(I+1)-33) downto (LANEWIDTH*I)+16) = X"7C7C"  then
																		Found_Alignment_Lane(I) <= '1';
																end if;
														 END LOOP;
														 FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP	
															rx_fifo_rd_en_r(I) <= '1';	
															 END LOOP;

															FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP				
																if Found_Alignment_Lane(I) = '1' then
																	Delay(I) <= Delay(I) + 1;
																end if;
															END LOOP;	

															if (Found_Alignment_Lane = Ones) then 
																	FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
																		Found_Alignment_Lane(I) <= '0';
																	END LOOP;		
															end if;	
															
					WHEN CheckDelay			=> 
														FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
															if Delay(I) > 0 then			-- If delay is bigger than zero then do not read out the FIFO for one clock cycle in order to delay it for one clock
																rx_fifo_rd_en_r(I) <= '0';
															else
																rx_fifo_rd_en_r(I) <= '1';
															end if;
														END LOOP;
														


					WHEN Success				=> FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP	
															rx_fifo_rd_en_r(I) <= '1';	
														END LOOP;
															 
														Lane_Aligned_min1 <= '1';
														if (Lane_Aligned_min1 = '1') then 
															Lane_Aligned_assertion <= '1';
															assert(Lane_Aligned_assertion = '1')
															report "==========================================================================================================> All lanes Aligned ..." 		severity note;										
														end if;
														
					WHEN WaitForControl_Validation 		=>  FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP	
															rx_fifo_rd_en_r(I) <= '1';	
															 END LOOP;	
														
														-- Reset the delay
														FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
															Delay(I) <= (OTHERS => '1');
														END LOOP;															
														
					WHEN WaitForLaneAligned_Validation	=>	 FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP				
																if ctrl_in(I) = '1' and data_in((LANEWIDTH*(I+1)-33) downto (LANEWIDTH*I)+16) = X"7C7C"  then
																		Found_Alignment_Lane(I) <= '1';
																		Lane_identifier(I) 		<= data_in((LANEWIDTH*(I+1)-1) downto (LANEWIDTH*I)+56);	
																		Latency_Count_Rx			<= data_in(55 downto 48);
																		Latency_Count_Rx_Valid	<= '1';
																else
																		Latency_Count_Rx_Valid	<= '0';
																end if;
														 END LOOP;

														 FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP	
															rx_fifo_rd_en_r(I) <= '1';	
															 END LOOP;

															FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP				
																if Found_Alignment_Lane(I) = '1' then
																	Delay(I) <= Delay(I) + 1;
																end if;
															END LOOP;	

															if (Found_Alignment_Lane = Ones) then 
																	FOR i IN 0 to (NUMBER_OF_LANES-1) LOOP
																		Found_Alignment_Lane(I) <= '0';
																	END LOOP;		
															end if;	
															
	

					WHEN CheckDelay_Validation			=> 	Latency_Count_Rx_Valid	<= '0';
														
					WHEN ErrorState			=> Error <= '1';
					
					When OTHERS					=> Error <= '1';
				end case;	
			end if;	

		end if;
end process;


rx_fifo_rd_en <= rx_fifo_rd_en_r;


data_out <= data_in;
Valid_Data <= '1' when ((ctrl_in /= Ones) and (Lane_Aligned = '1') and (Enable = '1') and (Linkup = '1')) else '0';
-- Modified to allow for glitches on ctrl_in to not bring down the entire link for a long time
-- Discovered during testing with FEC.

Generate_Delay_Combined_MSB:
FOR i IN 0 to (NUMBER_OF_LANES-1) GENERATE
	Delay_Combined((5*I)+4 downto (5*I)) <=  Delay(I)(4 downto 0); 		
END GENERATE;		

-----------------------------------------------------------------------------------------------------------
--	Rx_State State Machine
-----------------------------------------------------------------------------------------------------------	

	process (Clock)
	begin
		if Clock'event and Clock = '1' then
		
			if Reset_dupA2 = '1' then
				Rx_State <= Idle;	

			else			
			
			  if (ctrl_in = Ones) and (Lane_Aligned_min1 = '1') then 
			  
				  CASE data_in(15 downto 0) IS
				  
					  WHEN X"7C7C" => Rx_State <= Normal;  -- K28.3/K28.3
												assert (Rx_State = Normal)
												report "==========================================================================================================> Rx State Normal ..." 		severity note;
					  
					  WHEN X"FD7C" => Rx_State <= Remote_Side_Aligned; -- K29.7/K28.3
												assert (Rx_State = Remote_Side_Aligned)
												report "==========================================================================================================> Remote_Side_Aligned ..." 		severity note;
					  
					  WHEN X"5C7C" => Rx_State <= XOFF_Received_from_Remote; -- K28.2/K28.3
												assert (Rx_State = XOFF_Received_from_Remote)
												report "==========================================================================================================> XOFF_Received_from_Remote ..." 		severity note;

												
					  WHEN X"1CBC" => Rx_State <= Rx_State;
					  WHEN X"AAAA" => Rx_State <= Rx_State; -- Idle Data
					  WHEN OTHERS  => Rx_State <= Idle;
												assert (Rx_State = Idle)
												report "==========================================================================================================> Rx_State = Idle ..." 		severity note;
					  					  
				  end case;
			 end if;

			end if;  							
		end if;
   	end process;
		
	process (Clock)
	begin

		if Clock'event and Clock = '1' then
		
		if Reset_dupA2 = '1' then
					Linkup <= '0';
					XOFF_Received <= '0';
					Rx_Error <= '0';
		else		
		
		

		     CASE Rx_State IS
		         WHEN Idle    				=>   Linkup <= '0';
														  XOFF_Received <= '0';
														  
					WHEN Normal					=>   if (SIMPLEX) then		
																Linkup <= '1'; -- When Lanealigned is achieved, Linkup is also achieved in simplex mode.
														  else 
																Linkup <= '0';
														  end if;
														  XOFF_Received <= '0';
														  
					WHEN XOFF_Received_from_Remote => Linkup <= '1';
														   XOFF_Received <= '1';	
														
					WHEN Remote_Side_Aligned => 	Linkup <= '1';
															assert (Linkup = '1')
															report "==========================================================================================================> Linkup ..." 		severity note;

														   XOFF_Received <= '0';																																
														  
					When OTHERS					=> 	Linkup <= '0';
														   XOFF_Received <= '0';
															Rx_Error <= '1';
															assert (Rx_Error = '1')
															report "==========================================================================================================> Rx State Error ..." 		severity note;

															
														
															
				end case;
		  end if;
		end if;
   	end process;
					
end;
