const Elm = require("./elm/Main.elm");
require("./css/main.scss");
require("../semantic/dist/semantic.min.css");
window.$ = window.jQuery = require("jquery");
require("../semantic/dist/semantic.min.js");

var mountNode = document.getElementById("app");
var app = Elm.Main.fullscreen();
