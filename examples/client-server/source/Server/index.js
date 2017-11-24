var App = require("./Main.elm")
var Http = require("http")
var Fs = require("fs")
var Ehs = require("../../../../source/index.js")
var Ws = require("ws")

var PORT = process.env.PORT || 3000

var worker = App.Server.Main.worker({
    client : { script: Fs.readFileSync("build/client.js", "utf8") }
})

var httpServer = Http.createServer(Ehs.createRequestListener(worker))

Ehs.attachMessageListener(worker, new Ws.Server({
    server: httpServer
}))

httpServer.listen(PORT, function () {
    console.log("listening at http://localhost:" + PORT)
})