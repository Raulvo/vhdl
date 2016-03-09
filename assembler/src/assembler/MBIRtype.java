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
 * This class serves as base type for the memory, conditional branch 
 * and immediate-register instructions.
 * Instruction format:
 * |    opcode    |    Rd    |    Ra     |   Offset             |
 * 31           24 23      20 18       14 13                    0
 * 
 * Example of instructions using this format are:
 * 
 * Load						(LD)
 * Store					(SD)
 * Branch if equal		 	(BEQ)
 * Addition with immediate	(ADDDI)
 */
public class MBIRtype extends Instruction {
	private static Pattern opsexp = null;
	private static Pattern labelp = null;
	private static Pattern offsetp = null;

	public MBIRtype(String op, Integer address) {
		super(op,address);
		if (opsexp == null) 
			opsexp = Pattern.compile("([ ]*r([0-9]{1,})[ ]*,[ ]*r([0-9]{1,})[ ]*,[ ]*(#-?[0-9]{1,}|0x-?[0-9]{1,}|.*))",Pattern.CASE_INSENSITIVE);
		if (labelp == null)
			labelp = Pattern.compile("([A-Z]{1,}[0-9]?{1,})", Pattern.CASE_INSENSITIVE);
		if (offsetp == null)
			offsetp = Pattern.compile("(#|0x)(-?[0-9]{1,})", Pattern.CASE_INSENSITIVE);
	}
	
	
	@Override
	public Integer getBinaryRepresentation() {
		Integer instruction = 0; //We start with a NOP.
		instruction = (0x000000FF & this.opcode) << Opcodes.bitsinst-Opcodes.bitsopcode;
		instruction = instruction | ((0x0000001F & this.rd) << (Opcodes.bitsinst-Opcodes.bitsopcode-Opcodes.bitsreg));
		instruction = instruction | ((0x0000001F & this.ra) << (Opcodes.bitsinst-Opcodes.bitsopcode-2*Opcodes.bitsreg));
		instruction = instruction | (0x00003FFF & this.offset);
		return instruction;
	}

	@Override
	public Boolean parseInstruction(String line)
			throws BadInstructionException {
		Matcher opmatcher = MBIRtype.opsexp.matcher(line);
		String offstring;
		opmatcher.reset();
		if (opmatcher.find()) {
			this.rd = Integer.parseInt(opmatcher.group(2));
			this.ra = Integer.parseInt(opmatcher.group(3));
			offstring = opmatcher.group(4);
		} else throw new BadInstructionException("No valid instruction operands");

		if (offstring.isEmpty()) throw new BadInstructionException("No offset operand found in MBIR instruction");
		Matcher labelmatcher = MBIRtype.labelp.matcher(offstring);
		Matcher offsetmatcher = MBIRtype.offsetp.matcher(offstring);
		if (offsetmatcher.find()) {
			String type = offsetmatcher.group(1);
			if (type.contains("#")) {
				this.offset = Integer.parseInt(offsetmatcher.group(2));
			} else if (type.contains("0x")) {
				this.offset = Integer.parseInt(offsetmatcher.group(2),16);
			} else throw new BadInstructionException("No valid instruction offset");
		} else if (labelmatcher.find()) {
			if (AssemblerParser.isDataLabel(offstring) && this.acceptsDataLabels()) {
				this.offset = AssemblerParser.getAddress(offstring);
			} else if (AssemblerParser.isCodeLabel(offstring) && this.acceptsCodeLabels()) {
				this.offset = (AssemblerParser.getAddress(offstring) - this.instaddress) >> 2;
			} else throw new BadInstructionException("Invalid label");
			
		} else throw new BadInstructionException("Invalid offset/label field");
		if (this.ra < 0 || this.ra > Opcodes.numregs-1 || this.rd < 0 || this.rd > Opcodes.numregs-1 
				|| this.offset < Opcodes.limitnegoffset || this.offset > Opcodes.limitposoffset) {
			throw new BadInstructionException("An instruction operand is out of range");
		}
		return true;
	}

}
