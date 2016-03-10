package assembler;

public class Movd extends Mov {
	public Movd(Integer address) {
		super(Opcodes.movd,address);
	}
}
