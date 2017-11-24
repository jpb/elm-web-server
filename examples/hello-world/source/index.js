var Http = require("http")
var Ehs = require("./ehs.js")
var App = require("./elm.js")
var Ws = require("ws")

var worker = App.Main.worker()

var httpServer = Http.createServer(Ehs.createRequestListener(worker))

Ehs.attachMessageListener(worker, new Ws.Server({
    server: httpServer
}))

httpServer.listen(3000, function () {
    console.log("listening at http://localhost:3000 & ws://localhost:3000")
})