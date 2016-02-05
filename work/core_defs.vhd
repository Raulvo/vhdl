library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.std_logic_misc.all;

-- The only supported operations in the hardware are:
-- ADDD, SUBD, MULD, BEQ, MOVD, MOVIL, MOVIH,
-- TLBWRITE, WRS, RDS, IRET


package core_defs is
    constant addr_bits                  : integer range 1 to 64 := 32;
    constant page_size                  : integer := 4096;
    constant page_bits                  : integer := integer(ceil(log2(real(page_size))));
    constant data_bits                  : integer range 1 to 64 := 32;
    constant num_exceptions             : integer := 16;
    constant exception_bits             : integer := integer(ceil(log2(real(num_exceptions))));
    
    constant instruction_bits           : integer := 32;
    constant opcode_bits                : integer := 8;
    constant opcode_type_bits           : integer := 2;
    
    constant ireg_num_registers         : integer := 32;
    constant ireg_id_bits               : integer := integer(ceil(log2(real(ireg_num_registers))));
    
    constant ireg_num_sp_registers      : integer := 4;
    constant ireg_sp_id_bits            : integer := integer(ceil(log2(real(ireg_num_registers))));
    
    constant fpreg_num_registers        : integer := 32;
    constant fpreg_id_bits              : integer := integer(ceil(log2(real(fpreg_num_registers))));
    
    
    -- Other types and functions
    subtype OPCODE is std_logic_vector (opcode_bits-1 downto 0);
    subtype OPCODER is std_logic_vector (opcode_bits+2-1 downto 0);
    
    -- INSTRUCTION ENCODING 
    --
    -------------------------------------------------------------------------------
    -- REGISTER OPS
    -- - Register - Register -
    -- |    opcode          |    rd         |    ra         |    rb        |   |   [DBWU]       |    LSBit  |
    -- 31                 24 23           19 18           14 13           9 8 8 7              6 5          0
    -- The LSBit field selects from which LSBit up to at most instruction_bits-1 the operation will be applied.
    -- Result stored in Rd starting at bit 0, always. If using LSBit, it is equivalent as an SHA to the right + ADD op.
    
    -- - Shift Arithmetic/Logic -
    -- |    opcode          |    rd         |    ra         |   rb/# Bits  | #B |     [DBWDI]    |    LSBit  |
    -- 31                 24 23           19 18           14 13           9 8  8 7              6 5          0
    -- Shift Ra as many bits as Rb or the immediate dictates. With 6 bits, 
    -- full register can be shifted left or right.
    -- Store in Rd. As with register-register operations, LSBits allows 
    -- to select the subset of bits to apply the operation. Sign extension applied to left or right if SHA. 0 fill if SHLogic.
    -- Bits field is represented in 2's Complement, hence, 6 bits: 32 positive values, 32 negative values.

    -- - Immediate - Register -
    -- |    opcode          |    rd         |ra/Imm/ImmLo/Hi|         ImmLo/Hi                  |
    -- 31                 24 23           19 18           14 13                                 0
    -- This instructions can write into Rd the number encoded in the immediate field. The 
    -- immediate can be half DWORD, that is, 16 bits or all the available bits, 19.
    -- The 16 bits immediate can be put into the lower or higher half of Rd.
    -- In the case of arithmetic operations, the immediate is added, subracted, multiplied, anded, ored
    -- xored with Ra in case of a Lo/Hi operation or with Rd, and written to Rd. Shift operates the same:
    -- put immediate in Rd and then shift the bits.
    

    constant ADDD                        : OPCODE := b"00_00_0000";
    constant ADDB                        : OPCODE := b"00_00_0000";
    constant ADDW                        : OPCODE := b"00_00_0000";
    constant ADDU                        : OPCODE := b"00_00_0000";
    constant ADDI                        : OPCODE := b"00_01_0000";
    constant ADDIL                       : OPCODE := b"00_10_0000";
    constant ADDIH                       : OPCODE := b"00_11_0000";
    constant ADD_OP                      : OPCODE := b"00_--_0000";
    constant SUBD                        : OPCODE := b"00_00_0001";
    constant SUBB                        : OPCODE := b"00_00_0001";
    constant SUBW                        : OPCODE := b"00_00_0001";
    constant SUBU                        : OPCODE := b"00_00_0001";
    constant SUBI                        : OPCODE := b"00_01_0001";
    constant SUBIL                       : OPCODE := b"00_10_0001";
    constant SUBIH                       : OPCODE := b"00_11_0001";
    constant SUB_OP                      : OPCODE := b"00_--_0001";
    constant MULD                        : OPCODE := b"00_00_0010";
    constant MULB                        : OPCODE := b"00_00_0010";
    constant MULW                        : OPCODE := b"00_00_0010";
    constant MULU                        : OPCODE := b"00_00_0010";
    constant MULI                        : OPCODE := b"00_01_0010";
    constant MULIL                       : OPCODE := b"00_10_0010";
    constant MULIH                       : OPCODE := b"00_11_0010";
    constant MUL_OP                      : OPCODE := b"00_--_0010";
                                                               
    constant ANDD                        : OPCODE := b"00_00_0011";
    constant ANDB                        : OPCODE := b"00_00_0011";
    constant ANDW                        : OPCODE := b"00_00_0011";
    constant ANDI                        : OPCODE := b"00_01_0011";
    constant ANDIL                       : OPCODE := b"00_10_0011";
    constant ANDIH                       : OPCODE := b"00_11_0011";
    constant AND_OP                      : OPCODE := b"00_--_0011";
    constant ORD                         : OPCODE := b"00_00_0100";
    constant ORB                         : OPCODE := b"00_00_0100";
    constant ORW                         : OPCODE := b"00_00_0100";
    constant ORI                         : OPCODE := b"00_01_0100";
    constant ORIL                        : OPCODE := b"00_10_0100";
    constant ORIH                        : OPCODE := b"00_11_0100";
    constant OR_OP                       : OPCODE := b"00_--_0100";
    constant XORD                        : OPCODE := b"00_00_0101";
    constant XORB                        : OPCODE := b"00_00_0101";
    constant XORW                        : OPCODE := b"00_00_0101";
    constant XORI                        : OPCODE := b"00_01_0101";
    constant XORIL                       : OPCODE := b"00_10_0101";
    constant XORIH                       : OPCODE := b"00_11_0101";
    constant XOR_OP                      : OPCODE := b"00_--_0101";
                                                               
    constant SHLD                        : OPCODE := b"00_00_0110";
    constant SHLDI                       : OPCODE := b"00_00_0110";
    constant SHLB                        : OPCODE := b"00_00_0110";
    constant SHLW                        : OPCODE := b"00_00_0110";
    constant SHLI                        : OPCODE := b"00_01_0110";
    constant SHLIL                       : OPCODE := b"00_10_0110";
    constant SHLIH                       : OPCODE := b"00_11_0110";
    constant SHL_OP                      : OPCODE := b"00_--_0110";
    constant SHAD                        : OPCODE := b"00_00_0111";
    constant SHADI                       : OPCODE := b"00_00_0111";
    constant SHAB                        : OPCODE := b"00_00_0111";
    constant SHAW                        : OPCODE := b"00_00_0111";
    constant SHAI                        : OPCODE := b"00_01_0111";
    constant SHAIL                       : OPCODE := b"00_10_0111";
    constant SHAIH                       : OPCODE := b"00_11_0111";
    constant SHA_OP                      : OPCODE := b"00_--_0111";
    constant SH_OP                       : OPCODE := b"00_--_011-";
                                                               
    constant MOVD                        : OPCODE := b"00_00_1000"; -- Move from one register to other.
    constant MOVI                        : OPCODE := b"00_01_1000"; -- Move 19 bits.
    constant MOVIL                       : OPCODE := b"00_10_1000"; -- Move 16 bits to lower half.
    constant MOVIH                       : OPCODE := b"00_11_1000"; -- Move 16 bits to higher half.
    constant MOV_OP                      : OPCODE := b"00_--_1000";
                                                               
    constant CMPEQ                       : OPCODE := b"00_00_1001";
    constant CMPEQU                      : OPCODE := b"00_01_1001";
    constant CMPNE                       : OPCODE := b"00_00_1010";
    constant CMPNEU                      : OPCODE := b"00_01_1010";
    constant CMPLT                       : OPCODE := b"00_00_1011";
    constant CMPLTU                      : OPCODE := b"00_01_1011";
    constant CMPGT                       : OPCODE := b"00_00_1100";
    constant CMPGTU                      : OPCODE := b"00_01_1100";
                                                               
    constant REG_OP                      : OPCODE := b"00_--_----";
    constant REG_OP_R                    : OPCODE := b"00_00_----";
    constant REG_OP_I                    : OPCODE := b"00_01_----"; -- The I suffix employs Rd as an implicit source register.
    constant REG_OP_IL                   : OPCODE := b"00_10_----";
    constant REG_OP_IH                   : OPCODE := b"00_11_----";

    constant REG_RD_L                    : integer := instruction_bits-1-opcode_bits;
    constant REG_RD_R                    : integer := REG_RD_L          -ireg_id_bits+1;
    constant REG_RA_L                    : integer := REG_RD_R          -1;
    constant REG_RA_R                    : integer := REG_RA_L          -ireg_id_bits+1;
    constant REG_RB_L                    : integer := REG_RA_R          -1;
    constant REG_RB_R                    : integer := REG_RB_L          -ireg_id_bits+1;
    constant REG_DBW_L                   : integer := REG_RB_R          -2;
    constant REG_DBW_R                   : integer := REG_DBW_L         -opcode_type_bits+1;
    constant REG_LSB_L                   : integer := REG_DBW_R         -1;
    constant REG_SHBITS_L                : integer := REG_RA_R          -1;
    constant REG_SHBITS_R                : integer := REG_DBW_L         +1;
    constant REG_ILH_L                   : integer := data_bits/2-1;
    constant REG_IM_L                    : integer := REG_RA_L;
    constant REG_I_R                     : integer := 0;
    
    -- MEMORY OPS
    -- |    opcode    |    rd    |    ra     |       offset         |
    -- 31           24 23      19 18       14 13                    0
    -- LD: rd <- M[ra+offset]. Load Byte/Word/Double Word from memory.
    -- ST: rd -> M[ra+offset]. Store Byte/Word/Double Word to memory.
    
    constant LDD                         : OPCODE := b"01_00_0000";
    constant LDW                         : OPCODE := b"01_01_0000";
    constant LDB                         : OPCODE := b"01_10_0000";
    constant STRD                        : OPCODE := b"01_00_0001";
    constant STRW                        : OPCODE := b"01_01_0001";
    constant STRB                        : OPCODE := b"01_10_0001";
                                                               
    constant MEM_OP                      : OPCODE := b"01_--_----";
    constant MEM_D_OP                    : OPCODE := b"01_00_----";
    constant MEM_W_OP                    : OPCODE := b"01_01_----";
    constant MEM_B_OP                    : OPCODE := b"01_10_----";
    constant LD_OP                       : OPCODE := b"01_--_0000";
    constant STR_OP                      : OPCODE := b"01_--_0001";
                                                               
    constant MEM_RD_L                    : integer := instruction_bits-1-opcode_bits;
    constant MEM_RD_R                    : integer := MEM_RD_L          -ireg_id_bits+1;
    constant MEM_RA_L                    : integer := MEM_RD_R          -1;
    constant MEM_RA_R                    : integer := MEM_RA_L          -ireg_id_bits+1;
    constant MEM_OFF_L                   : integer := MEM_RA_R          -1;
    constant MEM_OFF_R                   : integer := 0;
    
    -- BRANCH OPS
    -- - Conditional Jump (BEQ/R - BNEQ/R) -
    -- |    opcode    |    rd    |    ra     |   Offset             |
    -- 31           24 23      20 18       14 13                    0
    -- Non-R:   Jump to PC+4+   (sign_extend(offset)<<2) if (Rd == Ra || Rd != Ra)
    -- R:       Jump to Ra+     (sign_extend(offset)<<2) if (Rd == Ra || Rd != Ra) -- Yeah, jump if pointers are equal or not!
    
    -- - Conditional Jump (BZ/R - BNZ/R) -
    -- |    opcode    |    rd    | Offset/ra |   Offset             |
    -- 31           24 23      20 18       14 13                    0
    -- Non-R:   Jump to PC+4+   (sign_extend(offset)<<2) if (Rd == 0 || Rd != 0)
    -- R:       Jump to Ra+     (sign_extend(offset)<<2) if (Ra == 0 || Ra != 0)
    
    -- - Inconditional Jump (JMP/R) -
    -- |    opcode    |rd/Address|        Address/Offset            |
    -- 31           24 23      20 18                                0
    -- Non-R:   Jump to PC & address & 00
    -- R:       Jump to Rd + (sign_extend(offset)<<2)
    
    
    constant BEQ                         : OPCODE := b"10_00_0000";
    constant BEQR                        : OPCODE := b"10_01_0000";
    constant BEQ_OP                      : OPCODE := b"--_--_0000";

    constant BNEQ                        : OPCODE := b"10_00_0001";
    constant BNEQR                       : OPCODE := b"10_01_0001";
    constant BNEQ_OP                     : OPCODE := b"--_--_0001";
                                                               
    constant BZ                          : OPCODE := b"10_00_0010";
    constant BZR                         : OPCODE := b"10_01_0010";
    constant BZ_OP                       : OPCODE := b"--_--_0010";

    constant BNZ                         : OPCODE := b"10_00_0011";
    constant BNZR                        : OPCODE := b"10_01_0011";
    constant BNZ_OP                      : OPCODE := b"--_--_0011";
                                                               
    constant JMP                         : OPCODE := b"10_00_0100";
    constant JMPR                        : OPCODE := b"10_01_0100";
    constant JMP_OP                      : OPCODE := b"10_--_0100";
                                                               
    constant BR_OP                       : OPCODE := b"10_--_----";
    constant BR_NR_OP                    : OPCODE := b"10_00_----";
    constant BR_R_OP                     : OPCODE := b"10_01_----";
    constant BR_RD_L                     : integer := instruction_bits-1-opcode_bits;
    constant BR_RD_R                     : integer := BR_RD_L           -ireg_id_bits+1;
    constant BR_RA_L                     : integer := BR_RD_R           -1;
    constant BR_RA_R                     : integer := BR_RA_L           -ireg_id_bits;
    constant BR_OQ_L                     : integer := BR_RA_R           -1;
    constant BR_OI_L                     : integer := BR_RD_L;
    constant BR_O_R                      : integer := 0;
    
    -- OPERATING SYSTEM OPS
    constant RDS                         : OPCODE := b"11_00_0000";
    constant WRS                         : OPCODE := b"11_00_0001";
    constant TLBWRITE                    : OPCODE := b"11_00_0010";
    constant IRET                        : OPCODE := b"11_00_0011";
                                                               
    constant OS_OP                       : OPCODE := b"11_--_----";
                                                               
    -- NOP                                                     
    constant NOP                         : OPCODE := b"11_11_1111";
    
    -- L1 Instruction Cache parameters
    constant l1i_size                   : integer := 512;
    constant l1i_line_size              : integer := 128;
    constant l1i_line_bits              : integer := l1i_line_size*8;
    constant l1i_set_size               : integer := 2;
    constant l1i_lines                  : integer := l1i_size / l1i_line_size;
    constant l1i_sets                   : integer := l1i_lines / l1i_set_size;
    constant l1i_bil_bits               : integer := integer(ceil(log2(real(l1i_line_size))));    --byte in line
    constant l1i_set_in_bits            : integer := integer(ceil(log2(real(l1i_sets))));        --in set
    constant l1i_wis_bits               : integer := integer(ceil(log2(real(l1i_set_size))));         -- bits for way in set
    constant l1i_tag_bits               : integer := addr_bits-(l1i_set_in_bits+l1i_bil_bits);      --tag
    
    -- L1 Data Cache parameters
    constant l1d_size                   : integer := 512;
    constant l1d_line_size              : integer := 128;
    constant l1d_line_bits              : integer := l1d_line_size*8;
    constant l1d_set_size               : integer := 2;
    constant l1d_lines                  : integer := l1d_size / l1d_line_size;
    constant l1d_sets                   : integer := l1d_lines / l1d_set_size;
    constant l1d_bil_bits               : integer := integer(ceil(log2(real(l1d_line_size))));    --byte in line
    constant l1d_set_in_bits            : integer := integer(ceil(log2(real(l1d_sets))));        --in set
    constant l1d_wis_bits               : integer := integer(ceil(log2(real(l1d_set_size))));         -- bits for way in set
    constant l1d_tag_bits               : integer := addr_bits-(l1d_set_in_bits+l1d_bil_bits);      --tag
    
    -- ALU parameters
    constant alu_op_bits                : integer := 4;
        
    -- ROB parameters
    constant rob_num_entries            : integer := 4;
    constant rob_entry_bits             : integer := integer(ceil(log2(real(rob_num_entries))));
    
    -- Predictor Parameters

end core_defs;

package body core_defs is
    
end core_defs;
