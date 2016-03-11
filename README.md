A pipelined processor
=

This repository contains VHDL and Java sources for what form 
a core distribution of a processor.

## The processor
To be written

## About Assembler
The assembler program allows to compile assembly files for the processor 
it is being distributed with.
It requires:

* a Java installation. It has been tested under
OpenJDK 1.7 on Ubuntu 14.04 LTS.

* GNU Make if you use the provided Makefile.

### Compiling
#### With GNU Make
Enter into src directory an execute:
```
$ make
$ make install
```

You will have now a /bin directory and a JAR file 
(asm.jar).

#### With Java Compiler
Enter into src directory and execute:
```
$ javac -cp . asm.java
$ jar cvef asm asm.jar *.class assembler
```


### Running ###
To compile an assembly file, just use:
```
$ java -jar asm.jar <source.asm> <output.bin>
```
