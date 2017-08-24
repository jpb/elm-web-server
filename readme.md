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


An example of using the module can be found in the [universal-elm repository](https://github.com/opvasger/universal-elm). It features a small setup using [Webpack](https://webpack.js.org/).

## Features
- Utility-modules for working with Http-Request/Response on the server
- Emulation for XmlHttpRequest to enable `elm-lang/http` to run on the server
- A tiny API to hook Elm's `Platform.program` into `Http.createServer` in Node.JS

## Warning
Elm and it's architecture is based on browser-applications for now, which leaves a lot of open questions in terms of traditional server-application functionality. This, however, doesn't undercut a lot of the really nice properties of Elm, which with this module can easily be applied to client, server and shared logic.

## Node.js JavaScript API
in Node.js, assuming an Elm module named `Main` compiled to `main.elm.js`, the API can be used as such:

    var EHS = require("elm-http-server")
    var Http = require("http")
    var Elm = require("./main.elm.js")
    
    var PORT = 3000

    var onRequest = EHS.createRequestListener(ELm.Main.worker())
    
    var onStart = function () {
        console.log("server started at http://localhost:" + PORT)
    }

    Http.createServer()
    .on("request", onRequest)
    .listen(PORT, onStart)

Importing `elm-http-server` automatically exposes `XmlHttpRequest` globally to enable usage of `elm-lang/http` in the Elm-modules on the server.

## Elm Api
There is a couple of tiny modules for Elm written to facilitate some basic server-logic

### Server.Request
    type alias Request a =
    { method : String
    , headers : Dict String String
    , url : String
    , body : Maybe a
    }  
###  
    listen : (Result String (Request Decode.Value) -> msg) -> Sub msg
###
    decoder : Decoder a -> Decoder (Request a)

### Server.Response
    type alias Response =
    { status : Status
    , headers : Dict String String
    , body : Maybe String
    }
###
    from : Status -> List Header -> Maybe String -> Response
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