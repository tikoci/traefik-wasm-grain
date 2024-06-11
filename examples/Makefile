.PHONY: all docs clean
.SUFFIXES: 

ENV ?=  
OPTS ?= --no-wasm-tail-call $(ENV)
SUBDIRS := $(wildcard */)

%plugin.wasm: %plugin.gr
	grain compile $(OPTS) $< -o $@ 

%plugin.md: %plugin.gr
	grain doc $< -o $@ 

# build a plugin.wasm in each example directory
all: $(SUBDIRS:%=%plugin.wasm) docs

docs: $(SUBDIRS:%=%plugin.md) 

# TODO: quick Makefile hack to avoid removing target.
target/plugin.wasm: 
target/plugin.md: 

clean:
	rm -v -f -r target
	rm -v -f -r $(SUBDIRS:%=%plugin.wasm)
	rm -v -f -r $(SUBDIRS:%=%plugin.md)