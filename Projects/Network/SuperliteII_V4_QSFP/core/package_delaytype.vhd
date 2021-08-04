library ieee;
use ieee.std_logic_1164.all;


 PACKAGE package_delaytype IS
           type   Delay_Array	 is array (0 to 3) of std_logic_vector(4 downto 0); 
		   type   Bit8_ArrayType	is array (0 to 3) of std_logic_vector (7 downto 0);
 END package_delaytype ;

