---
title: TraefikGrainPlugin
---

Experimental Traefik plugin using WASM and Grain.  
This is the "main" code for the plugin, and where any operations can be preformed on HTTP requests or responses. 
Examples here include using Grain's [Pattern Matching](https://grain-lang.org/docs/guide/pattern_matching) on requests to take some actions.

> Traefik invokes a WASM plugin by call `handle_request` and `handle_response` exports. 
> Since these require unsafe pointers, `HttpWasm` module wraps them.  So Grain-based "callbacks" can use `registerRequestHandler` or `registerResponseHandler` to avoid needing unsafe code.   
> But for Traefik's [http-wasm](https://http-wasm.io/) host to find them, the `plugin.gr` must expose these, which just uses the implemention in `WasmHttp` to call any registered handlers here.

## Values

Functions and constants included in the TraefikGrainPlugin module.

### TraefikGrainPlugin.**handle_request**

```grain
handle_request : () => WasmI64
```

### TraefikGrainPlugin.**handle_response**

```grain
handle_response : (high: WasmI32, low: WasmI32) => Void
```

