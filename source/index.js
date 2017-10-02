var Crypto = require("crypto")

global.XMLHttpRequest = require("xhr2").XMLHttpRequest

var createRequestListener = function (worker, size) {

    if (!size || typeof size !== "number")
        throw Error("Invalid identifier-size. Ensure you have passed a valid buffer-size to generate IDs from to 'createRequestListener'.")

    if (!worker || !worker.ports)
        throw Error("Invalid Elm module. Ensure you are passing an instantiated Elm-worker to 'createRequestListener'.")

    if (!worker.ports.incoming)
        throw Error("Invalid Elm module. Ensure the worker you are passing to 'createRequestListener' is utilizing the Request-module.")

    if (!worker.ports.outgoing)
        throw Error("Invalid Elm module. Ensure the worker you are passing to 'createRequestListener' is utilizing the Response-module.")

    var unresolved = {}

    return function (request, response) {

        Crypto.randomBytes(size, function (error, buffer) {

            var id = buffer.toString("hex")

            unresolved[id] = response

            var body = []

            request
                .on("data", function (chunk) { body.push(chunk) })
                .on("end", function () {

                    worker.ports.outgoing.subscribe(function (output) {

                        if (!unresolved[output.id]) return undefined

                        unresolved[output.id].writeHead(output.status.code, output.status.message, output.headers)

                        unresolved[output.id].end(output.body)

                        unresolved[output.id] = undefined
                    })

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