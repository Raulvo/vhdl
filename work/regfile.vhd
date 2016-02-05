library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_defs.all;
use work.functions_and_types.all;

entity regfile is
	port
	(
		clk         : in std_logic;								-- Clock signal
		reset       : in std_logic;								-- Reset signal
		ida         : in integer range 0 to ireg_num_registers;				-- Operand A register ID
		idb         : in integer range 0 to ireg_num_registers;				-- Operand B register ID
		idd         : in integer range 0 to ireg_num_registers;				-- destination register ID
		ind         : in std_logic_vector (data_bits-1 downto 0);	-- data input
		we          : in std_logic;								-- write enable
		outa        : out std_logic_vector (data_bits-1 downto 0);	-- Operand A port read
		outb        : out std_logic_vector (data_bits-1 downto 0)	-- Operand B port read
	);
end regfile;

architecture regfile_impl of regfile is

subtype registerarray is array_1d_logic_vector (ireg_num_registers downto 1) (data_bits-1 downto 0);

signal registers    : registerarray;

begin
    -- Writing Process. Implied memory for signals without default values or default cases.
    process(clk,reset) begin
        if reset = '0' then
            registers <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if idd /= 0 and we = '1' then
                registers(idd) <= ind;
            end if;
        end if;
    end process;

    process(all)
    begin
        case ida is
            when 0 =>       outa <= sign_extend('0',outa'length);
            when others =>  outa <= registers(ida);			-- read operand a
        end case;
        case idb is
            when 0 =>       outb <= sign_extend('0',outb'length);
            when others =>  outb <= registers(idb);			-- read operand a
        end case;
    end process;
end regfile_impl;
