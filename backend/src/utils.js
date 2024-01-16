const {
  getGameInfoByRoom,
  setGameInfo,
  updateGameInfoByRoom,
  addGameInfo,
  addSelectedCellInfo,
  getSelectedCellsInfoByRoom,
} = require("./game_info.js");

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

        // generating player1 and player2 randomly
        const p1 = randomUser;
        const p2 = [player1, player2][(randomIndex + 1) % 2];

        io.to(currentRoom).emit("game-init", {
          player1: p1,
          player2: p2,
        });
      }

      socket.on("event", function (data) {
        // getting uid that triggered this event
        let userId = getGameInfoByRoom(currentRoom)["player-turn"];

        const selectedUserIndex = [player1, player2].indexOf(userId);

        const nextPlayerTurn = [player1, player2][(selectedUserIndex + 1) % 2];

        // storing the nextPlayer turn in the game info
        updateGameInfoByRoom(currentRoom, {
          "player-turn": nextPlayerTurn,
        });

        // adding the selected cells info to the game info
        addSelectedCellInfo(currentRoom, {
          selectedBy: data["selectedBy"],
          selectedIndex: data["selectedIndex"],
        });

        const selectedCellsInfo = getSelectedCellsInfoByRoom(currentRoom);
        checkForConclusion(selectedCellsInfo);

        // sending the event to the connected clients
        io.to(currentRoom).emit("event", {
          ...data,
          "player-turn": nextPlayerTurn,
        });
      });

      socket.on("winner", function (data) {
        io.to(currentRoom).emit("winner", data);
      });

      socket.on("draw", function (data) {
        io.to(currentRoom).emit("draw", data);
      });

      // triggers automatically when user is disconnected
      socket.on("disconnect", () => {
        console.log("User disconnected");
        io.to(currentRoom).emit("user-disconnected", socket.id);
      });

      // notifying the new user about the new users
      io.to(currentRoom).emit("new-user-connected", socket.id);
    }
  });
}

// Custom sorting function for alphanumeric strings, useful for maintaining the consistency of the room name
function sortAlphanumeric(arr) {
  return arr.sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));
}

function checkForConclusion(selectedCellsInfo) {
  // Grouping based on unique selectedBy values
  const groupedBySelectedBy = selectedCellsInfo.reduce((acc, cell) => {
    const { selectedBy, selectedIndex } = cell;
    acc[selectedBy] = acc[selectedBy] || [];
    acc[selectedBy].push(selectedIndex);
    return acc;
  }, {});

  console.log(groupedBySelectedBy);
}

module.exports = { joinRoom };
