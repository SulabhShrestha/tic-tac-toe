const http = require("http");
const express = require("express");
const { Server } = require("socket.io");
const { checkForConclusion } = require("./utils");
const {
  addGameInfo,
  getGameInfoByRoomId,

  updateGameInfoByRoomId,
  deleteGameInfoByUserId,
  getGameInfoByUserId,
  addSelectedCellInfo,
  getSelectedCellsInfoByRoomID,
  clearSelectedCellsInfoByRoomID,
} = require("./game_info");

const app = express();

const httpServer = http.createServer(app);

const io = new Server(httpServer, {
  serveClient: false,
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

app.get("/", (req, res) => {
  res.send("Server running");
});

// socket id : actual user id
const onlinePlayers = {};

io.on("connection", (socket) => {
  console.log(`a user connected ${socket.id}`);

  // triggers automatically when user is disconnected
  socket.on("disconnect", () => {
    // getting the game info
    const gameInfo = getGameInfoByUserId(onlinePlayers[socket.id]);

    // which means the data is already deleted and user is disconnected
    if (!gameInfo) return;

    io.to(gameInfo.roomID).emit("user-disconnected", onlinePlayers[socket.id]);

    // removing from online players and game info
    deleteGameInfoByUserId(onlinePlayers[socket.id]);
    delete onlinePlayers[socket.id];
  });

  // Event when a player creates a game
  socket.on("create-room", ({ uid }) => {
    const roomID = generateRoomID();

    console.log("Create room : ", uid);

    // adding to onlinePlayers
    onlinePlayers[socket.id] = uid;

    addGameInfo({
      roomID: roomID,
      players: [uid],
      "player-turn": null,
    });

    socket.join(roomID);

    console.log(`Room created: ${roomID}`);
    socket.emit("room-created", roomID);
  });

  socket.on("join-room", ({ uid, roomID }) => {
    // adding to onlinePlayers
    onlinePlayers[socket.id] = uid;

    // getting room details
    const roomDetails = getGameInfoByRoomId(roomID);

    console.log("Room details", roomDetails);

    // room doesn't exists
    if (!roomDetails) {
      socket.emit("room-not-found", "The room you searching doesn't exists.");
      return;
    }

    // room is full
    else if (roomDetails && roomDetails.players.length == 2) {
      socket.emit(
        "room-not-found",
        "The room you searching doesn't exists or is full."
      );
      return;
    }

    // someone is waiting for other player and can join the game
    else if (roomDetails && roomDetails.players.length == 1) {
      socket.join(roomID);
      // combining joined and waiting players
      const players = [roomDetails.players[0], uid];

      // picking player 1
      let randomIndex = Math.floor(Math.random() * 100);
      let player1 = players[randomIndex % 2];
      let player2 = players[(randomIndex + 1) % 2];

      // updating the game info
      updateGameInfoByRoomId(roomID, {
        players: players,
        "player-turn": player1,
      });
      console.log("Room info: ", getGameInfoByRoomId(roomID));

      // sending the game initialized event to the room
      io.to(roomID).emit("game-init", {
        "Player 1": player1,
        "Player 2": player2,
      });

      //
    } else {
      socket.emit(
        "room-not-found",
        "The room you searching doesn't exists or is full."
      );
    }
  });

  // handling the event when a user selects a cell
  socket.on("event", function ({ uid, roomID, selectedIndex }) {
    console.log("Event: ", uid, roomID, selectedIndex);

    const gameInfo = getGameInfoByRoomId(roomID);

    let userId = gameInfo["player-turn"];

    const selectedUserIndex = gameInfo.players.indexOf(userId);

    const nextPlayerTurn = gameInfo.players[(selectedUserIndex + 1) % 2];

    // storing the nextPlayer turn in the game info
    updateGameInfoByRoomId(roomID, {
      "player-turn": nextPlayerTurn,
    });

    // adding the selected cells info to the game info
    addSelectedCellInfo(roomID, {
      selectedBy: uid,
      selectedIndex,
    });

    const selectedCellsInfo = getSelectedCellsInfoByRoomID(roomID);
    checkForConclusion(selectedCellsInfo, io, roomID);

    // sending the event to the connected clients
    io.to(roomID).emit("event", {
      selectedIndex,
      uid,
      "player-turn": nextPlayerTurn,
    });
  });

  // handling the play again event and sending to the other person
  socket.on("play-again", ({ roomID, uid }) => {
    // sending the event to the connected clients
    socket.broadcast.to(roomID).emit("play-again", uid);
  });

  // handles the play again event sent accepted by the other person
  socket.on("play-again-accepted", ({ roomID }) => {
    let selectedCells = getSelectedCellsInfoByRoomID(roomID);
    console.log("Selected cells: ", selectedCells);

    // the second person to play game is the first to initate the game now
    let gameInitiater = selectedCells[1].selectedBy;

    // clearing the selected cells info
    clearSelectedCellsInfoByRoomID(roomID);

    // updating player turn
    updateGameInfoByRoomId(roomID, {
      "player-turn": gameInitiater,
    });

    // sending the event to the connected clients, and the player turn as well
    io.to(roomID).emit("play-again-accepted", gameInitiater);
  });

  // Function to generate a unique room ID
  function generateRoomID() {
    const characters =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~!@#$%^&*()+=[]{}<>?";
    let result = "";

    for (let i = 0; i < 12; i++) {
      const randomIndex = Math.floor(Math.random() * characters.length);
      result += characters.charAt(randomIndex);
    }

    return result;

    // return "sulabhRoom";
  }
});

const port = process.env.PORT || 3000;

httpServer.listen(port, () => {
  console.log("Server is running on port 3000 ");
});
