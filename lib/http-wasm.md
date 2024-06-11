---
title: HttpWasm
---

## Grain API for [http-wasm ABI](https://http-wasm.io/http-handler-abi/)

Implements WASM foreign binding from [`./http-wasm-abi.gr`](./http-wasm-abi.gr).
Traefik plugin logic code can `include HttpWasm` to use native http-wasm functions,
and register functions that will be called when http-wasm's `handle_request` or `handle_response`
are called.

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

  `Reguest` is provided as argument to any functions provided to `registerRequestHandler`

### HttpWasm.**Response**

```grain
record Response {
  headers: List<String>,
}
```

  `Response` is provided as argument to any functions provided to `registerResponseHandler`

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

  See http-wasm ABI spec for [log_level](./http-wasm-abi.md#log_level)

### HttpWasm.**Features**

```grain
enum Features {
  BufferRequest,
  BufferResponse,
  Trailers,
}
```

  See http-wasm ABI spec for [`features`](./http-wasm-abi.md#features)

### HttpWasm.**HeaderKind**

```grain
enum HeaderKind {
  RequestHeader,
  ResponseHeader,
}
```

  See http-wasm ABI spec for [header_kind](./http-wasm-abi.md#header_kind)

## Values

Functions and constants included in the HttpWasm module.

### HttpWasm.**enableFeatures**

```grain
enableFeatures : (features: List<Features>) => Void
```

  See http-wasm ABI spec for [HttpWasmAbi._log](./http-wasm-abi.md#httpwasmabi_enable_features)

> "whether the next handler on the host flushes the response prior to
returning is implementation-specific..."

### HttpWasm.**log**

```grain
log : (level: LogLevel, msg: String) => Void
```

  See http-wasm ABI spec for [HttpWasmAbi._log](./http-wasm-abi.md#httpwasmabi_log)

### HttpWasm.**getConfig**

```grain
getConfig : () => String
```

  Get middleware dynamic configuration exposed from Traefik as string containing unparsed JSON string 

  See http-wasm ABI spec for [HttpWasmAbi._getConfig](./http-wasm-abi.md#httpwasmabi_getconfig)

### HttpWasm.**hostJson**

```grain
hostJson : Result<Json.Json, Json.JsonParseError>
```

  _Grain helper function to parse JSON from Traefik, so not part of http-wasm ABI._ 

  Middleware configuration exposed from Traefik via [`get_config`](./http-wasm-abi#get_config), as "raw" **Grain `Json.Json`** types.

### HttpWasm.**configMap**

```grain
configMap : Map.Map<String, String>
```

  _Grain helper function to parse JSON from Traefik, so not part of http-wasm ABI_

  Middleware configuration exposed from Traefik via [`get_config`](./http-wasm-abi#get_config), as **Grain `Map`** type.
  This can be used like: `Map.get("Headers.Foo", configMap)`

### HttpWasm.**getConfigItem**

```grain
getConfigItem : (name: String) => Option<String>
```

  _Grain helper function to parse JSON from Traefik, so not part of http-wasm ABI_

  Quick access to config data from `plugin.gr` code.  For example:
  ```grain
  let fooHeaderValue = getConfigItem("Headers.Foo")
  ```

### HttpWasm.**getMethod**

```grain
getMethod : () => String
```

  See http-wasm ABI spec for [HttpWasmAbi._getMethod](./http-wasm-abi.md#httpwasmabi_getmethod)

### HttpWasm.**getUri**

```grain
getUri : () => String
```

  See http-wasm ABI spec for [HttpWasmAbi._getUri](./http-wasm-abi.md#httpwasmabi_geturi)

### HttpWasm.**getProtocolVersion**

```grain
getProtocolVersion : () => String
```

  See http-wasm ABI spec for [HttpWasmAbi._getProtocolVersion](./http-wasm-abi.md#httpwasmabi_getprotocolversion)

### HttpWasm.**getSourceAddr**

```grain
getSourceAddr : () => String
```

  See http-wasm ABI spec for [HttpWasmAbi._getSourceAddr](./http-wasm-abi.md#httpwasmabi_getsourceaddr)

### HttpWasm.**getHeaderNames**

```grain
getHeaderNames : (headerKind: HeaderKind) => List<String>
```

  See http-wasm ABI spec for [HttpWasmAbi._getHeaderNames](./http-wasm-abi.md#httpwasmabi_getheadernames)

### HttpWasm.**getHeaderValues**

```grain
getHeaderValues : (headerKind: HeaderKind, name: String) => String
```

  See http-wasm ABI spec for [HttpWasmAbi._getHeaderValues](./http-wasm-abi.md#httpwasmabi_getheadervalues)

### HttpWasm.**addHeaderValue**

```grain
addHeaderValue :
  (headerKind: HeaderKind, name: String, value: String) => Void
```

NOTE** plugin will panic if `addHeaderValue()` is called on existing header.
  Check `getHeaderName()` if header already exists _before_ call `addHeaderValue()`. 

  See http-wasm ABI spec for [HttpWasmAbi._addHeaderValue](./http-wasm-abi.md#httpwasmabi_addheadervalue)

### HttpWasm.**setHeaderValue**

```grain
setHeaderValue :
  (headerKind: HeaderKind, name: String, value: String) => Void
```

NOTE** plugin will panic if `setHeaderValue()` is called on non-existing header.
  Check `getHeaderName()` to make sure header exists _before_ call `setHeaderValue()`. 

  See http-wasm ABI spec for [HttpWasmAbi._setHeaderValue](./http-wasm-abi.md#httpwasmabi_setheadervalue)

### HttpWasm.**removeHeader**

```grain
removeHeader : (headerKind: HeaderKind, name: String) => Void
```

  See http-wasm ABI spec for [HttpWasmAbi._removeHeader](./http-wasm-abi.md#httpwasmabi_removeheader)

### HttpWasm.**getStatusCode**

```grain
getStatusCode : () => Int32
```

  #### Response Only

NOTE** will panic if status code has not be previously set.

  See http-wasm ABI spec for [HttpWasmAbi._getStatusCode](./http-wasm-abi.md#httpwasmabi_getstatuscode)

### HttpWasm.**registerRequestHandler**

```grain
registerRequestHandler : (fn: RequestHandler) => Void
```

This is critical to how `plugin.gr` works.**  The interface between `handle_request` and Grain
  Traefik Plugin code is one or more calls to `registerRequestHandler`.  This module will use
  list of "registered handlers" when a call from host (Traefik) to `handle_request` is invoked. 

  _All registered functions must return `true` or `false` to indicate whether HTTP processing should continue._

### HttpWasm.**registerResponseHandler**

```grain
registerResponseHandler : (fn: ResponseHandler) => Void
```

### HttpWasm.**handle_request**

```grain
handle_request : () => WasmI64
```

  See http-wasm ABI spec for [handle_request](./http-wasm-abi.md#handle_request)

### HttpWasm.**handle_response**

```grain
handle_response : (high: WasmI32, low: WasmI32) => Void
```

  See http-wasm ABI spec for [handle_response](./http-wasm-abi.md#handle_response)

### HttpWasm.**stripNulls**

```grain
stripNulls : (str: String) => String
```

   Helper to remove C-like null-terminated strings that http-wasm returns.

Returns** String to the null-terminator

   > Traefik logging seems to ignore them.
   > However Grain `Number.parse()` treats null-terminated string as invalid char.

### HttpWasm.**dumpCodePoints**

```grain
dumpCodePoints : (str: String) => String
```

For debugging, dump strings as codepoints to see tailing non-printables

