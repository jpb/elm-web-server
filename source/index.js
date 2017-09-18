global.XMLHttpRequest = require("xhr2").XMLHttpRequest

var createRequestListener = function (worker) {

    if(!worker || !worker.ports)
        throw Error("Invalid Elm module. Ensure you are passing an instantiated Elm-worker to 'createRequestListener'.")

    if(!worker.ports.incoming)
        throw Error("Invalid Elm module. Ensure the worker you are passing to 'createRequestListener' is utilizing the Request-module.")

    if(!worker.ports.outgoing)
        throw Error("Invalid Elm module. Ensure the worker you are passing to 'createRequestListener' is utilizing the Response-module.")

     return function (request, response) {
        var body = []

        request
        .on("data", function (chunk) { body.push(chunk) })
        .on("end", function () {

            worker.ports.outgoing.subscribe(function (output) {

                response.writeHead(output.status.code, output.status.message, output.headers)
                
                response.end(output.body)
            })

            worker.ports.incoming.send({
                url:        request.url,
                method:     request.method,
                headers:    request.headers,
                body:       Buffer.concat(body).toString()
            })
        })
    }
}

module.exports = {
    createRequestListener: createRequestListener
}