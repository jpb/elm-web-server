# Elm Http Server
A puny module for putting together HTTP-servers using Elm

## Warning
Elm (along with the Elm architecture) is designed for browser-applications; This project in experimental attempt to embed the architecture inside a small Node.js Http-server program. Taking the unreasonable performance implications aside, it is fun to experience Elm as a shared language between client and server with all of it's nice properties for continuous improvement and modification. Enjoy! :)

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

## JavaScript Interface
in Node.js, assuming an Elm module named `Main` compiled to `main.elm.js` in the same directory, the API can be used as such:

    var Ehs = require("elm-http-server")
    var Http = require("http")
    var App = require("./main.elm.js")
    
    var PORT = 3000

    var ID_GEN_SIZE = 420

    var onRequest = Ehs.createRequestListener(App.Main.worker(), ID_GEN_SIZE)
    
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
    type alias Request =
    { id : Id
    , method : Method
    , headers : Dict String String
    , url : String
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
    listen : (Result String Request -> msg) -> Sub msg

### Server.Response
    html : Request.Id -> Status -> Server.Html.Document -> Response
###
    text : Request.Id -> Status -> String -> Response
###
    json : Request.Id -> Status -> Json.Encode.Value -> Response
###
    empty : Request.Id -> Status -> Response
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