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
        // "http://10.0.2.2:3000",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNewConnection()
            .build());

    socket.connect(); // connect to the server
    socket.onConnect((_) {
      log("Connected to the server");
    });

    socket.onDisconnect((_) {
      log("Disconnected from the server");
    });
  }

  /// sending disconnect status to the server
  void disconnect() {
    log("Disconnect server function called");
    socket.disconnect();
  }

  void createRoom({required String myUid}) {
    log("Creating room");

    socket.emit('create-room', {
      "uid": myUid,
    });
  }

  // when room is created
  void onRoomCreated(ValueChanged<dynamic> onCreated) {
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

  void sendPlayAgainEvent({
    required String roomID,
    required String uid,
  }) {
    log("Sending play again event");

    socket.emit('play-again', {
      "roomID": roomID,
      "uid": uid,
    });
  }

  void sendPlayAgainAccepted({required String roomID}) {
    log("Sending play again accepted event");

    socket.emit('play-again-accepted', {
      "roomID": roomID,
    });
  }

  void sendData({required Map<String, dynamic> data}) {
    socket.emit("event", data);
  }
}
