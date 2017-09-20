/* jshint node: true */
/* jshint esversion: 6 */
const uid = require("uid");
const WebSocket = require("ws");
const PORT = 5000;
const wss = new WebSocket.Server({
    port: PORT
});

// Data Type
// Question { id: String, question: String, rating: Int }

// [Server -> Client] { message: "init", questions: [Question] }
// [Server -> Client] { message: "update question", question: Question }

// [Client -> Server] { message: "update question", id: String, vote: Int }
// [Client -> Server] { message: "add question", question: String }


console.log("WebSocket starts at ws://localhost:%d", PORT);
var questions = [];

wss.on("connection", function connection(ws) {
    if (arrayExist(questions)) {
        var initMsg = {
            message: "init",
            questions: questions
        };
        // [Server -> Client] { message: "init", questions: [{id : String, question: String, rating: Int}]}
        ws.send(JSON.stringify(initMsg));
    }

    // [Client -> Server] data = {message: "update question", id: String, vote: Int}
    // [Client -> Server] data = {message: "add question", question: String}
    ws.on("message", function incoming(data) {
        data = JSON.parse(data);
        if (data.message === "update question") {
            console.log("Received: update question: ", data);
            updateQuestionAndBroadcast(data);
        } else if (data.message === "add question") {
            console.log("Received: add question: ", data);
            addQuestionAndBroadcast(data);
        }
    });
});

function addQuestionAndBroadcast(data) {
    var newQuestion = {
        question: data.question,
        rating: 0,
        id: uid()
    };
    questions.push(newQuestion);
    broadcastQuestion(newQuestion);
}

function updateQuestionAndBroadcast(data) {
    questions.forEach(function(question) {
        if (question.id === data.id) {
            question.rating += data.vote;
            broadcastQuestion(question);
        }
    });
}

// [Server -> Client] {message: "update question", question: {id : String, question: String, rating: Int}}
function broadcastQuestion(question) {
    if (arrayExist(questions)) {
        var questionMsg = {
            message: "update question",
            question: question
        };
        questionMsg = JSON.stringify(questionMsg);
        wss.clients.forEach(function each(client) {
            client.send(questionMsg);
            console.log("Send: ", questionMsg);
        });
    }
}

function arrayExist(array) {
    return typeof array !== "undefined" && array.length > 0;
}

module.exports = {
    questions: questions,
    processFn: updateQuestionAndBroadcast
};
