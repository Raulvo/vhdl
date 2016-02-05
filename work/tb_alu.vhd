library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.core_defs.all;
use work.alu;

entity tb_alu is
end tb_alu;

architecture tb_alu_impl of tb_alu is
component alu_comp
    port(op1      : in  std_logic_vector(data_bits-1 downto 0);
           op2      : in  std_logic_vector(data_bits-1 downto 0);
           aluctl   : in  std_logic_vector(alu_op_bits-1 downto 0);
           res      : out std_logic_vector(data_bits-1 downto 0);
           carry    : out std_logic;
           zero     : out std_logic;
           neg      : out std_logic;
           ovfl     : out std_logic
           );
end component;
	for alu_inst : alu_comp use entity work.alu;
	signal op1,op2,result               : std_logic_vector(data_bits-1 downto 0);
	signal aluop                        : std_logic_vector(alu_op_bits-1 downto 0);
	signal carry,zero,negative,overflow : std_logic;
begin
	
	alu_inst: alu_comp
		port map(op1 => op1, op2 => op2, 
					aluctl => aluop, res => result, carry => carry, zero => zero, neg => negative, ovfl => overflow);
	
	process
		type pattern_type is record
			op1,op2                     : std_logic_vector(data_bits-1 downto 0);
			aluop                       : std_logic_vector(alu_op_bits-1 downto 0);
            carry,zero,neg,ovfl         : std_logic;            
            result                      : std_logic_vector(data_bits-1 downto 0);
		end record;
		type pattern_array is array (natural range <>) of pattern_type;
		constant input_tests : pattern_array := 
			-- op1, op2, aluop, expected carry, expected zero, expected neg, expected ovfl, expected result
		(
            -- ADD TESTS
            --zero Flag should be activated.
            (x"00_00_00_00",x"00_00_00_00","0011",'0','1','0','0',x"00_00_00_00"),
            -- neg Flag should be activated.
            (x"80_00_00_00",x"00_00_00_00","0011",'0','0','1','0',x"80_00_00_00"),
            -- neg Flag should be activated         
            (x"FF_FF_FF_FF",x"FF_FF_FF_FF","0011",'1','0','1','0',x"FF_FF_FF_FE"),
            -- ovfl Flag should be activated. Carry too, but no effect in case of integers         
            (x"9F_FF_FF_FF",x"9F_FF_FF_FF","0011",'1','0','0','1',x"3F_FF_FF_FE"),
            --Should return 2                        
            (x"00_00_00_01",x"00_00_00_01","0011",'0','0','0','0',x"00_00_00_02"),
            
            --SUB TESTS                              
            --zero Flag should be activated          
            (x"00_00_00_01",x"00_00_00_01","0101",'0','1','0','0',x"00_00_00_00"),
            --neg Flag should be activated          
            (x"00_00_00_00",x"00_00_00_01","0101",'0','0','1','0',x"FF_FF_FF_FF"),
            --ovfl Flag should be activated          
            (x"7F_FF_00_FF",x"AF_FF_00_EE","0101",'0','0','1','1',x"D0_00_00_11"),
            --Should return the same number          
            (x"00_00_00_01",x"00_00_00_00","0101",'0','0','0','0',x"00_00_00_01"),
            
            --AND TESTS                              
            --zero Flag should be activated          
            (x"00_00_00_00",x"00_00_00_00","0000",'0','1','0','0',x"00_00_00_00"),
            --zero Flag should be activated          
            (x"11_11_11_11",x"00_00_00_00","0000",'0','1','0','0',x"00_00_00_00"),
            --Return 00_11_11_00                     
            (x"11_11_11_11",x"00_11_11_00","0000",'0','0','0','0',x"00_11_11_00"),
            
            --OR TESTS                               
            --zero Flag should be activated          
            (x"00_00_00_00",x"00_00_00_00","0001",'0','1','0','0',x"00_00_00_00"),
            --Should return all ones                 
            (x"10_10_10_10",x"01_01_01_01","0001",'0','0','0','0',x"11_11_11_11"),
            --Should return all ones                 
            (x"11_11_11_11",x"11_11_11_11","0001",'0','0','0','0',x"11_11_11_11"),
            
            --OTHER NON-AVAILABLE OPERATION CODE
            (x"00_00_00_00",x"12_34_56_78","1111",'0','1','0','0',x"00_00_00_00")
		);
		
		begin
		-- Assignments are done in parallel, but each test is processed sequentially
		for test in input_tests'range loop
			op1 <= input_tests(test).op1;
			op2 <= input_tests(test).op2;
			aluop <= input_tests(test).aluop;
			wait for 1 ns;
            assert (zero = input_tests(test).zero) report "Zero flag assertion failed" severity failure;
            assert (negative = input_tests(test).neg) report "Negative flag assertion failed" severity failure;
            assert (overflow = input_tests(test).ovfl) report "Overflow flag assertion failed" severity failure;
            assert (result = input_tests(test).result) report "Result assertion failed" severity failure;
		end loop;
		assert false report "end of test" severity note;
		wait; -- Wait without timeout to end simulation
	end process;
end tb_alu_impl;
