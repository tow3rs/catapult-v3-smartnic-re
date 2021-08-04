library ieee;
use ieee.std_logic_1164.all;

entity Reset_Synchro is
port
	(
	Clk			: in std_logic;
	Reset_in	: in std_logic;
	Reset_out	: out std_logic
	);
end;


architecture rtl of Reset_Synchro is

signal Synchro : std_logic_vector(2 downto 0);

begin

process(Clk,Reset_in)
begin
	if (Reset_in = '1') then
		Reset_out	 	<= '1';
		Synchro			<= "111";
	elsif rising_edge(Clk) then
		Synchro		<= Synchro(1 downto 0) & (Reset_in);
		Reset_out	<= Synchro(2);
	end if;
end process;

end;