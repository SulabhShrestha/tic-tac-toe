import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketWebServices {
  late IO.Socket socket;

  /// adds the userId in the header location
  void init() {
    log("Uid: ");

    socket = IO.io(
        'http://10.0.2.2:3000',
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
      "from": myUid,
    });
  }

  // when room is created
  void roomCreated(ValueChanged<dynamic> onCreated) {
    log("Game created");
    socket.on("room-created", onCreated);
  }

  void joinRoom({required String myUid, required String otherUserId}) {
    log("Joining room");

    socket.emit('join-room', {
      "from": myUid,
      "to": otherUserId,
    });
  }

  void sendData({required Map<String, dynamic> data}) {
    socket.emit("event", data);
  }
}
