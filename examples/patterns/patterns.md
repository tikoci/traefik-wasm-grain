---
title: PatternClassifier
---

## Values

Functions and constants included in the PatternClassifier module.

### PatternClassifier.**handle_request**

```grain
handle_request : () => WasmI64
```

  See http-wasm ABI spec for [handle_request](./http-wasm-abi.md#handle_request)

### PatternClassifier.**handle_response**

```grain
handle_response : (high: WasmI32, low: WasmI32) => Void
```

  See http-wasm ABI spec for [handle_response](./http-wasm-abi.md#handle_response)

### PatternClassifier.**reRestMethods**

```grain
reRestMethods : Regex.RegularExpression
```

  #### Regular Expressions

  Grain supports regular expressions, and used in `match` by invoking operations from 
  Grain's stdlib `Regex` type.

### PatternClassifier.**methods**

```grain
methods : (req: HttpWasm.Request) => Bool
```

 
  #### Request Handler using `match` and `Regex`

   By separating the handler function from a call to `registerRequestHandler()`,
   the handler logic can be exported using `provide`, and used by other Grain code via `from`.
   For example, `handlerMethodClassification` below is used by the top-level [`plugin.gr`](../../plugin.gr)

