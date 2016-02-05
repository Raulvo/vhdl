library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_signed.all; -- never use this library!!!
use ieee.std_logic_misc.all; -- provides or_reduce
use work.core_defs.all;
use work.functions_and_types.all;

entity alu is
  port(op1      : in  std_logic_vector(data_bits-1 downto 0);
       op2      : in  std_logic_vector(data_bits-1 downto 0);
       aluctl   : in  std_logic_vector(alu_op_bits-1 downto 0);
       res      : out std_logic_vector(data_bits-1 downto 0);
       carry    : out std_logic;
       zero     : out std_logic;
       neg      : out std_logic;
       ovfl     : out std_logic
       );
end alu;

architecture alu_impl of alu is
  signal tmp  : std_logic_vector(data_bits downto 0);
  signal op2in : std_logic_vector(data_bits-1 downto 0);
  signal is_subtraction : std_logic;
begin
    is_subtraction  <= bitwise_cmp(aluctl,"0101");
    op2in           <= sign_extend(is_subtraction,op2in'length) xor op2;
    res             <= tmp(tmp'left-1 downto 0);
    zero            <= not(or_reduce(tmp(tmp'left-1 downto 0)));


    --A "combinational process" must have a sensitivity list containing all 
    --the signals which it reads (inputs), and must always update the signals 
    --which it assigns (outputs).
    
    operate : process (aluctl, op1, op2,op2in, is_subtraction)
    begin
        case aluctl is
            when "0000"                     =>      tmp     <= logic_extend(op1 and op2in,tmp'length);
            when "0001"                     =>      tmp     <= logic_extend(op1 or op2in,tmp'length);
            when "0010"                     =>      tmp     <= logic_extend(op1 xor op2in,tmp'length);
            
            when "0011" | "0100" | "0101"   =>      tmp     <= full_adder(op1, op2in, is_subtraction);
            when "0110"                     =>      tmp     <= logic_extend(bitwise_cmp(op1,op2in),tmp'length);
            
            when others                     =>      tmp     <= sign_extend('0',tmp'length);
        end case;
    end process;
  
    outputs : process(aluctl,op1,op2,op2in,tmp)
    begin
        case? aluctl is
            when "0011"             =>      ovfl     <= ((tmp(op1'left) xor op1(op1'left)) and (tmp(op2in'left) xor op2in(op2in'left))); -- ADD INTEGER
                                            carry    <= (tmp(tmp'left));
                                            neg      <= tmp(data_bits-1);
                                                        
            when "0100"             =>      ovfl     <= (tmp(tmp'left)); -- ADD NATURAL
                                            carry    <= (tmp(tmp'left));
                                            neg      <= '0';

            when "0101"             =>      ovfl     <= (((not (tmp(op2'left))) xor op2(op2'left)) and (op1(op1'left) xor op2(op2'left))); -- SUB
                                            carry    <= tmp(tmp'left);
                                            neg      <= tmp(tmp'left-1);
            
            when others             =>      ovfl     <= '0';
                                            carry    <= '0';
                                            neg      <= '0';
        end case?;
    end process;
end alu_impl;
