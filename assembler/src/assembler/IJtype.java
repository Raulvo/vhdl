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

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 
 * @author raul
 *
 * Immediate Jump
 * This class serves as base class for all Jump instructions which 
 * take a register as a base instead of being relative to the Program Counter
 * register. It is also employed for immediate instructions.
 * Instruction format:
 *  |    opcode    |     Rd   |        Address/Offset            |
 *  31           24 23      19 18                                0
 *  
 *  Example of instructions using this format are:
 *  
 *  Jump Register 	(JR)
 *  Move Immediate 	(MOVI)
 */
public abstract class IJtype extends Instruction {
	private static Pattern opsexp = null;
	private static Pattern labelp = null;
	private static Pattern offsetp = null;
	
	public IJtype(String opcode, Integer address) {
		super(opcode,address);
		if (opsexp == null)
			opsexp = Pattern.compile("([ ]*r([0-9]{1,})[ ]*,[ ]*((#-?|0x-?)([0-9]{1,})|[A-Z]{1,}[0-9]?{1,}))", 
					Pattern.CASE_INSENSITIVE);
		if (labelp == null)
			labelp = Pattern.compile("([A-Z]{1,}[0-9]?{1,})", Pattern.CASE_INSENSITIVE);
		if (offsetp == null)
			offsetp = Pattern.compile("((#-?|0x-?)([0-9]{1,}))", Pattern.CASE_INSENSITIVE);
	}
	@Override
	public Integer getBinaryRepresentation() {
		Integer instruction = 0;
		instruction = (0x000000FF & this.opcode) << Opcodes.bitsinst-Opcodes.bitsopcode;
		instruction = instruction | ((0x0000001F & this.rd) << (Opcodes.bitsinst-Opcodes.bitsopcode-Opcodes.bitsreg));
		instruction = instruction | (0x000FFFFF & this.offset);
		return 0;
	}

	@Override
	public Boolean parseInstruction(String operands)
			throws BadInstructionException {
		Matcher opmatcher = IJtype.opsexp.matcher(operands);
		String offstring;
		opmatcher.reset();
		if (opmatcher.find()) {
			this.rd = Integer.parseInt(opmatcher.group(2));
			offstring = opmatcher.group(3);
		} else throw new BadInstructionException("No valid instruction operands");

		if (offstring == null) throw new BadInstructionException("No offset operand found in MBIR instruction");
		else {
			Matcher labelmatcher = IJtype.labelp.matcher(offstring);
			Matcher offsetmatcher = IJtype.offsetp.matcher(offstring);
			if (offsetmatcher.find()) {
				String type = offsetmatcher.group(2);
				if (type.contains("#")) {
					this.offset = Integer.parseInt(offsetmatcher.group(3));
				} else if (type.contains("0x")) {
					this.offset = Integer.parseInt(offsetmatcher.group(3),16);
				} else throw new BadInstructionException("No valid instruction offset");
			} else if (labelmatcher.find()) {
				if (AssemblerParser.isDataLabel(offstring) && this.acceptsDataLabels()) {
					this.offset = AssemblerParser.getAddress(offstring);
				} else if (AssemblerParser.isCodeLabel(offstring) && this.acceptsCodeLabels()) {
					this.offset = (AssemblerParser.getAddress(offstring) - this.instaddress) >> 2;
				} else throw new BadInstructionException("Invalid label");
				
			} else throw new BadInstructionException("Invalid offset/label field");
			if (this.rd < 0 || this.rd > Opcodes.numregs-1 
					|| this.offset < Opcodes.limitnegoffset || this.offset > Opcodes.limitposoffset) {
				throw new BadInstructionException("An instruction operand is out of range");
			}
		}
		return true;
	}

}
