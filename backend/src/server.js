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

// for storing the play again requests made in particular roomID
let playAgainRequests = [];

io.on("connection", (socket) => {
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
    let roomID = generateRoomID();

    // roomID = "sulabh";

    // adding to onlinePlayers
    onlinePlayers[socket.id] = uid;

    addGameInfo({
      roomID: roomID,
      players: [uid],
      "player-turn": null,
    });

    socket.join(roomID);

    socket.emit("room-created", roomID);
  });

  socket.on("join-room", ({ uid, roomID }) => {
    // adding to onlinePlayers
    onlinePlayers[socket.id] = uid;

    // getting room details
    const roomDetails = getGameInfoByRoomId(roomID);

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
      let players = [roomDetails.players[0], uid];

      // picking player 1
      let randomIndex = Math.floor(Math.random() * 100);
      let player1 = players[randomIndex % 2];
      let player2 = players[(randomIndex + 1) % 2];

      // updating the game info
      updateGameInfoByRoomId(roomID, {
        players: [player1, player2],
        "player-turn": player1,
      });

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

    // sending the event to the connected clients
    io.to(roomID).emit("event", {
      selectedIndex,
      uid,
      "player-turn": nextPlayerTurn,
    });
    let isConcluded = checkForConclusion(selectedCellsInfo, io, roomID);

    if (isConcluded) return;
  });

  // handling the play again event and sending to the other person
  socket.on("play-again", ({ roomID, uid }) => {
    // checking if the play again request is already made
    if (playAgainRequests.includes(roomID)) return;

    playAgainRequests.push(roomID);

    // sending the event to the connected clients
    socket.broadcast.to(roomID).emit("play-again", uid);
  });

  // forwarding qr scanned event to other device
  socket.on("qr-scanned", ({ roomID }) => {
    socket.broadcast.to(roomID).emit("qr-scanned");
  });

  // handles the play again event sent accepted by the other person
  socket.on("play-again-accepted", ({ roomID }) => {
    // removing the room from the play again requests
    playAgainRequests = playAgainRequests.filter((room) => room != roomID);

    let selectedCells = getSelectedCellsInfoByRoomID(roomID);

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

  // handles the user sending emoji event
  socket.on("emoji", ({ roomID, emojiPath, sender }) => {
    // sending the event to the connected clients
    io.to(roomID).emit("emoji", { emojiPath, sender });
  });

  // Function to generate a unique room ID
  function generateRoomID() {
    const characters =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    let result = "";

    for (let i = 0; i < 5; i++) {
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
