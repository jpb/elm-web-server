var App = require("./Main.elm")

var root = document.createElement("div")
document.body.appendChild(root)
App.Client.Main.embed(root)