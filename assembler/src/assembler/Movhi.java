package assembler;

public class Movhi extends IJtype {
	public Movhi(Integer address) {
		super(Opcodes.movhi,address);
	}
}
