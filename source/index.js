var Crypto = require("crypto")

global.XMLHttpRequest = require("xhr2").XMLHttpRequest

var createRequestListener = function (worker, size) {

    if (!size || typeof size !== "number")
        throw Error("Invalid configuration - Ensure you have passed an integer as the 2nd argument to 'createRequestListener'.")

    if (!worker || !worker.ports)
        throw Error("Invalid configuration - Ensure you are passing an instantiated Elm-worker to 'createRequestListener'.")

    if (!worker.ports.incoming)
        throw Error("Invalid configuration - Ensure the worker you are passing to 'createRequestListener' is utilizing the Request-module.")

    if (!worker.ports.outgoing)
        throw Error("Invalid configuration - Ensure the worker you are passing to 'createRequestListener' is utilizing the Response-module.")

    var unresolved = {}

    worker.ports.outgoing.subscribe(function (output) {

        if (!unresolved[output.id]) return undefined

        unresolved[output.id].writeHead(output.status.code, output.status.message, output.headers)

        unresolved[output.id].end(output.body)

        unresolved[output.id] = undefined
    })

    return function (request, response) {

        Crypto.randomBytes(size, function (error, buffer) {

            var id = Date.now() + buffer.toString("hex")

            unresolved[id] = response

            var body = []

            request
                .on("data", function (chunk) {

                    body.push(chunk)
                })
                .on("end", function () {

                    worker.ports.incoming.send({
                        id: id,
                        url: request.url,
                        method: request.method,
                        headers: request.headers,
                        body: Buffer.concat(body).toString()
                    })
                })
        })
    }
}

module.exports = {
    createRequestListener: createRequestListener
}