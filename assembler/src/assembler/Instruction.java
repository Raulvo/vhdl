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

import java.util.regex.Pattern;

public abstract class Instruction {
	protected Integer instaddress;
	protected Integer opcode;
	protected Integer rd,ra,rb;
	protected Integer imm;
	protected Integer offset,address;
	protected Integer zerofillsize;
	protected String label;
	protected Pattern whitespace;
	
	public Instruction() {
		this.whitespace = Pattern.compile("(\\s+)",Pattern.CASE_INSENSITIVE);
		this.opcode = Integer.parseInt(Opcodes.nop,2);
		this.setZeroAll();
		this.instaddress = 0;
		this.label = "";
	}
	
	public Instruction(Integer address) {
		this.opcode = Integer.parseInt(Opcodes.nop,2);
		this.instaddress = address;
		this.setZeroAll();
		this.label = "";
	}
	
	public Instruction(Integer op, Integer address) {
		this.opcode = op;
		this.instaddress = address;
		this.setZeroAll();
		this.label = "";
	}
	
	public Instruction(String op, Integer address) {
		this.opcode = Integer.parseInt(op,2);
		this.instaddress = address;
		this.setZeroAll();
		this.label = "";
	}
	
	public Boolean setZeroAll() {
		this.rd = 0;
		this.ra = 0;
		this.rb = 0;
		this.imm = 0;
		this.offset = 0;
		this.address = 0;
		this.zerofillsize = 0;
		return true;
	}
	
	public Boolean setInstAddress(Integer address) {
		this.instaddress = address;
		return true;
	}
	
	public Integer getInstAddress() {
		return this.instaddress;
	}
	
	public Integer getOpcode() {
		return this.opcode;
	}
	
	public Integer getRd() {
		return this.rd;
	}
	
	public Integer getRa() {
		return this.ra;
	}
	
	public Integer getRb() {
		return this.rb;
	}
	
	public Integer getImm() {
		return this.imm;
	}
	
	public Integer getOffset() {
		return this.offset;
	}
	
	public Integer getAddress() {
		return this.address;
	}
	
	public String getOpcodeBinString() {
		return Integer.toBinaryString(this.opcode);
	}
	
	public String getRdBinString() {
		return Integer.toBinaryString(this.opcode);
	}
	
	public String getRaBinString() {
		return Integer.toBinaryString(this.ra);
	}
	
	public String getRbBinString() {
		return Integer.toBinaryString(this.rb);
	}
	
	public String getImmBinString() {
		return Integer.toBinaryString(this.imm);
	}
	
	public String getOffsetBinString() {
		return Integer.toBinaryString(this.offset);
	}
	
	public String getAddressBinString() {
		return Integer.toBinaryString(this.address);
	}
	
	public static String stringConstantToStringBinary(String constant) {
		String binaddress = null;
		String[] splitted;
		String first = constant.substring(0, 1);
		splitted = constant.split(first,2);
		
		if (first.equals("#")) binaddress = Integer.toBinaryString(Integer.parseInt(splitted[0], 10));
		else if (first.equals("x")) binaddress = Integer.toBinaryString(Integer.parseInt(splitted[0], 16));
		return binaddress;
	}
	
	public static Instruction NewInstruction(String op) {
		return Instruction.NewInstruction(op, 0);
	}
	
	public static Instruction NewInstruction(String op, Integer address) {
		switch (op) {
			case "nop":
				return new Nop(address);
			case "halt":
				return new Halt(address);
			case "addd":
				return new Addd(address);
			case "subd":
				return new Subd(address);
			case "movd":
				return new Movd(address);
			case "movi":
				return new Movi(address);
			case "movhi":
				return new Movhi(address);
			case "ld":
				return new Ld(address);
			case "sd":
				return new Sd(address);
			case "jmp":
				return new Jmp(address);
			case "beq":
				return new Beq(address);
		}
		return null;
	}
	
	public abstract Integer getBinaryRepresentation();
	public abstract Boolean parseInstruction(String operands) throws BadInstructionException;
	public Boolean acceptsDataLabels() {
		return true;
	}
	public Boolean acceptsCodeLabels() {
		return true;
	}
}
