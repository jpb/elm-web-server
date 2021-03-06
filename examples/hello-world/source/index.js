var Http = require("http")
var Ws = require("ws")
var Ews = require("./ews.js")
var App = require("./elm.js")

var worker = App.Main.worker()

var httpServer = Http.createServer(Ews.createRequestListener(worker))

Ews.attachMessageListener(worker, new Ws.Server({
    server: httpServer
}))

httpServer.listen(3000, function () {
    console.log("listening at localhost:3000")
})