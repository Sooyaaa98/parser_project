all: parser

parser: y.tab.c lex.yy.c
	gcc -o parser y.tab.c lex.yy.c -lfl -Wall -Wextra -O2

y.tab.c: parser.y
	bison -d -y -v parser.y

lex.yy.c: scanner.l
	flex --header-file=lex.yy.h scanner.l

clean:
	rm -f parser y.tab.c y.tab.h lex.yy.c lex.yy.h *.output

test: parser
	./parser < test_input.txt

.PHONY: all clean test
