.PHONY: all clean

all: example

gcc = gcc -c -Wall -Wextra -std=c17 -g -Og

core.o: core.asm debug_macros.asm
	nasm -DN=2 -f elf64 -w+all -w+error -gdwarf -o $@ $<

example.o: example.c
	$(gcc) -o $@ $<

example_2.o: example_2.c
	$(gcc) -o $@ $<

example_2: example_2.o
	gcc -g -z noexecstack -pthread -no-pie -fno-pie -o $@ $^

example: core.o example.o
	# -no-pie -fno-pie is needed so that fputs etc. can be called
	gcc -g -z noexecstack -pthread -no-pie -fno-pie -o $@ $^

official:
	nasm -DN=2 -f elf64 -w+all -w+error -o core.o core.asm;
	gcc -c -Wall -Wextra -std=c17 -O2 -o example.o example.c;
	gcc -z noexecstack -pthread -o example core.o example.o

clean:
	rm -rf *.o ./example
