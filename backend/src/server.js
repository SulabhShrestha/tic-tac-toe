const http = require("http");
const express = require("express");
const { Server } = require("socket.io");
const { joinRoom } = require("./utils");
const { addGameInfo } = require("./game_info");

const app = express();

const httpServer = http.createServer(app);

const io = new Server(httpServer, {
  serveClient: false,
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

io.on("connection", (socket) => {
  console.log(`a user connected ${socket.id}`);

  // Event when a player creates a game
  socket.on("create-room", (uid) => {
    const roomID = generateRoomID();

    addGameInfo({
      roomID: roomID,
      players: [uid],
      "player-turn": null,
    });

    socket.join(roomID);

    console.log(`Room created: ${roomID}`);
    socket.emit("room-created", { roomID });
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
  }
});

httpServer.listen(3000, () => {
  console.log("Server is running on port 3000 ");
});
