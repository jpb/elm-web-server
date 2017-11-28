# Elm Web Server
An API with Node.js-bindings for Elm WebSocket/HTTP servers

## Warning
Elm (along with the Elm architecture) is designed for browser-applications; This project in an experimental attempt to embed the architecture inside a small Node.js framework. Taking the unreasonable performance implications aside, it is fun to experience Elm as a shared language between client and server, with all of it's nice properties for continuous improvement and modification. Enjoy! :)

## Usage
The module is distributed through NPM:

    npm install -S elm-web-server

if you're going to use the `Server.WebSocket`-module, you should install the following modules from npm:

    npm install -S ws bufferutil utf-8-validate

Go to `elm-package.json` and expose the internal Elm-code from the module:

```json
{   
    ...
    "source-directories": [
        ...
        "node_modules/elm-web-server/source"
    ]
}
```

Examples of usage can be found in the `examples` sub-directory.

## Features
- Utility-modules for working with Http-Request/Response & WebSocket messages on the server
- Emulation for XmlHttpRequest to enable `elm-lang/http` to run on the server
- A small API to hook Elm's `Platform.program` into either `Node/http` or `Websockets/ws` in Node.js

## JavaScript Interface
in Node.js, assuming an Elm module named `Main` compiled to `main.elm.js` in the same directory, the API can be used as such:
```javascript
var Ews = require("elm-web-server")
var Http = require("http")
var Ws = require("ws")
var App = require("./main.elm.js")

var worker = App.Main.worker()

var httpServer = Http.createServer(Ews.createRequestListener(worker))

Ews.attachMessageListener(worker, new Ws.Server({
    server: httpServer
}))

httpServer.listen(3000, function () {
    console.log("listening at localhost:3000")
})
```
Importing `elm-web-server` automatically exposes `XmlHttpRequest` globally to enable usage of `elm-lang/http` in the Elm-modules on the server.

## Elm Interface
There is a couple of tiny modules for Elm, written to facilitate some basic server-logic.

### Server.Http
The HTTP modules exposes utility for dealing with HTTP requests and responses

```elm
type alias Request =
{ id :      Id
, method :  Method
, headers : Dict String String
, url :     String
, body :    Maybe String
}
```

```elm
type Method
    = Get
    | Put
    | Post
    | Delete
    | Other String
```

```elm
listen : (Result String Request -> msg) -> Sub msg
```

```elm
htmlResponse : Status -> Html.Document -> Id -> Response
```

```elm
textResponse : Status -> String -> Id -> Response
```

```elm
jsonResponse : Status -> E.Value -> Id -> Response
```

```elm
emptyResponse : Status -> Id -> Response
```

```elm
send : Response -> Cmd msg
```

```elm
type alias Status =
{ code :    Int
, message : String
}
```

```elm
okStatus : Status
```

```elm
badRequestStatus : Status
```

```elm
unauthorizedStatus : Status
```

```elm
notFoundStatus : Status
```

```elm
internalErrorStatus : Status
```

### Server.WebSocket
The HTTP modules exposes utility for dealing with WebSocket connections & messages

```elm
type Msg
    = Connected Id
    | Disconnected Id
    | Message Id String
```

```elm
listen : (Result String Msg -> msg) -> Sub msg
```

```elm
send : String -> Id -> Cmd msg
```

```elm
compareId : Id -> Id -> Bool
```

```elm
disconnect : Id -> Cmd msg
```

### Server.Html
The HTML modules exposes utility for building an HTML document from a title & some JavaScript.

```elm
document : String -> String -> Document
```

```elm
toString : Document -> String
```