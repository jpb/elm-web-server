const createServer = require("http").createServer
const readFileSync = require("fs").readFileSync
const createRequestListener = require("../source").createRequestListener
const main = require("./main.elm.js").Main

createServer()
.on("request", createRequestListener(main.worker().ports))
.listen(3000, function () { console.log("listening at port 3000") })