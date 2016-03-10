package assembler;

public class Movd extends MBIRtype {
	public Movd(Integer address) {
		super(Opcodes.movd,address);
		this.needsoffset = false;
	}
}
