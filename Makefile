.PHONY: clean all

all:
	ghc --make Main.lhs -o gen_lexer
	
clean:
	rm *.hi *.o gen_lexer

