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

public class Data implements Comparable<Data> {
	private String data;
	private Integer startingaddress;
	private String type;
	private String label;
	public Data(String data, Integer lastdataaddress, String type, String label) {
		this.data = data;
		this.startingaddress = lastdataaddress;
		this.type = type;
		this.label = label;
	}
	
	public Boolean containsLabel(String lbl) {
		return this.label.equals(lbl);
	}
	
	public Integer getAddress() {
		return this.startingaddress;
	}
	
	public String getData() {
		return this.data;
	}
	
	public String getType() {
		return this.type;
	}

	@Override
	public int compareTo(Data o) {
		if (this == o) return 0;
		if (o.startingaddress == this.startingaddress)
			return 0;
		if (this.startingaddress > o.startingaddress)
			return 1;
		if (this.startingaddress < o.startingaddress)
			return -1;
		return 0;
	}
	
	
}
