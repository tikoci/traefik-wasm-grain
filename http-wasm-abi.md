---
title: HttpWasmAbi
---

Provides low-level access to [http-wasm ABI](https://http-wasm.io/http-handler-abi/)

## Values

Functions and constants included in the HttpWasmAbi module.

### HttpWasmAbi.**_log**

```grain
_log : (WasmI32, WasmI32, WasmI32) => Void
```

### HttpWasmAbi.**_getConfig**

```grain
_getConfig : (WasmI32, WasmI32) => WasmI32
```

### HttpWasmAbi.**_enableFeatures**

```grain
_enableFeatures : WasmI32 => WasmI32
```

### HttpWasmAbi.**_logEnabled**

```grain
_logEnabled : WasmI32 => WasmI32
```

### HttpWasmAbi.**_getHeaderNames**

```grain
_getHeaderNames : (WasmI32, WasmI32, WasmI32) => WasmI64
```

### HttpWasmAbi.**_getHeaderValues**

```grain
_getHeaderValues : (WasmI32, WasmI32, WasmI32, WasmI32, WasmI32) => WasmI64
```

### HttpWasmAbi.**_setHeaderValue**

```grain
_setHeaderValue : (WasmI32, WasmI32, WasmI32, WasmI32, WasmI32) => Void
```

### HttpWasmAbi.**_addHeaderValue**

```grain
_addHeaderValue : (WasmI32, WasmI32, WasmI32, WasmI32, WasmI32) => Void
```

### HttpWasmAbi.**_removeHeader**

```grain
_removeHeader : (WasmI32, WasmI32, WasmI32) => Void
```

### HttpWasmAbi.**_readBody**

```grain
_readBody : (WasmI32, WasmI32, WasmI32) => WasmI64
```

### HttpWasmAbi.**_writeBody**

```grain
_writeBody : (WasmI32, WasmI32, WasmI32) => Void
```

### HttpWasmAbi.**_getMethod**

```grain
_getMethod : (WasmI32, WasmI32) => WasmI32
```

### HttpWasmAbi.**_setMethod**

```grain
_setMethod : (WasmI32, WasmI32) => Void
```

### HttpWasmAbi.**_getUri**

```grain
_getUri : (WasmI32, WasmI32) => WasmI32
```

### HttpWasmAbi.**_setUri**

```grain
_setUri : (WasmI32, WasmI32) => Void
```

### HttpWasmAbi.**_getProtocolVersion**

```grain
_getProtocolVersion : (WasmI32, WasmI32) => WasmI32
```

### HttpWasmAbi.**_getSourceAddr**

```grain
_getSourceAddr : (WasmI32, WasmI32) => WasmI32
```

### HttpWasmAbi.**_getStatusCode**

```grain
_getStatusCode : () => WasmI32
```

### HttpWasmAbi.**_setStatusCode**

```grain
_setStatusCode : WasmI32 => Void
```

