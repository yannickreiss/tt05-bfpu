-- instructionMemory.vhd
-- Created on: Di 26. Sep 07:43:20 CEST 2023
-- Author(s): Yannick Reiß
-- Content: Instruction memory; Read and write operations are controlled externally.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity instructionMemory: Currently ROM; TODO: Add write enable when implementing a bus.
entity instructionMemory is

    port(
        instructionAddr     :   in  std_logic_vector(7 downto 0); -- We start with 256 instructions

        instruction         :   out std_logic_vector(2 downto 0)  -- instruction in current cell
    );
end instructionMemory;

-- Architecture arch of instructionMemory: read on every clock cycle to instruction.
architecture arch of instructionMemory is

    type imem is array(0 to 255) of std_logic_vector(2 downto 0);
    signal memory : imem := (b"010",b"001",b"010",b"000",b"011",b"001",b"011",b"000",b"110",b"011",b"111",b"011",b"110",b"011",b"101",b"111",others=>"000");
begin
    -- Process clk_read
--    clk_read : process (clk) -- runs only, when clk changed
--    begin
--
--        if rising_edge(clk) then
--
--            instruction <= memory(to_integer(unsigned(instructionAddr)));
--
--        end if;
--    end process;

    instruction <= memory(to_integer(unsigned(instructionAddr)));

end arch;
