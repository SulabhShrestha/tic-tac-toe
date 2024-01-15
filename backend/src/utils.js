function joinRoom(socket, io) {
  // object contains, myUid, otherUid
  socket.on("join-room", async (object) => {
    console.log("User joined room:", object["to"]);

    // getting the sender and receiver user id
    const sender = object["to"];
    const receiver = object["from"];

    // sorting the user id to maintain the consistency of the room name
    currentRoom = sortAlphanumeric([sender, receiver]).join("-");

    // getting room details
    const sockets = await io.in(currentRoom).fetchSockets();

    console.log("Room size: ", sockets.length);

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
