global.XMLHttpRequest = require("xhr2").XMLHttpRequest

var createRequestListener = function (ports) {
     return function (request, response) {
        var body = []

        request
        .on("data", function (chunk) { body.push(chunk) })
        .on("end", function () {

            ports.outgoing.subscribe(function (output) {

                response.writeHead(output.status.code, output.status.message, output.headers)
                
                response.end(output.body)
            })

            ports.incoming.send({
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