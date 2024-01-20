import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketWebServices {
  late IO.Socket socket;

  /// adds the userId in the header location
  void init() {
    socket = IO.io(
        dotenv.env['URL'],
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());

    socket.connect(); // connect to the server
    socket.onConnect((_) {
      log("Connected to the server");
    });
  }

  // sending disconnect status to the server
  void disconnect() {
    socket.disconnect();
  }

  void createRoom({required String myUid}) {
    log("Creating room");

    socket.emit('create-room', {
      "uid": myUid,
    });
  }

  // when room is created
  void roomCreated(ValueChanged<dynamic> onCreated) {
    log("Game created");
    socket.on("room-created", onCreated);
  }

  void joinRoom({required String myUid, required String roomID}) {
    log("Joining room");

    socket.emit('join-room', {
      "uid": myUid,
      "roomID": roomID,
    });
  }

  void sendData({required Map<String, dynamic> data}) {
    socket.emit("event", data);
  }
}
