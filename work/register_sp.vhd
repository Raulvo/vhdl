library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_defs.all;

entity register_sp is
	port
	(
		clk             : in std_logic;								-- Clock signal
		reset           : in std_logic;								-- Reset signal
        we_sp           : in std_logic;                             -- write enable
		in_sp           : in std_logic_vector (data_bits-1 downto 0);	-- data input
		out_sp          : out std_logic_vector (data_bits-1 downto 0);	-- Operand A port read
	);
end register_sp;

architecture register_sp_impl of register_sp is

signal sp_reg    : std_logic_vector (data_bits-1 downto 0);

begin
    process(clk,reset) begin
        if reset = '0' then
            sp_reg <= others => '0';
        elsif rising_edge(clk) then
            sp_reg <= in_sp;
        end if;
    end process;

    process(all)
    begin
        out_sp <= sp_reg;
    end process;
end register_sp_impl;
