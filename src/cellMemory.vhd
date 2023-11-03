-- cellMemory.vhd
-- Created on: Di 26. Sep 11:39:10 CEST 2023
-- Author(s): Yannick Reiß
-- Content: Cell memory as part of brainfuck logic
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Entity cellblock
entity cellblock is

    port(
        clk         :   in  std_logic; -- clock with speed of board clock
        enable      :   in  std_logic;
        address     :   in  std_logic_vector(15 downto 0);
        new_cell    :   in  std_logic_vector(7 downto 0);

        old_cell    :   out std_logic_vector(7 downto 0)
    );
end cellblock;

-- Architecture arch of cellblock: read on every clock cycle to cell.
architecture arch of cellblock is
    type empty is array(0 to 65535) of std_logic_vector(7 downto 0);

    signal memory : empty := (others => (others => '0'));

begin
    -- Process clk_read
    clk_read : process (clk, enable) -- runs only, when clk changed
    begin

        if rising_edge(clk) and enable = '1' then
            memory(to_integer(unsigned(address))) <= new_cell;
        end if;

    end process;

    old_cell <= memory(to_integer(unsigned(address)));

end arch;
