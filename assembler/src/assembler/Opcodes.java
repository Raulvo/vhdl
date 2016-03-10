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

public final class Opcodes {
	public static final String nop 	= 	"00000000";
	public static final String halt = 	"11111111";
	public static final String addd = 	"00000001";
	public static final String subd = 	"00000010";
	public static final String movd = 	"00001001";
	public static final String movi = 	"00011001";
	public static final String movhi = 	"00101001";
	public static final String ld 	= 	"01000000";
	public static final String sd 	= 	"01000001";
	public static final String jmp 	= 	"10000100";
	public static final String beq 	= 	"10000000";
	public static final Integer bitsinst	= 32;
	public static final Integer bytesinst	= bitsinst/8;
	public static final Integer bitsopcode	= 8;
	public static final Integer bitsreg		= 5;
	public static final Integer numregs		= (int) Math.pow(2, Opcodes.bitsreg);
	public static final Integer bitsaddress = 32;
	public static final Integer bitsoffset 	= 14;
	public static final Integer bitsimmmov  = 19;
	public static final Integer bitsjmpaddr = 24;
	public static final Integer limitposaddr	= (int) Math.pow(2,Opcodes.bitsaddress-1)-1;
	public static final Integer limitnegaddr	= 0;
	public static final Integer limitposoffset 	= (int) Math.pow(2, Opcodes.bitsoffset-1)-1;
	public static final Integer limitnegoffset 	= (int) -(Math.pow(2, Opcodes.bitsoffset-1));
	public static final Integer limitposimmov 	= (int) Math.pow(2, Opcodes.bitsimmmov-1)-1;
	public static final Integer limitnegimmov 	= (int) -(Math.pow(2, Opcodes.bitsimmmov-1));
	public static final Integer limitposjmpaddr = (int) Math.pow(2, Opcodes.bitsjmpaddr-1)-1;
	public static final Integer limitnegjmpaddr = (int) -(Math.pow(2, Opcodes.bitsjmpaddr-1));
	
	
	private Opcodes() {}
	
	public static String OpStringToOpcode(String op) {
		switch (op) {
			case "nop":
				return Opcodes.nop;
			case "halt":
				return Opcodes.halt;
			case "addd":
				return Opcodes.addd;
			case "subd":
				return Opcodes.subd;
			case "movd":
				return Opcodes.movd;
			case "movi":
				return Opcodes.movi;
			case "movhi":
				return Opcodes.movhi;
			case "ld":
				return Opcodes.ld;
			case "sd":
				return Opcodes.sd;
			case "jmp":
				return Opcodes.jmp;
			case "beq":
				return Opcodes.beq;
		}
		return null;
	}
	
	public static String addZeroes(String binary, Integer size) {
		if (binary.length() < size) {
			Integer distance = size-binary.length();
			for (int i = 0; i < distance; i++) {
				binary = "0".concat(binary);
			}
		}
		return binary;
	}
	
	public static String trimOnes(String binary, Integer size) {
		Integer distance = binary.length() - size;
		return binary.substring(distance);
	}
}
