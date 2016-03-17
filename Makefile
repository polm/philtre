all: src/*ls test/*ls
	lsc -c -o lib src/
	lsc -c -o test test/

clean:
	rm -f lib/*
