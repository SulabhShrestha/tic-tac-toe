function joinRoom(socket) {
  // object contains, myUid, otherUid
  socket.on("join-room", (object) => {
    console.log("User joined room:", object["to"]);

    // getting the sender and receiver user id
    const sender = object["to"];
    const receiver = object["from"];

    // sorting the user id to maintain the consistency of the room name
    currentRoom = sortAlphanumeric([sender, receiver]).join("-");

    // joining the room
    socket.join(currentRoom);

    console.log("currentRoom", currentRoom);

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
  });
}

// Custom sorting function for alphanumeric strings, useful for maintaining the consistency of the room name
function sortAlphanumeric(arr) {
  return arr.sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));
}

module.exports = { joinRoom };
