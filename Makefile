.PHONY: all build zip scp examples docs clean  

ENV ?=  
OPTS ?= --no-wasm-tail-call $(ENV)
SSH_HOST ?= admin@192.168.88.1

%.wasm: %.gr 
	grain compile $(OPTS) --wat $< $< -o $@ 

all: examples plugin.wasm 

plugin.wasm: plugin.gr ./lib/*.gr 

zip: plugin.wasm .traefik.yml icon.png readme.md icon.png
	mkdir -p build
	zip $(notdir $(CURDIR)) $^

scp:
	scp plugin.wasm '$(SSH_HOST):/traefik-plugins/traefik-wasm-grain/plugin.wasm' 
	ssh $(SSH_HOST) '$$proxyrestart; $$proxytail'

examples:
	$(MAKE) -C ./examples

docs:
	grain doc . -o .

clean:
	rm -v -f -r target
	rm -v -f *.wasm lib/*.wasm
	rm -v -f *.wat lib/*.wat
	$(MAKE) -C ./examples clean
