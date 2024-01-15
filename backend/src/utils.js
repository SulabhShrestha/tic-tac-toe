const { getGameInfo, setGameInfo, addGameInfo } = require("./game_info.js");

function joinRoom(socket, io) {
  // object contains, myUid, otherUid
  socket.on("join-room", async (object) => {
    console.log("User joined room:", object["from"]);

    // getting the sender and receiver user id
    const player1 = object["to"];
    const player2 = object["from"];

    // sorting the user id to maintain the consistency of the room name
    currentRoom = sortAlphanumeric([player1, player2]).join("-");

    // getting room details
    const sockets = await io.in(currentRoom).fetchSockets();

    // don't join if size is greater than or equal to 2
    if (sockets.length >= 2) {
      console.log("Room is full no joining");
      socket.emit(
        "room-not-found",
        "The room you searching doesn't exists or is full"
      );
    } else {
      // joining the room
      socket.join(currentRoom);

      console.log("Room size: ", sockets.length);

      // being 1 means two sockets has been joined
      // generating whose turn first
      if (sockets.length == 1) {
        let randomIndex = Math.floor(Math.random() * 100);
        let randomUser = [player1, player2][randomIndex % 2];

        console.log("Random user: ", randomUser);

        addGameInfo({
          room: currentRoom,
          "player-turn": randomUser,
        });

        socket.broadcast.emit("player-turn", randomUser);
      }

      socket.on("event", function (data) {
        socket.broadcast.to(currentRoom).emit("event", data);
      });

      socket.on("winner", function (data) {
        socket.to(currentRoom).emit("winner", data);
      });

      socket.on("draw", function (data) {
        socket.to(currentRoom).emit("draw", data);
      });

      socket.on("user-disconnect", () => {
        socket.to(currentRoom).emit("user-disconnected", socket.id);
      });

      // notifying the new user about the new users
      socket.to(currentRoom).emit("new-user-connected", socket.id);
    }
  });
}

// Custom sorting function for alphanumeric strings, useful for maintaining the consistency of the room name
function sortAlphanumeric(arr) {
  return arr.sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));
}

module.exports = { joinRoom };
