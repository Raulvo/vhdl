all:
	javac -cp . asm.java
	jar cvef asm asm.jar *.class assembler

install: 
	cp asm.jar ../bin/

clean:
	rm *.class *.jar assembler/*.class
