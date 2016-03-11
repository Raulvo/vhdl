all:
	javac -cp . asm.java
	jar cvef asm asm.jar *.class assembler

install: all
	mkdir -p ../bin
	cp asm.jar ../bin/

clean:
	rm *.class *.jar assembler/*.class
