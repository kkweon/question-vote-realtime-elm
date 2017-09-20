const Elm = require("./elm/Main.elm");
require("./css/main.scss");
require("../semantic/dist/semantic.min.css");
require("../semantic/dist/semantic.min.js");
require("jquery");

var mountNode = document.getElementById("app");
var app = Elm.Main.fullscreen();
