all: src/*ls test/*ls lib/parser.js
	lsc -c -o lib src/
	lsc -c -o test test/

lib/parser.js: src/parser.pegjs
	./node_modules/.bin/pegjs src/parser.pegjs lib/parser.js

clean:
	rm -f lib/*
