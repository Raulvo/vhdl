all:
	javac -cp . asm.java
	jar cvef asm asm.jar *.class assembler

install: 
	mkdir -p ../bin
	cp asm.jar ../bin/

clean:
	rm *.class *.jar assembler/*.class
