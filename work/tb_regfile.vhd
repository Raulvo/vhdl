    library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.regfile;

entity tb_regfile is
end tb_regfile;

architecture tb_regfile_impl of tb_regfile is
component rfile
	generic(nregisters : integer := 32;
				idwidth : integer := 5;
				regwidth : integer := 32
			 );
	port (
	   clk : in std_logic;											-- Clock signal
		rst : in std_logic;
		ida : in unsigned (idwidth-1 downto 0);				-- Operand A register ID
		idb : in unsigned (idwidth-1 downto 0);				-- Operand B register ID
		idd : in unsigned (idwidth-1 downto 0);				-- destination register ID
		ind : in std_logic_vector (regwidth-1 downto 0);		-- data input
		inrm0 : in std_logic_vector (regwidth-1 downto 0);
		inrm1 : in std_logic_vector (regwidth-1 downto 0);
		we  : in std_logic;
		wesp : in std_logic;											-- write enable
        rdsp : in std_logic;
		outa: out std_logic_vector (regwidth-1 downto 0);		-- Operand A port read
		outb: out std_logic_vector (regwidth-1 downto 0)
		);
end component;
	for Regfile: rfile use entity work.regfile;
	signal ida,idb,idd : unsigned(5-1 downto 0);
	signal ind,inrm0,inrm1 : std_logic_vector(32-1 downto 0);
	signal outa,outb : std_logic_vector(32-1 downto 0);
	signal we,wesp,rdsp,clk,rst : std_logic;
begin
	
	Regfile: rfile
		port map(ida => ida, idb => idb, idd => idd, ind => ind,
					inrm0 => inrm0, inrm1 => inrm1, outa => outa, outb => outb,
					we => we, rst => rst, wesp => wesp, rdsp => rdsp,clk => clk);
	
	process
        -- Includes "prev" and "after" outputs. Register file has delays in the outputs.
		type pattern_type is record
			ida,idb,idd : unsigned(5-1 downto 0);
			ind,inrm0,inrm1 : std_logic_vector(31 downto 0);
			wesp,we,rdsp,rst,clk : std_logic;
            prevouta,prevoutb,afterouta,afteroutb : std_logic_vector(31 downto 0);
		end record;
		type pattern_array is array (natural range <>) of pattern_type;
		constant input_tests : pattern_array := 
