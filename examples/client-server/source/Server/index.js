var App = require("./Main.elm")
var Http = require("http")
var Fs = require("fs")
var Ehs = require("../../../../source/index.js")

var PORT = process.env.PORT || 3000

var CLIENT_SCRIPT = Fs.readFileSync("build/client.js", "utf8")

var onRequest = Ehs.createRequestListener(App.Server.Main.worker({
    client : { script: CLIENT_SCRIPT }
}), 10)

var onListen = function () {
    console.log("listening at http://localhost:" + PORT)
}

Http.createServer()
.on("request", onRequest)
.listen(PORT, onListen)