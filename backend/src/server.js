const http = require("http");
const express = require("express");
const { Server } = require("socket.io");

const httpServer = http.createServer(app);

httpServer.listen(3000, () => {
  console.log("Server is running on port 3000 ");
});