-- IDA, IDB, IDD, IND, INRM0, INRM1, WESP, WE, RDSP, RST, CLOCK, Previous Expected OUTA, Previous Expected OUTB, After Expected OUTA, After Expected OUTB
		( -- Do rst. If rst = 0, all regs to 0.
		("00000","00000","00000",x"00_00_00_00",x"00_00_00_00",x"00_00_00_00",'1','1','0','0','0',x"UU_UU_UU_UU",x"UU_UU_UU_UU",x"00_00_00_00",x"00_00_00_00"),
		("00000","00000","00000",x"00_00_00_00",x"00_00_00_00",x"00_00_00_00",'1','1','0','0','1',x"00_00_00_00",x"00_00_00_00",x"00_00_00_00",x"00_00_00_00"),
			-- Write on register 1, and also read from it.                        
		("00000","00001","00001",x"00_00_00_01",x"00_00_00_00",x"00_00_00_00",'1','0','0','1','0',x"00_00_00_00",x"00_00_00_00",x"00_00_00_00",x"00_00_00_00"),
		("00000","00001","00001",x"00_00_00_01",x"00_00_00_00",x"00_00_00_00",'1','0','0','1','1',x"00_00_00_00",x"00_00_00_00",x"00_00_00_00",x"00_00_00_01"),
			-- Write on rm0 and rm1, and read from them. WESP, RDSP enabled.       
		("11110","11111","00000",x"00_00_00_02",x"00_00_00_EE",x"00_00_00_22",'1','1','1','1','0',x"00_00_00_00",x"00_00_00_01",x"00_00_00_00",x"00_00_00_00"),
		("11110","11111","00000",x"00_00_00_02",x"00_00_00_EE",x"00_00_00_22",'0','1','1','1','1',x"00_00_00_00",x"00_00_00_00",x"00_00_00_EE",x"00_00_00_22"),
        	-- Read registers r0 on both operands. Output has to be 0.
		("00000","00000","00000",x"00_00_00_00",x"00_00_00_00",x"00_00_00_00",'1','1','0','1','0',x"00_00_00_EE",x"00_00_00_22",x"00_00_00_00",x"00_00_00_00"),
		("00000","00000","00000",x"00_00_00_00",x"00_00_00_00",x"00_00_00_00",'1','1','0','1','1',x"00_00_00_00",x"00_00_00_00",x"00_00_00_00",x"00_00_00_00"),
			-- Read from rm0 and rm1.                                             
		("11110","11111","00000",x"00_00_00_03",x"00_00_00_FF",x"00_00_00_33",'1','1','1','1','0',x"00_00_00_00",x"00_00_00_00",x"00_00_00_EE",x"00_00_00_22"),
		("11110","11111","00000",x"00_00_00_03",x"00_00_00_FF",x"00_00_00_33",'1','1','1','1','1',x"00_00_00_EE",x"00_00_00_22",x"00_00_00_EE",x"00_00_00_22"),
			-- Write on Destination register, and read from it.                   
		("00010","00010","00010",x"AA_BB_CC_04",x"00_00_00_44",x"00_00_00_44",'1','0','0','1','0',x"00_00_00_EE",x"00_00_00_22",x"00_00_00_00",x"00_00_00_00"),
		("00010","00010","00010",x"AA_BB_CC_04",x"00_00_00_44",x"00_00_00_44",'1','0','0','1','1',x"00_00_00_00",x"00_00_00_00",x"AA_BB_CC_04",x"AA_BB_CC_04"),
			-- Read only, two sources. Register 1 and previous Destination Register.
		("00001","00010","00000",x"AA_BB_CC_05",x"00_00_00_55",x"00_00_00_55",'1','0','0','1','0',x"AA_BB_CC_04",x"AA_BB_CC_04",x"00_00_00_01",x"AA_BB_CC_04"),
		("00001","00010","00000",x"AA_BB_CC_05",x"00_00_00_55",x"00_00_00_55",'1','0','0','1','1',x"00_00_00_01",x"AA_BB_CC_04",x"00_00_00_01",x"AA_BB_CC_04"),
            -- Try to write to both Standard and Special registers. Values of registers should not change.
            -- Result: 
		("00001","00010","00000",x"FF_FF_FF_FF",x"EE_EE_EE_EE",x"DD_DD_DD_DD",'1','1','1','1','0',x"00_00_00_01",x"AA_BB_CC_04",x"00_00_00_EE",x"00_00_00_22"),
		("00001","00010","00000",x"FF_FF_FF_FF",x"EE_EE_EE_EE",x"DD_DD_DD_DD",'0','0','1','1','1',x"00_00_00_EE",x"00_00_00_22",x"00_00_00_EE",x"00_00_00_22"),
        -- now disable reading special registers, so output should be standard registers 1 and 2
        ("00001","00010","00000",x"FF_FF_FF_FF",x"EE_EE_EE_EE",x"DD_DD_DD_DD",'0','0','0','1','1',x"00_00_00_EE",x"00_00_00_22",x"00_00_00_01",x"AA_BB_CC_04")
		);
		
		begin
		-- Assignments are done in parallel, but each test is processed sequentially
		for test in input_tests'range loop
			ida <= input_tests(test).ida;
			idb <= input_tests(test).idb;
			idd <= input_tests(test).idd;
			ind <= input_tests(test).ind;
			inrm0 <= input_tests(test).inrm0;
			inrm1 <= input_tests(test).inrm1;
			wesp <= input_tests(test).wesp;
			we <= input_tests(test).we;
            rdsp <= input_tests(test).rdsp;
			rst <= input_tests(test).rst;
			clk <= input_tests(test).clk;
            assert (input_tests(test).prevouta = outa) report "Output A is not equal to expected value" severity failure;
            assert (input_tests(test).prevoutb = outb) report "Output B is not equal to expected value" severity failure;
			wait for 0.3 ns;
            assert (input_tests(test).afterouta = outa) report "Output A is not equal to expected value" severity failure;
            assert (input_tests(test).afteroutb = outb) report "Output B is not equal to expected value" severity failure;
		end loop;
		assert false report "End of Test" severity note;
		wait; -- Wait without timeout to end simulation
	end process;
end tb_regfile_impl;
