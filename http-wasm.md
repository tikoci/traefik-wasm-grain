---
title: HttpWasm
---

Grain API for [http-wasm ABI](https://http-wasm.io/http-handler-abi/)

## Types

Type declarations included in the HttpWasm module.

### HttpWasm.**Request**

```grain
record Request {
  method: String,
  path: String,
  headers: List<String>,
  sourceAddr: String,
  protocolVersion: String,
}
```

### HttpWasm.**Response**

```grain
record Response {
  headers: List<String>,
}
```

### HttpWasm.**RequestHandler**

```grain
type RequestHandler = Request => Bool
```

### HttpWasm.**ResponseHandler**

```grain
type ResponseHandler = Response => Void
```

### HttpWasm.**LogLevel**

```grain
enum LogLevel {
  Debug,
  Info,
  Warn,
  Err,
}
```

### HttpWasm.**HeaderKind**

```grain
enum HeaderKind {
  RequestHeader,
  ResponseHeader,
}
```

## Values

Functions and constants included in the HttpWasm module.

### HttpWasm.**log**

```grain
log : (level: LogLevel, msg: String) => Void
```

### HttpWasm.**getConfig**

```grain
getConfig : () => String
```

Get middleware configuration exposed from Traefik as string containing unparsed json

### HttpWasm.**hostJson**

```grain
hostJson : Json.Json
```

Middleware configuration exposed from Traefik, as Grain Json.* types

### HttpWasm.**hostConfig**

```grain
hostConfig : Map.Map<String, String>
```

Middleware configuration exposed from Traefik, as Grain Json.* types.
This can be used like: `Map.get("Headers.Foo", hostConfig)`

### HttpWasm.**getMethod**

```grain
getMethod : () => String
```

### HttpWasm.**getUri**

```grain
getUri : () => String
```

### HttpWasm.**getProtocolVersion**

```grain
getProtocolVersion : () => String
```

### HttpWasm.**getSourceAddr**

```grain
getSourceAddr : () => String
```

### HttpWasm.**getHeaderNames**

```grain
getHeaderNames : (headerKind: HeaderKind) => List<String>
```

### HttpWasm.**getHeaderValues**

```grain
getHeaderValues : (headerKind: HeaderKind, name: String) => String
```

### HttpWasm.**addHeaderValue**

```grain
addHeaderValue :
  (headerKind: HeaderKind, name: String, value: String) => Void
```

Note: plugin will panic if `addHeaderValue()` is called on existing header.
  Check `getHeaderName()` if header already exists _before_ call `addHeaderValue()`.

### HttpWasm.**setHeaderValue**

```grain
setHeaderValue :
  (headerKind: HeaderKind, name: String, value: String) => Void
```

Note: plugin will panic if `setHeaderValue()` is called on non-existing header.
  Check `getHeaderName()` to make sure header exists _before_ call `setHeaderValue()`.

### HttpWasm.**getStatusCode**

```grain
getStatusCode : () => Int32
```

Response Only** 
Note: Will panic if status code has not be previously set.

### HttpWasm.**registerRequestHandler**

```grain
registerRequestHandler : (fn: RequestHandler) => Void
```

### HttpWasm.**registerResponseHandler**

```grain
registerResponseHandler : (fn: ResponseHandler) => Void
```

### HttpWasm.**handle_request**

```grain
handle_request : () => WasmI64
```

### HttpWasm.**handle_response**

```grain
handle_response : (high: WasmI32, low: WasmI32) => Void
```

