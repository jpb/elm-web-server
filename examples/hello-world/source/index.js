var Http = require("http")
var Ehs = require("elm-http-server")
var App = require("./elm.js")

var PORT = 3000

var onRequest = Ehs.createRequestListener(App.Main.worker())

var onListen = function () { console.log("listening at http://localhost:" + PORT) }

Http.createServer()
.on("request", onRequest)
.listen(PORT, onListen)