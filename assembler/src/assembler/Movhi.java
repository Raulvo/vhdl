package assembler;

public class Movhi extends Mov {
	public Movhi(Integer address) {
		super(Opcodes.movhi,address);
	}
}
