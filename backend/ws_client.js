/* jshint node: true */
/* jshint esversion: 6 */
const WebSocket = require("ws");
const ws = new WebSocket("ws://localhost:5000");

ws.on("open", function open() {
    console.log("Connected");

    var questionMessage = {
        message: "add question",
        question: "Question1"
    };
    ws.send(JSON.stringify(questionMessage));
});
var checked = false;

ws.on("message", function incoming(data) {
    data = JSON.parse(data);
    console.log("Incoming: ", data);

    if (!checked && data.message === "update question") {
        var updateMessage = {
            message: "update question",
            id: data.question.id,
            vote: -1
        };
        ws.send(JSON.stringify(updateMessage));
        checked = true;
    }
});
