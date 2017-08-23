global.XMLHttpRequest = require("xhr2").XMLHttpRequest

var createRequestListener = function (worker) {

    if(!worker || !worker.ports || !worker.ports.outgoing || !worker.ports.incoming)
        throw Error("invalid Elm module. Make sure 'createRequestListener' is supplied with a valid Elm-module which utilizies 'Server.Request' and 'Server.Response'.")

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