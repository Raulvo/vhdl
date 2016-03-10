package assembler;

public abstract class Mov extends IJtype {
	public Mov(String op,Integer address) {
		super(op,address);
	}
	
	@Override
	public Boolean acceptsCodeLabels() {
		return false;
	}
	
	@Override
	public Boolean acceptsDataLabels() {
		return true;
	}
}
