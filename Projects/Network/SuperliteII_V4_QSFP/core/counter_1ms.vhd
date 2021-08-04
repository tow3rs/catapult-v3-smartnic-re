library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity counter_1ms is
GENERIC
	(
		BITRATE	: std_logic_vector(19 downto 0) :=	X"1E848"  --(125000)
	);
port
	(
	RefClock		: in	std_logic;
	reset			: in	std_logic;
	count_1ms		: buffer std_logic_vector(31 downto 0)
	);
end;

architecture rtl of counter_1ms is

signal count_words	:std_logic_vector(33 downto 0);


begin

	process(RefClock)
	begin
		if rising_edge(RefClock) then
			if reset = '1' then
				count_1ms <= (OTHERS => '0');
				count_words <= (OTHERS => '0');
			else
				if count_words = (BITRATE-1) then -- (125000 -1)
				
					count_words <= (OTHERS => '0');
					count_1ms <= count_1ms + 1;
				else
					count_words <= count_words + 1;
				end if;
			end if;
		end if;
	end process;
									
		
end;