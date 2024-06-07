
ENV ?= --release 
OPTS ?= --no-wasm-tail-call $(ENV)

plugin.wasm: plugin.gr http-wasm.gr
	grain compile $(OPTS) --wat plugin.gr  plugin.gr -o plugin.wasm 
	rm -rf target

clean:
	rm -v -f *.wasm
	rm -v -f *.wat
