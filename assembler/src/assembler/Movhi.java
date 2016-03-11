package assembler;

public class Movhi extends IJtype {
	public Movhi(Integer address) {
		super(Opcodes.movhi,address);
	}
	
	@Override
	public Boolean acceptsCodeLabels() {
		return false;
	}
}
