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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.SortedMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.FileWriter;
import java.io.IOException;

public class AssemblerParser {
	private ArrayList<Instruction> instructions;
	private HashMap<String,Data> datas;
	private HashMap<String,Data> codelabels;
	
	public static final Integer DATASEGSIZE = 512;
	private static AssemblerParser parser;
	
	/* We need two passes: 1 for labels, another for replacing them with 
	 * actual offsets and address
	 */
	public static AssemblerParser getAssemblerParser() {
		if (parser != null) return parser;
		else {
			parser = new AssemblerParser();
			return parser;
		}
	}
	
	private AssemblerParser() {
		this.instructions = new ArrayList<Instruction>();
		this.datas = new HashMap<String,Data>();
		this.codelabels = new HashMap<String,Data>();
	}
	
	public void parseFile(String path) {
		BufferedReader filereader;
		String line;
		String label;
		String type;
		String data;
		String instop;
		Integer lastdataaddress = 0;
		Integer lastcodeaddress = DATASEGSIZE;
		Integer counter = 1;
		Boolean textfound = false;
		Boolean datafound = false;
		Pattern stringData = Pattern.compile("\"(.*?)\"",Pattern.CASE_INSENSITIVE);
		Pattern intData = Pattern.compile("-?[0-9]{1,}\\w",Pattern.CASE_INSENSITIVE);
		Pattern stringOp = Pattern.compile("(nop|halt|addd|subd|movd|movi|movhi|ld|sd|jmp|beq)",Pattern.CASE_INSENSITIVE);
		Matcher stringMatcher;
		Matcher intMatcher;
		Matcher opMatcher;
		try {
			/* Pass 1 */
			filereader = new BufferedReader(new FileReader(path));
			while ((line = filereader.readLine()) != null) {
				if (line.isEmpty()) {counter++; continue;}
				else if (line.matches("\\.data")) { datafound = true; counter++;continue;}
				else if (line.matches("\\.text") && !datafound) {
					counter++;
					filereader.close();
					throw new IllegalAsmNoSectionException(".data");
				} else if (line.matches("\\.text") && datafound) {
					textfound = true;
					counter++;
					continue;
				} else if (datafound && !textfound) {
					label = line.split(":")[0];
					if (line.contains(".string")) {
						type = "string";
						stringMatcher = stringData.matcher(line);
						if (stringMatcher.find()) {
							data = stringMatcher.group();
							data = AssemblerParser.padString(data);
							if (!datas.containsKey(label))
								datas.put(label,new Data(data,lastdataaddress,type,label));
							else {
								filereader.close();
								throw new IllegalAsmException("Repeated label. Check your code. Line "+counter);
							}
						} else {
							filereader.close();
							throw new IllegalAsmException("No valid string variable found at line "+counter);
						}
						lastdataaddress += data.length()+data.length()%Opcodes.bytesinst;
					} else if (line.contains(".int")) {
						type = "int";
						intMatcher = intData.matcher(line);
						if (intMatcher.find()) {
							data = intMatcher.group();
							if (!datas.containsKey(label))
								datas.put(label,new Data(data,lastdataaddress,type,label));
							else {
								filereader.close();
								throw new IllegalAsmException("Repeated label. Check your code. Line "+counter);
							}
						} else {
							filereader.close();
							throw new IllegalAsmException("No valid string variable found at line "+counter);
						}
						lastdataaddress += Opcodes.bytesinst;
					}
				} else if (textfound && datafound) {
					label = line.split(":")[0];
					if (!label.isEmpty() && !label.equals(line)) {
						data = label;
						if (!codelabels.containsKey(label)) {
							codelabels.put(label,new Data(data,lastcodeaddress,null,label));
						} else {
							filereader.close();
							throw new IllegalAsmException("Repeated label. Check your code. Line "+counter);
						}
					}
					lastcodeaddress += Opcodes.bytesinst;
				} else {
					filereader.close();
					throw new IllegalAsmException("Undefined section error. "+ 
					"No matching case for processing code. " + 
							"Please respect section order.");
				}
				counter++;
			}
			filereader.close();
			if (lastdataaddress > lastcodeaddress || lastdataaddress%Opcodes.bytesinst != 0)
				throw new IllegalAsmDataSizeException();
			counter = 1;
			/* Pass 2 */
			filereader = new BufferedReader(new FileReader(path));
			textfound = false;
			lastcodeaddress = DATASEGSIZE;
			while ((line = filereader.readLine()) != null) {
				if (!textfound) {
					if (line.matches(".text")) {
						textfound = true;
						counter++;
						continue;
					}
				} else if (textfound && line.matches(".text")) {counter++;continue;}
				else if (line.isEmpty()) {counter++; continue;}
				else if (line.equals(".data") && textfound) {
					filereader.close();
					throw new IllegalAsmMisplacedSectionException(".data");
				} else {
					opMatcher = stringOp.matcher(line);
					opMatcher.reset();
					if (opMatcher.find()) instop = opMatcher.group();
					else {
						filereader.close();
						throw new IllegalAsmException("No opcode found");
					}
					instop = instop.toLowerCase();
					Instruction inst = Instruction.NewInstruction(instop, lastcodeaddress);
					inst.parseInstruction(line);
					instructions.add(inst);
					lastcodeaddress+=Opcodes.bytesinst;
				}
				counter++;
			}
			filereader.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
			System.err.println("Error opening file. File not found");
			System.err.println("Error while parsing line " + counter);
		} catch (IllegalAsmException e){
			e.printStackTrace();
			System.err.println(e.getMessage());
			System.err.println("Error while parsing line " + counter);
		} catch (BadInstructionException e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
			System.err.println("Error while parsing line " + counter);
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
			System.err.println("Error while parsing line " + counter);
		}
	}
	
