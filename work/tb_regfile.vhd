    library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.core_defs.all;
use work.regfile;

entity tb_regfile is
end tb_regfile;

architecture tb_regfile_impl of tb_regfile is
component rfile
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
end component;
	for Regfile: rfile use entity work.regfile;
	signal ida,idb,idd : integer range 0 to ireg_num_registers;
	signal ind : std_logic_vector(data_bits-1 downto 0);
	signal outa,outb : std_logic_vector(data_bits-1 downto 0);
	signal we,clk,rst : std_logic;
begin
	
	Regfile: rfile
		port map(ida => ida, idb => idb, idd => idd, ind => ind,
					outa => outa, outb => outb,
					we => we, reset => rst, clk => clk);
	
	process
        -- Includes "prev" and "after" outputs. Register file has delays in the outputs.
		type pattern_type is record
			ida,idb,idd : integer range 0 to ireg_num_registers;
			ind : std_logic_vector(data_bits-1 downto 0);
			we,rst,clk : std_logic;
            outa,outb : std_logic_vector(data_bits-1 downto 0);
		end record;
		type pattern_array is array (natural range <>) of pattern_type;
		constant input_tests : pattern_array := 
            -- IDA, IDB, IDD, IND, WE, RST, CLOCK, OUTA, OUTB
		( -- Do rst. If rst = 0, all regs to 0.
		(0,0,0,x"00_00_00_00",'1','0','1',x"00_00_00_00",x"00_00_00_00"),
		(0,0,0,x"00_00_00_00",'1','0','0',x"00_00_00_00",x"00_00_00_00"),
			-- Write on register 1, and also read from it.                        
		(0,1,1,x"00_00_00_01",'1','1','1',x"00_00_00_00",x"00_00_00_01"),
		(0,1,1,x"00_00_00_01",'1','1','0',x"00_00_00_00",x"00_00_00_01"),
        	-- Read registers r0 on both operands. Output has to be 0.
		(0,0,0,x"00_00_00_00",'0','1','1',x"00_00_00_00",x"00_00_00_00"),
		(0,0,0,x"00_00_00_00",'0','1','0',x"00_00_00_00",x"00_00_00_00"),
			-- Write on Destination register, and read from it.                   
		(2,2,2,x"AA_BB_CC_04",'1','1','1',x"AA_BB_CC_04",x"AA_BB_CC_04"),
		(2,2,2,x"AA_BB_CC_04",'1','1','0',x"AA_BB_CC_04",x"AA_BB_CC_04"),
			-- Read only, two sources. Register 1 and previous Destination Register.
		(1,2,0,x"AA_BB_CC_05",'0','1','1',x"00_00_00_01",x"AA_BB_CC_04"),
		(1,2,0,x"AA_BB_CC_05",'0','1','0',x"00_00_00_01",x"AA_BB_CC_04"),
            -- Write Register ireg_num_registers
		(1,2,ireg_num_registers,x"AA_BB_CC_05",'1','1','1',x"00_00_00_01",x"AA_BB_CC_04"),
		(0,0,0,x"AA_BB_CC_05",'0','1','0',x"00_00_00_00",x"00_00_00_00"),
            -- Read Register ireg_num_registers
		(1,2,0,x"AA_BB_CC_05",'0','1','1',x"00_00_00_01",x"AA_BB_CC_04"),
		(ireg_num_registers,ireg_num_registers,0,x"AA_BB_CC_05",'0','1','0',x"AA_BB_CC_05",x"AA_BB_CC_05")
		);
		
		begin
		-- Assignments are done in parallel, but each test is processed sequentially
		for test in input_tests'range loop
			ida <= input_tests(test).ida;
			idb <= input_tests(test).idb;
			idd <= input_tests(test).idd;
			ind <= input_tests(test).ind;
			we <= input_tests(test).we;
			rst <= input_tests(test).rst;
			clk <= input_tests(test).clk;
			wait for 0.3 ns;
            assert (input_tests(test).outa = outa) report "Output A is not equal to expected value" severity failure;
            assert (input_tests(test).outb = outb) report "Output B is not equal to expected value" severity failure;
		end loop;
		assert false report "End of Test" severity note;
		wait; -- Wait without timeout to end simulation
	end process;
end tb_regfile_impl;
