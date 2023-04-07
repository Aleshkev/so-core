.PHONY: all test clean

all: example test test_c

gcc = gcc -c -Wall -Wextra -std=c17 -g -Og

core.o: core.asm debug_macros.asm
	nasm -DN=XXX -f elf64 -w+all -w+error -o $@ $<

example.o: example.c
	$(gcc) -o $@ $<

example: core.o example.o
	gcc -g -z noexecstack -pthread -o $@ $^

official:
	nasm -DN=2 -f elf64 -w+all -w+error -o core.o core.asm;
	gcc -c -Wall -Wextra -std=c17 -O2 -o example.o example.c;
	gcc -z noexecstack -pthread -o example core.o example.o

clean:
	rm -rf *.o ./example
