/*******************************************************************************
 *     Copyright (c) 2016 Raul Vidal Ortiz.
 *     
 *     This file is part of Assembler.
 *
 *     Assembler is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Assembler is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with Assembler.  If not, see <http://www.gnu.org/licenses/>.
 *******************************************************************************/
package assembler;

import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
/**
 * 
 * @author raul
 *
 * This class serves as base class for all Register-Register 
 * instructions.
 * Instruction format:
 * |    opcode      |    rd     |    ra     |    rb    |   |   [DBWU]   |    LSBit  |
 * 31             24 23       19 18       14 13       9 8 8 7          6 5          0
 *
 *
 * Additional comments:
 * Currently only opcode, Rd, Ra and Rb fields are being used. The rest of bits remain unused.
 * 
 * Example of instructions using this are:
 * Addition		 	(ADDD)
 * Subtraction		(SUBD)
 * Multiplication	(MULD)
 * 
 */
public abstract class Rtype extends Instruction {
	private static Pattern opsexp = null;
	
	public Rtype() {
		super();
		if (opsexp == null)
			opsexp = Pattern.compile("([ ]*r([0-9]{1,})[ ]*,[ ]*r([0-9]{1,})[ ]*,[ ]*r([0-9]{1,})[ ]*)", Pattern.CASE_INSENSITIVE);
	}
	public Rtype(String opcode, Integer address) {
		super(opcode,address);
		this.zerofillsize = Opcodes.bitsinst - 3*Opcodes.bitsreg;
		if (opsexp == null)
			opsexp = Pattern.compile("([ ]*r([0-9]{1,})[ ]*,[ ]*r([0-9]{1,})[ ]*,[ ]*r([0-9]{1,})[ ]*)", Pattern.CASE_INSENSITIVE);
	}
	
	@Override
	public Integer getBinaryRepresentation() {
		Integer instruction = 0; //We start with a NOP.
		instruction = (0x000000FF & this.opcode) << Opcodes.bitsinst-Opcodes.bitsopcode;
		instruction = instruction | ((0x0000001F & this.rd) << (Opcodes.bitsinst-Opcodes.bitsopcode-Opcodes.bitsreg));
		instruction = instruction | ((0x0000001F & this.ra) << (Opcodes.bitsinst-Opcodes.bitsopcode-2*Opcodes.bitsreg));
		instruction = instruction | ((0x0000001F & this.rb) << (Opcodes.bitsinst-Opcodes.bitsopcode-3*Opcodes.bitsreg));
		instruction = instruction | (0x000001FF & 0);
		return instruction;
	}
	
	@Override
	public Boolean parseInstruction(String operands) throws BadInstructionException {
		Matcher opmatcher = opsexp.matcher(operands);
		opmatcher.reset();
		if (opmatcher.find()) {
			this.rd = Integer.parseInt(opmatcher.group(2));
			this.ra = Integer.parseInt(opmatcher.group(3));
			this.rb = Integer.parseInt(opmatcher.group(4));
		} else throw new BadInstructionException("No valid instruction operands");

		if (this.ra < 0 || this.ra > Opcodes.numregs-1 || this.rd < 0 || this.rd > Opcodes.numregs-1 
				|| this.rb < 0 || this.rb > Opcodes.numregs-1) {
			throw new BadInstructionException("An instruction operand is out of range");
		}
		return true;
	}

}
