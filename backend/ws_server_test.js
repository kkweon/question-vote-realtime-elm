const ws_server = require("./ws_server.js");


ws_server.comments.push({
    id: "id1",
    rating: 5
});

console.log(ws_server.comments);

ws_server.processFn({
    id: "id1",
    vote: 1
});


console.log(ws_server.comments);
