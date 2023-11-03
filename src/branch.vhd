-- branch.vhd
-- Created on: Di 26. Sep 13:47:51 CEST 2023
-- Author(s): Yannick Reiss <yannick.reiss@protonmail.ch>
-- Content: Branch unit / ALU for program counter XD
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TODO: CHECK PUSH AND POP AND THE PHASES/STATES OF PC_ENABLE

-- Entity branch: branch
entity branch is
    port(
        clk	        :	in	std_logic;
        state       :   in  std_logic;
		instruction	:	in	std_logic_vector(2 downto 0);
		instr_addr	:	in	std_logic_vector(7 downto 0);
        cell_value  :   in  std_logic_vector(7 downto 0);

        skip        :   out std_logic;
		pc_enable	:	out	std_logic;
        jump        :   out std_logic;
		pc_out	    :   out	std_logic_vector(7 downto 0)
    );
end branch;

-- Architecture impl of branch:
architecture impl of branch is
    type stack is array(0 to 255) of std_logic_vector(7 downto 0);

    signal addr_stack           :   stack := (others => (others => '0'));
    signal nested               :   std_logic_vector(7 downto 0) := (others => '0'); -- count nested loops
    signal skip_internal        :   std_logic := '0';
    signal stack_ptr            :   std_logic_vector(7 downto 0) := (others => '0');
    signal pc_enable_internal   :   std_logic := '1';

begin

    -- Process branch_compute  Thing that does things.
    branch_compute : process (all) -- runs only, when all changed
    begin
        if rising_edge(clk) then

            -- set addr_stack
            if skip = '0' then
                -- pop part 1

                -- push part 2
                if state = '1' and instruction = "110" then
                    addr_stack(to_integer(unsigned(stack_ptr))) <= instr_addr;
                end if;
            end if;

            -- set nested
            if state = '0' and skip_internal = '1' then

                -- deeper nest
                if instruction = "110" then
                    nested <= std_logic_vector(unsigned(nested) + 1);
                end if;
            end if;

            if state = '1' and skip_internal = '1' then
                -- nested loop ended
                if instruction = "111" then
                    nested <= std_logic_vector(unsigned(nested) - 1);
                end if;
            end if;

            -- set skip
            --  on instruction [
            if instruction = "110" and state = '0' then
                if unsigned(cell_value) > 0 and not ( skip_internal = '1' or unsigned(nested) > 0 ) then
                    skip_internal <= '0';
                else
                    skip_internal <= '1';
                end if;
            end if;

            --  on instruction ]
            if state = '0' and instruction = "111" then
                if skip_internal = '1' and unsigned(nested) > 0 then
                    skip_internal <= '1';
                else
                    skip_internal <= '0';
                end if;
            end if;

            -- set stack_ptr
            if skip_internal = '0' then
                -- pop part 2
                if state = '1' and instruction = "111" then
                    stack_ptr <= std_logic_vector(unsigned(stack_ptr) - 1);
                end if;

                -- push part 1
                if state = '0' and instruction = "110" then
                    stack_ptr <= std_logic_vector(unsigned(stack_ptr) + 1);
                end if;
            end if;


            -- set pc_enable
            pc_enable_internal <= not state;

            -- set jump
            if instruction = "111" and skip = '0' and state = '0' then
                jump <= '1';
            else
                jump <= '0';
            end if;


        end if;
    end process;

    -- connect signals to pins
    skip        <=  skip_internal;
    pc_enable   <=  pc_enable_internal;
    pc_out <= addr_stack(to_integer(unsigned(stack_ptr)));

end impl;
