-- bfpu.vhd
-- Created on: Di 26. Sep 08:27:47 CEST 2023
-- Author(s): Yannick Reiß
-- Content: Connect the entities of the processing unit.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity bfpu: brainfuck processing unit
entity tt_um_vhdl_yannickreiss_bfpu is
  port(
    ui_in   : in  std_logic_vector(7 downto 0);
    uo_out  : out std_logic_vector(7 downto 0);
    uio_in  : in  std_logic_vector(7 downto 0);
    uio_out : out std_logic_vector(7 downto 0);
    uio_oe  : out std_logic_vector(7 downto 0);
    clk     : in  std_logic;
    ena     : in  std_logic;
    rst_n   : in  std_logic
    );
end tt_um_yannickreiss_bfpu;

-- Architecture arch of tt_um_yannickreiss_bfpu: setup and connect components
architecture arch of tt_um_yannickreiss_bfpu is

  component instructionMemory
    port(
      instructionAddr : in  std_logic_vector(7 downto 0);
      instruction     : out std_logic_vector(2 downto 0)
      );
  end component;

  component alu
    port(
      instruction : in std_logic_vector(2 downto 0);
      old_cell    : in std_logic_vector(7 downto 0);
      old_pointer : in std_logic_vector(15 downto 0);
      extern_in   : in std_logic_vector(7 downto 0);

      new_cell    : out std_logic_vector(7 downto 0);
      new_pointer : out std_logic_vector(15 downto 0);
      enable_cell : out std_logic;
      enable_ptr  : out std_logic;
      extern_out  : out std_logic_vector(7 downto 0)
      );
  end component;

  component ptr
    port(
      clk        : in  std_logic;
      enable_ptr : in  std_logic;
      new_ptr    : in  std_logic_vector(15 downto 0);
      old_ptr    : out std_logic_vector(15 downto 0)
      );
  end component;

  component cellblock
    port(
      clk      : in  std_logic;
      enable   : in  std_logic;
      address  : in  std_logic_vector(15 downto 0);
      new_cell : in  std_logic_vector(7 downto 0);
      old_cell : out std_logic_vector(7 downto 0)
      );
  end component;

  component program_counter
    port(
      clk    : in  std_logic;
      enable : in  std_logic;
      jmp    : in  std_logic;
      pc_in  : in  std_logic_vector(7 downto 0);
      pc_out : out std_logic_vector(7 downto 0)
      );
  end component;

  component branch
    port(
      clk         : in std_logic;
      state       : in std_logic;
      instruction : in std_logic_vector(2 downto 0);
      instr_addr  : in std_logic_vector(7 downto 0);
      cell_value  : in std_logic_vector(7 downto 0);

      skip      : out std_logic;
      jump      : out std_logic;
      pc_enable : out std_logic;
      pc_out    : out std_logic_vector(7 downto 0)
      );
  end component;

  signal s_clk : std_logic;
  signal s_in  : std_logic_vector(7 downto 0) := (others => '0');
  signal s_out : std_logic_vector(7 downto 0) := (others => '0');

  signal s_instrAddr   : std_logic_vector(7 downto 0) := "00000000";
  signal s_instruction : std_logic_vector(2 downto 0) := "000";

  signal s_cell_out : std_logic_vector(7 downto 0)  := (others => '0');
  signal s_cell_in  : std_logic_vector(7 downto 0)  := (others => '0');
  signal s_ptr_out  : std_logic_vector(15 downto 0) := (others => '0');
  signal s_ptr_in   : std_logic_vector(15 downto 0) := (others => '0');

  signal s_enable_cells : std_logic := '0';
  signal s_enable_ptr   : std_logic := '0';

  signal s_enable_pc   : std_logic                    := '1';
  signal s_jmp_pc      : std_logic                    := '0';
  signal s_jmp_addr_pc : std_logic_vector(7 downto 0) := "00000000";

  signal s_skip           : std_logic := '0';
  signal s_enable_cells_o : std_logic := '0';
  signal s_enable_ptr_o   : std_logic := '0';

  signal s_processor_state : std_logic := '0';  -- 0: execute; 1: write back

begin

  -- clock and state logic
  s_clk <= clk;
  -- Process state  change state between execute and write back
  state : process (s_clk)               -- runs only, when s_clk changed
  begin
    if rising_edge(s_clk) then
      s_processor_state <= not s_processor_state;
    end if;
  end process;

  -- Process in_out  set in- and output on clk high and exec/write back
  in_out : process (s_clk)              -- runs only, when s_clk changed
  begin
    if rising_edge(s_clk) then
      if s_processor_state = '1' then
        uo_out<= s_out;
      else
        s_in <= ui_in;
      end if;
    end if;
  end process;



  instrMemory : instructionMemory
    port map(
      instructionAddr => s_instrAddr,
      instruction     => s_instruction
      );

  alu_entity : alu
    port map(
      instruction => s_instruction,
      old_cell    => s_cell_out,
      old_pointer => s_ptr_out,
      extern_in   => s_in,

      new_cell    => s_cell_in,
      new_pointer => s_ptr_in,
      enable_cell => s_enable_cells_o,
      enable_ptr  => s_enable_ptr_o,
      extern_out  => s_out
      );

  ptr_bf : ptr
    port map(
      clk        => s_clk,
      enable_ptr => s_enable_ptr,
      new_ptr    => s_ptr_in,
      old_ptr    => s_ptr_out
      );

  cellblock_bf : cellblock
    port map(
      clk      => s_clk,
      enable   => s_enable_cells,
      address  => s_ptr_out,
      new_cell => s_cell_in,
      old_cell => s_cell_out
      );

  pc : program_counter
    port map(
      clk    => s_clk,
      enable => s_enable_pc and s_processor_state,
      jmp    => s_jmp_pc,
      pc_in  => s_jmp_addr_pc,
      pc_out => s_instrAddr
      );

  branch_bf : branch
    port map(
      clk         => s_clk,
      state       => s_processor_state,
      instruction => s_instruction,
      instr_addr  => s_instrAddr,
      cell_value  => s_cell_out,
      skip        => s_skip,
      jump        => s_jmp_pc,
      pc_enable   => s_enable_pc,
      pc_out      => s_jmp_addr_pc
      );

  s_enable_ptr   <= not s_skip and s_enable_ptr_o and s_processor_state;
  s_enable_cells <= not s_skip and s_enable_cells_o and s_processor_state;
  uio_oe <= (others => '0');
  uio_out <= (others => '0');

end arch;