	public void dumpObjFile(String path) {
		try {
			FileOutputStream writer = new FileOutputStream(path);
			List<Data> datacol = new ArrayList<Data>(datas.values());
			Collections.sort(datacol);
			Data lastdata = null;
			for (Data d : datacol) {
				if (d.getType().equals("int")) {
					Integer number = Integer.parseInt(d.getData());
					writer.write(AssemblerParser.intToByteArray(number));
				} else {
					Integer length = d.getData().length();
					String content = d.getData();
					if (length%Opcodes.bytesinst != 0) content = AssemblerParser.padString(content);
					writer.write(content.getBytes());
				}
				lastdata = d;
			}
			if (lastdata != null) {
				Integer dataend = lastdata.getAddress()+lastdata.getData().length();
				if ( dataend < 512) {
					for (int i = 0; i < 512-dataend; i++) {
						writer.write("0".getBytes());
					}
				}
			}
			for (Instruction i : instructions) {
				writer.write(AssemblerParser.intToByteArray(i.getBinaryRepresentation()));
			}
			writer.close();
		} catch (IOException e) {
			e.printStackTrace();
			System.err.println(e.getMessage());
			System.err.println("Error while opening file for writing");
		}
	}

	public static boolean isDataLabel(String label) {
		return parser.datas.containsKey(label);
	}
	public static boolean isCodeLabel(String label) {
		return parser.codelabels.containsKey(label);		
	}

	public static Integer getDataAddress(String label) {
		return parser.datas.get(label).getAddress();
	}
	public static Integer getCodeAddress(String label) {
		return parser.codelabels.get(label).getAddress();
	}
	
	public static Integer getAddress(String label) {
		Integer addr = null;
		if (parser.datas.containsKey(label))
			addr = parser.datas.get(label).getAddress();
		else if (parser.codelabels.containsKey(label))
			addr = parser.codelabels.get(label).getAddress();
		return addr;
	}
	
	public static String getData(String label) {
		String d = null;
		if (parser.datas.containsKey(label))
			d = parser.datas.get(label).getData();
		else if (parser.codelabels.containsKey(label))
			d = parser.codelabels.get(label).getData();
		return d;
	}
	
	public static String getDataType(String label) {
		if (parser.datas.containsKey(label))
			return parser.datas.get(label).getType();
		else if (parser.codelabels.containsKey(label))
			return parser.codelabels.get(label).getType();
		else return null;
	}
	
	public static String padString(String sequence) {
		Integer padding = sequence.length()%Opcodes.bytesinst;
		for (int i = 0; i < padding; i++)
			sequence = sequence.concat("0");
		return sequence;
	}
	
	public static byte[] intToByteArray(Integer number) {
		byte[] bytes = new byte[Opcodes.bytesinst];
		Integer b0 = (number & 0xFF000000) >> 24;
		Integer b1 = (number & 0x00FF0000) >> 16;
		Integer b2 = (number & 0x0000FF00) >> 8;
		Integer b3 = (number & 0x000000FF);
		bytes[0] = b0.byteValue();
		bytes[1] = b1.byteValue();
		bytes[2] = b2.byteValue();
		bytes[3] = b3.byteValue();
		return bytes;
	}
}
