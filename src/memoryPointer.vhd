-- memoryPointer.vhd
-- Created on: Di 26. Sep 11:11:49 CEST 2023
-- Author(s): Yannick Reiß
-- Content: Store current ptr. Part of brainfuck logic
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity ptr: 15 bit pointer to cell
entity ptr is
    port(
        clk	        :	in	std_logic;
		enable_ptr	:	in	std_logic;
		new_ptr	    :	in	std_logic_vector(15 downto 0);

		old_ptr	    :	out	std_logic_vector(15 downto 0)
    );
end ptr;

-- Architecture implement_ptr of ptr:
architecture implement_ptr of ptr is
    signal reg : std_logic_vector(15 downto 0) := (others => '0');
begin

    -- Process Write  set new_ptr
    write : process (clk, enable_ptr) -- runs only, when clk changed
    begin
        if rising_edge(clk) and enable_ptr = '1' then
            reg <= new_ptr;
        end if;
    end process;

    old_ptr <= reg;

end implement_ptr;
