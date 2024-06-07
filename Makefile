.PHONY: clean docs

ENV ?=  
OPTS ?= --no-wasm-tail-call $(ENV)

plugin.wasm: plugin.gr http-wasm.gr
	grain compile $(OPTS) --wat plugin.gr  plugin.gr -o plugin.wasm 

docs:
	grain doc . -o . 

clean:
	rm -v -f *.wasm
	rm -v -f *.wat
	rm -v -f target
