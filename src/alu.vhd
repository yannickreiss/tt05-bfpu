-- alu.vhd
-- Created on: Di 26. Sep 10:07:59 CEST 2023
-- Author(s): Yannick Reiß
-- Content: Decode instructions and control brainfuck logic
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity alu: alu crtl
entity alu is
    port(
        instruction	:	in	std_logic_vector(2 downto 0);
        old_cell	:	in	std_logic_vector(7 downto 0);
        old_pointer :   in	std_logic_vector(15 downto 0);
        extern_in	:   in	std_logic_vector(7 downto 0);

        new_cell	:	out	std_logic_vector(7 downto 0);
        new_pointer	:	out	std_logic_vector(15 downto 0);
        enable_cell	:	out	std_logic;
        enable_ptr	:	out	std_logic;
        extern_out	:   out	std_logic_vector(7 downto 0)
    );
end alu;

-- Architecture implementation of alu: implements table
architecture implementation of alu is
    signal buffer_out : std_logic_vector(7 downto 0) := (others => '0');
begin
    -- Process p_instruction
    p_instruction : process (extern_in, instruction, old_cell, old_pointer)
    begin
        case instruction is
            when "000" =>
                enable_cell <= '0';
                enable_ptr  <= '1';
                new_pointer <= std_logic_vector(unsigned(old_pointer) + 1);

                new_cell    <= old_cell;
                -- buffer_out  <= "00000000";
            when "001" =>
                enable_cell <= '0';
                enable_ptr  <= '1';
                new_pointer <= std_logic_vector(unsigned(old_pointer) - 1);

                new_cell    <= old_cell;
                -- buffer_out  <= "00000000";
            when "010" =>
                enable_cell <= '1';
                enable_ptr  <= '0';
                new_cell    <= std_logic_vector(unsigned(old_cell) + 1);

                new_pointer <= old_pointer;
                -- buffer_out  <= "00000000";
            when "011" =>
                enable_cell <= '1';
                enable_ptr  <= '0';
                new_cell    <= std_logic_vector(unsigned(old_cell) - 1);

                new_pointer <= old_pointer;
                -- buffer_out  <= "00000000";
            when "100" =>
                enable_cell <= '1';
                enable_ptr  <= '0';
                new_cell    <= extern_in;

                new_pointer <= old_pointer;
                -- buffer_out  <= "00000000";
            when "101" =>
                enable_cell <= '0';
                enable_ptr  <= '0';
                buffer_out  <= old_cell;

                new_pointer <= old_pointer;
                new_cell    <= old_cell;
            when others =>
                enable_cell <= '0';
                enable_ptr  <= '0';

                new_pointer <= old_pointer;
                new_cell    <= old_cell;
                -- buffer_out  <= "00000000";
        end case;
    end process;

    extern_out <= buffer_out;

end implementation;
