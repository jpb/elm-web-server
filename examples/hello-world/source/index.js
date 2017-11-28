var Http = require("http")
var Ews = require("./ews.js")
var App = require("./elm.js")
var Ws = require("ws")

var worker = App.Main.worker()

var httpServer = Http.createServer(Ews.createRequestListener(worker))

Ews.attachMessageListener(worker, new Ws.Server({
    server: httpServer
}))

httpServer.listen(3000, function () {
    console.log("listening at http://localhost:3000 & ws://localhost:3000")
})