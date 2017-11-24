# Elm Server
An API with Node.js-bindings for Elm WebSocket/HTTP servers

## Warning
Elm (along with the Elm architecture) is designed for browser-applications; This project in an experimental attempt to embed the architecture inside a small Node.js framework. Taking the unreasonable performance implications aside, it is fun to experience Elm as a shared language between client and server, with all of it's nice properties for continuous improvement and modification. Enjoy! :)

## Usage
The module is distributed through NPM:

    npm install -S elm-server

if you're going to use the `Server.WebSocket`-module, you should install the following modules from npm:

    npm install -S ws bufferutil utf-8-validate

Go to `elm-package.json` and expose the internal Elm-code from the module:

```json
{   
    ...
    "source-directories": [
        ...
        "node_modules/elm-server/source"
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
var Ehs = require("elm-server")
var Http = require("http")
var Ws = require("ws")
var App = require("./main.elm.js")

var worker = App.Main.worker()

var httpServer = Http.createServer(Ehs.createRequestListener(worker))

Ehs.attachMessageListener(worker, new Ws.Server({
    server: httpServer
}))

httpServer.listen(3000, function () {
    console.log("listening at localhost:3000")
})
```
Importing `elm-server` automatically exposes `XmlHttpRequest` globally to enable usage of `elm-lang/http` in the Elm-modules on the server.

## Elm Interface
There is a couple of tiny modules for Elm, written to facilitate some basic server-logic.

### Server.Http
The HTTP modules exposes utility for dealing with HTTP requests and responses

#### Server.Http.Request

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
encodeId : Request.Id -> E.Value
```

```elm
compareId : Request.Id -> Request.Id -> Bool
```
#### Server.Http.Response

```elm
html : Request.Id -> Status -> Server.Html.Document -> Response
```

```elm
text : Request.Id -> Status -> String -> Response
```

```elm
json : Request.Id -> Status -> Json.Encode.Value -> Response
```

```elm
empty : Request.Id -> Status -> Response
```

```elm
send : Response -> Cmd msg
```

#### Server.Http.Response.Header

```elm
type alias Header = ( String, String )
```

```elm
contentType : String -> Header
```

```elm
textContent : Header
```

```elm
htmlContent : Header
```

```elm
jsonContent : Header
```

#### Server.Http.Response.Status

```elm
type alias Status =
{ code :    Int
, message : String
}
```

```elm
ok : Status
```

```elm
badRequest : Status
```

```elm
unauthorized : Status
```

```elm
notFound : Status
```

```elm
internalError : Status
```

### Server.WebSocket
The HTTP modules exposes utility for dealing with WebSocket connections & messages

```elm
type Event
= Message       WebSocket.Id    D.Value
| Connection    WebSocket.Id
| Disconnection WebSocket.Id
```

```elm
listen : (Result String WebSocket.Event -> msg) -> Sub msg
```

```elm
send : String -> WebSocket.Id -> Cmd msg
```

```elm
compareId : WebSocket.Id -> WebSocket.Id -> Bool
```

### Server.Html
The HTML modules exposes utility for building an HTML document from a title & some JavaScript.

```elm
document : String -> String -> Document
```

```elm
toString : Document -> String
```