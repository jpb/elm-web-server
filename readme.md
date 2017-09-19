# Elm Http Server
A tiny module for easily building an HTTP-server with Elm.

## Usage
The module is distributed through NPM:

`npm install -S elm-http-server`

Go to `elm-package.json` and expose the internal Elm-code from the module:


    {       ...
        "source-directories": [
            ...
            "node_modules/elm-http-server/source"
        ],
        ...
    }

Examples of usage can be found in the `examples` sub-directory.

## Features
- Utility-modules for working with Http-Request/Response on the server
- Emulation for XmlHttpRequest to enable `elm-lang/http` to run on the server
- A tiny API to hook Elm's `Platform.program` into `Http.createServer` in Node.JS

## Warning
Elm and it's architecture is based on browser-applications for now, which leaves a lot of open questions in terms of traditional server-application functionality. This, however, doesn't undercut a lot of the really nice properties of Elm, which with this module can easily be applied to both client- & server-logic.

## JavaScript Interface
in Node.js, assuming an Elm module named `Main` compiled to `main.elm.js` in the same directory, the API can be used as such:

    var Ehs = require("elm-http-server")
    var Http = require("http")
    var App = require("./main.elm.js")
    
    var PORT = 3000

    var onRequest = Ehs.createRequestListener(App.Main.worker())
    
    var onStart = function () {
        console.log("server started at http://localhost:" + PORT)
    }

    Http.createServer()
    .on("request", onRequest)
    .listen(PORT, onStart)

Importing `elm-http-server` automatically exposes `XmlHttpRequest` globally to enable usage of `elm-lang/http` in the Elm-modules on the server.

## Elm Interface
There is a couple of tiny modules for Elm, written to facilitate some basic server-logic.

### Server.Request
    type alias Request route =
    { method : Method
    , headers : Dict String String
    , route : route
    , body : Maybe String
    }
###
    type Method
        = Get
        | Put
        | Post
        | Delete
        | Other String
###
    listen : (String -> route) -> (Result String (Request route) -> msg) -> Sub msg
###
    decoder : (String -> route) -> Decoder (Request route)

### Server.Response
    html : Status -> Server.Html.Document -> Response
###
    text : Status -> String -> Response
###
    json : Status -> Json.Encode.Value -> Response
###
    nothing : Status -> Response
###
    send : Response -> Cmd msg

### Server.Response.Header
    type alias Header = ( String, String )
###
    contentType : String -> Header
###
    textContent : Header
###
    htmlContent : Header
###
    jsonContent : Header

### Server.Response.Status
    type alias Status =
    { code : Int
    , message : String
    }
###
    ok : Status
###
    badRequest : Status
###
    unauthorized : Status
###
    notFound : Status
###
    internalError : Status

### Server.Html
    document : String -> String -> Document
###
    toString : Document -> String