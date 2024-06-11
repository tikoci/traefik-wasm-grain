# traefik-wasm-grain
_⚠️ Traefik WASM plugin using Grain and http-wasm ABI_

Traefik 3.0 introduced support for [WASM-based middleware plugins](https://traefik.io/blog/traefik-3-deep-dive-into-wasm-support-with-coraza-waf-plugin/), with [http-wasm](https://http-wasm.io) providing the WASM-based middleware API.  Essentially, WASM allows Traefik Plugins to be implemented in languages other than `go`.  

This project tests that theory and implements a complete Traefik WASM middleware plugin in [Grain](https://grain-lang.org).  Included is a Grain module, [`HttpWasm`](./lib/http-wasm.md), that deals with the WASM to Grain plumbing, as well as some [simple examples](./examples/) of Grain-based Traefik plugins. 

In terms of the [http-wasm spec](https://http-wasm.io/http-handler-abi/), Traefik implements to "host" part, while [`plugin. gr`](./plugin.gr) here with the `WasmHttp` [code](./lib/http-wasm.gr) implements the "client" portion of http-wasm ABI.

#### _The Premise_ of Grain Program Language

See [Grain Docs](https://grain-lang.org/docs/): 
> Grain is a programming language that brings wonderful features from academic and functional programming languages to the 21st century. We want these features to be accessible and easy to understand. Ideally, as you make your way through this guide, you’ll find that the language feels largely familiar and homey, with many quality-of-life improvements that you’d come to expect of any new-age language.

 While `go` is a fine language, the "business logic" common in HTTP middleware may not be its strength.  With Traefik's WASM support, they can be anything that compiles to WASM.  Grain is used as a test to see how well it works for something tangible (if not entirely practical yet). 

#### About Traefik

Traefik is an Edge Router - it intercepts and routes every incoming HTTP (and other) requests, using dynamically discovered config/logic/rules to determine which services handle which requests (based on the path, host, headers, etc.).  Traefik has four main concepts: EntryPoints, Routers, Middlewares and Services.  See https://doc.traefik.io/traefik/


### Project is a Plugin

This project has become an example and http-wasm library for Grain too.  But still a working WASM plugin, ready-to-use.  The middleware plugin's logic is more example, than production-ready, but **adds request timing data to the logs and response headers**. The specific logic is contained within the [`plugin.gr`](./plugin.gr) file.  

The needed static and dynamic configurations are shown in the [Traefik Plugin Catelog](https://plugins.traefik.io) for "Example WASM Plugin using Grain" and the "Install Plugin" link.  

> To use `traefik-wasm-grain` as a "local plugin" - which is useful for developing your plugin based on this code – see [Setup and Building](#setup_and_building) below for details. 

The basic function of `traefik-wasm-grain` is to time and report the WASM plugin processing itself.  It does this by logging a debug message with each processed request time (in nanoseconds) & by adding response headers:
* `x-grain-timestamp` - added at start of _request_ handling within the WASM plugin
* `x-grain-timing` - added at end of _response_ handling, storing the calculated difference between the end time and start time value from `x-grain-timestamp`

> Using the sample configuration shown in the Plugin Catalog, an "X-Foo" header is added based on the value under "Headers" for "Foo" - if this section is removed from the middleware configuration for a service, the header will not be set.  The logic exists to "do something" with config to meet Traefik's plugin catalog requirements. But not needed to "time requests".


### _Example:_ Grain "Hello World" Plugin

The plumbing needed to integrate Grain types with the http-wasm model is contained within [`HttpWasm` module](./lib/http-wasm.md) in this project.  So a simple `plugin.gr` that just logs to Traefik when a request passes looks like this in Grain:

```grain
module HelloExample

// 3 lines needed for `HttpWasm` plumbing

from "../../lib/http-wasm.gr" include HttpWasm
use HttpWasm.*
provide { handle_request, handle_response }


// add "hello world" to Traefik log at "info" level

registerRequestHandler((resp: Request) => {
  log(Info, "hello world")
  true // continue processing (or not == false)
})


// before response, after all request handlers are run, log something else

registerResponseHandler((resp: Response) => {
  log(Debug, "the end")
  void // response in-flight already, so always void
})
```

Grain's pattern matching can be useful to "match" parts of a request to take some actions.  Here is an example handler that classifies requests by the HTTP method:
```grain
registerRequestHandler((req: Request) => {
  let reRestMethods = Result.unwrap(Regex.make("(PUT|PATCH|DELETE)"))
  match (req) {
    { method, path, _ } when method == "GET" && path == "/" =>
      log(Debug, "processing GET request to homepage"),
    { method, _ } when Regex.isMatch(reRestMethods, method) =>
      log(Debug, "REST API method used"),
    { method, _ } when method == "OPTIONS" =>
      log(Debug, "Possible CORS usage"),
    _ => void, // do nothing is "void", required because of "when" clause
  }
  true
})
```

The [examples](./examples) directory in repo contains the "hello" and "pattern matching" examples above.



### Setup and Building 

You can `git clone` or "Fork" this project from GitHub.  The basic requirements to build a Grain WASM plugin are:
* `make` package install (typically installed on most Linux)
* Grain compiler (see below)
* Some container environment to run Traefik (for example, Docker Desktop, see below)

The "main" logic of a plugin exists in the `plugin.gr` file.  There is one in the root of the repo that's built and used here.  Additionally, each directory in [`./examples`](./examples/) is a valid "local plugin" too.  

You can implement a plugin using multiple files to split up logic, see [`./examples/patterns`](./examples/patterns).

Once everything is installed, to compile the code, just run `make` from the project directory.  This will build the plugin and examples.  To build the documentation, use `make docs`.  And there is a `make clean` to remove any built targets.  While `Makefile` deals with more stuff, to just build the `plugin.wasm` and docs the commands used are:
```sh
grain compile --no-wasm-tail-call plugin.gr -o plugin.wasm
grain doc . -o . 
``` 

#### Grain Language Setup

Since the plugin compiles to a WASM file (plugin.wasm), to _use_ a plugin in Traefik, Grain does **not** need to be installed inside a Traefik container.  Only is this needed to compile this plugin, or build your own, Grain needs to be installed.  

Grain's docs cover installation well under [Getting Grain](https://grain-lang.org/docs/getting_grain).  Using homebrew on MacOS, it's just `brew install --no-quarantine --cask grain-lang/tap/grain`, but the docs cover most common OS's.

Grain has very friendly error messages.  Most messages give a very clear indication of the issue and, importantly, the solution in human-readable form.  But to see those, without compiling, you'd need to use the VSCode Plugin for Grain recommended in Grain's [Editor Setup](https://grain-lang.org/docs/editor_setup) docs.  VSCode does a pretty good job of highlighting any syntax issues with meaningful suggestions to fix them.  Untested, but since Grain supports being a [LSP](https://langserver.org) (AFAIK), there is a ["tree-sitter"](https://github.com/marceline-cramer/tree-sitter-grain) plugin for CLI editors like `nvim` too.  These tools likely can help with figuring out some syntax issues in Grain code, without RTFM.


#### Traefik Setup

Assumed here is some familiarity with the concept of HTTP middleware and/or have Traefik running someplace.  If not, Traefik has a [Docker Compose example](https://doc.traefik.io/traefik/user-guides/docker-compose/basic-example/) to set up a local test environment.  

The specific configuration setup for developing and using plugins is well covered by [Traefik's WASM plugin demo project's readme](https://github.com/traefik/plugindemowasm) for details on need "static configuration" and "dynamic configuration".  See Traefik Proxy Docs for general configuration, which varies depending on the containerization system being used.

For development, using "File Provider" and shared volumes is likely the easiest to quickly build and test a new plugin.   Specifically, volume mounts between the Traefik and development system for `/etc/traefik` (file provider's default for both static and dynamic configuration files) and `/plugins-local/src` (where any local WASM plugins live within a container).  

Any changes to the `plugin.wasm` file requires restarting the container for it to be used.  Dynamic middleware configuration can be made without a restart.

> **TIP** 
> The entire `/example` directory can be copied to `/plugins-local/src` within a Traefik container after running `make` to test running code.  Each subdirectory under `src` can be referenced in Traefik's static configuration as a "localPlugin", using the directory name.

> ### HTTP Middleware and Grain
> "HTTP middleware" is just functionalized piped processing of an HTTP request/response stream with code - the same concept popularized by Node's [express](http://expressjs.com).  
>
> In the context of Traefik Proxy, it's an edge router for microservices, so that's context any middleware is run here.  Traefik, like most HTTP servers, uses a declarative config style.  But sometimes trivial conditionals or logic are needed to correctly route requests to the right service (or reject them), so being able to _simply_ write some code is useful.   
> 
> Since Grain offers functional programming features in more friendly script-like syntax,  it seemed like a nice language to write HTTP middleware.  _i.e._ most middleware involves pattern matching so Grain's [`match` operator](https://grain-lang.org/docs/guide/pattern_matching) seemed well suited to the task, with this project is testing that theory.
>
> But since the `HttpWasm` module here just follows the underlying [http-wasm specifications](http://http-wasm.io), nothing is "Traefik-specific".  While untested, any web server that implements the http-wasm ABI as a WASM "host", _should_ also work with Grain plugin code in this project.  For example, HTTP servers like [fasthttp](https://github.com/valyala/fasthttp?tab=readme-ov-file) and [dapr](https://docs.dapr.io/reference/components-reference/supported-middleware/middleware-wasm/), I believe, support hosting http-wasm "clients" too.


### Creating New Grain WASM Plugins

Future Grain-based Traefik plugins can "fork" this project.  The plugin's "business logic" lives in `plugin.gr` in the project root and is used to interact with Traefik's HTTP middleware flows.  The low-level interactions are contained within `WasmHttp`, which provides Grain-based types to handler functions in `plugin.gr`. 

Since the top-level `plugin.gr` is largely an example, most new plugins should be able to just modify that one file with any desired logic.  And run `make` (or `make OPTS=--release` for a release build)

At the end of the day, Traefik just needs a file named `plugin.wasm` (that implemented http-wasm ABI), and a `.traefik.yml`, in the right path, to be a WASM plugin.  All the other files in this project are just used to build those two files.

> To create a new project "from scratch", the files in `./lib` would need to be copied to deal with low-level http-wasm interaction (or re-written).  But the recommendation is to start by "forking" this project and changing the `plugin.gr` as needed.  Forking allows future changes to the http-wasm binding in `./lib/http-wasm.gr` (and friends) to the pulled.  

#### Reading Middlewares Configuration

A plugin can access any services's "dynamic configuration" by calling `HttpWasm.getConfig()` to get the raw JSON of the `middlewares` config section for the service using the plugin.  `HttpWasm` also offers a parsed version using Grain's `Json` module in `HttpWasm.configJson`.  Or parsed into `Map` can be read using `HttpWasm.configMap`.  See the [HttpWasm docs](./lib/http-wasm.md). 


#### `.traefik.yml` 

The [specifications for `.traefik.yml`](https://github.com/traefik/plugindemowasm?tab=readme-ov-file#manifest) are in the [traefik/plugindemowasm](traefik/plugindemowasm) GitHub project.  These would need to be updated for any plugins to be published.

####  Publishing on Traefik's Plugin Catalog

The project here has a [`Makefile`](./Makefile) and GitHub workflow named [`build.yml`](./.github/workflows/build.yml).  While GitHub Actions can build the WASM file in GitHub Actions, to publish a new plugin, some **manual steps are required**:
1. `build.yml` using a `dispatch_workflow` trigger, so builds are started by going to "build-on-command" workflow in **GitHub Actions**, and selecting the "Run Workflow" button.  Internal to the workflow, the WASM is built using Grain's `--release` optimization so it will take a few minutes to build.
2. When completed, GitHub will produce a "build artifact" named `dist-traefik-wasm-plugin.zip`, containing the `plugin.wasm` and `.traefik.yml` built.  Download this file as it will be needed in the next step.  _Traefik's Plugin Catalog uses this `.zip` file as what to deploy when a middleware plugin is used in a configuration._   
3. In the GitHub project, go to the "Releases" section and "Draft a new Release".  Attach the `dist-traefik-wasm-plugin.zip` previouly downloaded to the Release page, and add any title, etc. as desired.  A new `git` version tag must be created (e.g. `v0.1.1`) and release marked as "Latest" to be picked up by the Plugin Catalog requires versioning.  The release cannot be marked as "Pre-release".
4. Any new plugin should be picked up within 30 minutes.  If there is an issue, an GitHub Issues should be created in the project with the details.

> If the project is a "Fork", GitHub Actions would have to specifically enabled in the repo settings.  But the workflow _should_ be agnostic to the project, and used as-is.

Traefik's WASM demo project also has more information about the Plugin Catalog:
https://github.com/traefik/plugindemowasm


### Troubleshooting

#### Traefik configuration is complex...
**Getting the Traefik configuration correct is important – otherwise, any WASM plugin will not load.** Traefik docs well cover the needed configuration options for plugins, most of which apply to WASM ones too - but it can be complex if not familiar with Traefik. The quickest way for a plugin to not work is if the various configs do not align.  Traefik has a "provider" to get configuration too, adding additional complexity if not familiar with Traefik schemes.  

In Traefik, there are **two** configuration parts: "static" and "dynamic" config.  Essentially a plugin becomes available for use in "static configuration", but to be used for anything the plugin middleware has to be referenced/used in "dynamic configuration" for an HTTP service being proxied.

#### Logs are your friend...
The Traefik log (or potentially HTTP responses if panic) will generally report decent messages on any issues.  The `HttpWasm` Grain wrapper does not protect against illegal operations, since it is designed to be a thin mapping between native WASM and Grain types.  For example,
per the http-wasm ABI, headers cannot be added in a response handler.  But if `addResponseHeader()` is called from a function registered via `registerResponseHandler()`, the following error will appear in Traefik's output.  The fix is "don't do that", and  the logs, like Grain, show something useful: 
> `Recovered from panic in HTTP handler [10.87.1.254:59510 - /]: can't add response header after next handler unless buffer_response is enabled (recovered by wazero) middlewareName=traefik-internal-recovery middlewareType=Recovery`

To implement a `printf` debugging strategy, just use http-wasm `log(level, msg)` method, along with Grain `toString()` Primitive to unwrap Grain types to a string for logging:
```grain
let list = List.init(10, i => i)
// ... code ...
HttpWasm.log(Debug, toString(list))   
```

### Known Issues and Notes
* Operations on the HTTP body are **not** provided by `HttpWasm` wrappers.  This is possible, but how to _correctly_ manage memory and/or effects on traffic processing are unknown at present.  So only header processing things can be done today.
* While in basic testing things appear stable, it is still unknown if there are memory leaks.  _Or, how even to check for them._
* Getting middleware config JSON into usable Grain things for use in "plugin logic" could be improved.  Currently, a `Map` with any JSON object/array hierarchy collapsed in dotted names as the map keys, via `HttpWasm.configMap`.  But this is also not an ideal interface.  Perhaps easier than dealing with the `Json` types directly, and those types are provided by `configJson` as an alternative in case.  Or HttpWasm.getConfig() can get the JSON as a `String`, which could be used with Grain's `Regex` if a simple case.   
* Basically `HttpWasm` masks the low-level `WasmI32` stuff, but allows Grain code to call anything, in any order.  While what the Traefik (i.e. http-wasm "host") called code does is out of `HttpWasm` control. i.e. a `plugin.gr` can still cause a panic on the HTTP pipeline, without any effect in Grain - since the host panic'ed, no more calls are done.
* `HttpWasm` likely should not log on each request by default, but for debugging it's useful. But there should likely be some log level restrictions and/or controls.
* `make` & GitHub process things could be refined - currently random split between various things to accommodate both being a library (`HttpWasm`) and Traefik "WASM Plugin Demo" product.
* There is no "mock" http-wasm or detection if running inside a valid http-wasm host, so testing must be done within a Traefik container.  So "standalone" use or testing will not work today.
