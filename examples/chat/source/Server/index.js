var Http = require("http")
var Fs = require("fs")
var Ws = require("ws")
var Ews = require("../../../../source/index.js")
var App = require("./Main.elm")

var worker = App.Server.Main.worker(Fs.readFileSync("build/client.js", "utf8"))

var httpServer = Http.createServer(Ews.createRequestListener(worker))

Ews.attachMessageListener(worker, new Ws.Server({
    server: httpServer
}))

httpServer.listen(3000, function () {
    console.log("listening at http://localhost:3000")
})