const http = require("http");
const express = require("express");
const { Server } = require("socket.io");
const { joinRoom } = require("./utils");

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

  joinRoom(socket, io);
});

httpServer.listen(3000, () => {
  console.log("Server is running on port 3000 ");
});
