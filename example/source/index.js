var Http = require("http")
var EHS = require("../../source/index.js")
var App = require("./elm.js")

var PORT = 3000

var onRequest = EHS.createRequestListener(App.Main.worker())

var onListen = function () { console.log("listening at http://localhost:" + PORT) }

Http.createServer()
.on("request", onRequest)
.listen(PORT, onListen)