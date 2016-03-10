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
 * Jump
 * This class serves as base class for Jump instructions which 
 * do not take any register as relative address.
 * 
 * Instruction format:
 * |    opcode    |              Address/Offset                 |
 * 31           24 23                                           0
 * 
 * 
 * Example of instructions needing this are:
 * Jump 			(JMP)
 * Jump and Link 	(JAL)
 * Return			(RET)
 */
public class Jtype extends Instruction {
	private static Pattern opsexp = null;
	private static Pattern labelp = null;
	private static Pattern offsetp = null;
	
	public Jtype(String opcode, Integer address) {
		super(opcode,address);
		if (opsexp == null)
			opsexp = Pattern.compile("[A-Z][ ]{1,}([ ]*((#-?|0x-?)([0-9]{1,})|[A-Z]{1,}[0-9]?{1,}))", Pattern.CASE_INSENSITIVE); //Jump
		if (labelp == null)
			labelp = Pattern.compile("([A-Z]{1,}[0-9]?{1,})", Pattern.CASE_INSENSITIVE);
		if (offsetp == null)
			offsetp = Pattern.compile("((#-?|0x-?)([0-9]{1,}))", Pattern.CASE_INSENSITIVE);
	}
	@Override
	public Integer getBinaryRepresentation() {
		Integer instruction = 0; //We start with a NOP.
		instruction = (0x000000FF & this.opcode) << Opcodes.bitsinst-Opcodes.bitsopcode;
		instruction = instruction | (0x0007FFFF & this.offset);
		return instruction;
	}

	@Override
	public Boolean parseInstruction(String operands)
			throws BadInstructionException {
		Matcher opmatcher = Jtype.opsexp.matcher(operands);
		String offstring;
		opmatcher.reset();
		if (opmatcher.find()) {
			offstring = opmatcher.group(2);
		} else throw new BadInstructionException("No valid instruction operands");
		if (offstring == null) throw new BadInstructionException("No offset operand found in J instruction");
		else {
			Matcher labelmatcher = Jtype.labelp.matcher(offstring);
			Matcher offsetmatcher = Jtype.offsetp.matcher(offstring);
			labelmatcher.reset(); offsetmatcher.reset();
			if (offsetmatcher.find()) {
				String type = offsetmatcher.group(2);
				if (type.contains("#")) {
					this.offset = Integer.parseInt(offsetmatcher.group(3));
				} else if (type.contains("0x")) {
					this.offset = Integer.parseInt(offsetmatcher.group(3),16);
				} else throw new BadInstructionException("No valid instruction offset");
			} else if (labelmatcher.find()) {
				if (AssemblerParser.isCodeLabel(offstring) && this.acceptsCodeLabels()) {
					this.offset = (AssemblerParser.getAddress(offstring) - this.instaddress) >> 2;
				} else throw new BadInstructionException("Invalid label");
				
			} else throw new BadInstructionException("Invalid offset/label field");
			if (this.offset < Opcodes.limitnegoffset || this.offset > Opcodes.limitposoffset) {
				throw new BadInstructionException("An instruction operand is out of range");
			}
		}
		return true;
	}

}
