var IS_DEVELOPMENT = process.argv.indexOf("-p") === -1

var outputPathConfig = __dirname + "/build"

var resolveConfig = { extensions: [ ".elm", ".js" ] }

var moduleConfig = { rules: [ {
    test: /.elm$/,
    use: "elm-webpack-loader?debug=" + IS_DEVELOPMENT
} ] }

var client = {
    target: "web",
    entry: "./source/Client/index.js",
    output: { path: outputPathConfig, filename: "client.js" },
    resolve: resolveConfig,
    module: moduleConfig
}

var server = {
    target: "node",
    entry: "./source/Server/index.js",
    output: { path: outputPathConfig, filename: "server.js" },
    resolve: resolveConfig,
    module: moduleConfig
}

module.exports = [ server, client ]