-- programCounter.vhd
-- Created on: Di 26. Sep 12:45:10 CEST 2023
-- Author(s): Yannick Reiß
-- Content: Set and store program counter only. Logic entirely in branch!
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity program_counter: set/store pc
entity program_counter is
    port(
        clk	    :	in	std_logic;
		enable	:	in	std_logic;
		jmp	    :	in	std_logic;
		pc_in	:	in	std_logic_vector(7 downto 0);
		pc_out	:	out	std_logic_vector(7 downto 0)
    );
end program_counter;

-- Architecture pc of program_counter:
architecture pc of program_counter is
    signal pc_intern : std_logic_vector(7 downto 0) := (others => '0');
begin

    -- Process count
    count : process (clk, enable, jmp) -- runs only, when clk, enable, jmp changed
    begin
        if rising_edge(clk) and enable = '1' then
            if jmp = '1' then
                pc_intern <= pc_in;
            else
                pc_intern <= std_logic_vector(unsigned(pc_intern) + 1);
            end if;
        end if;
    end process;


    pc_out <= pc_intern;

end pc;
