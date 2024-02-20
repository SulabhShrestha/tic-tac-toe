import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketDataProvider {
  late IO.Socket socket;

  // initialize the socket
  void init() {
    socket = IO.io(
        // dotenv.env['URL'],
        "http://10.0.2.2:3000",
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNewConnection()
            .build());

    socket.connect(); // connect to the server
    socket.onConnect((_) {
      debugPrint("Connected to the server");
    });

    socket.onDisconnect((_) {
      debugPrint("Disconnected from the server");
    });
  }

  /// Disconnect the socket
  void disconnect() {
    socket.disconnect();
  }

  /// Creates room
  void createRoom({required String uid}) {
    debugPrint("Creating room");

    socket.emit('create-room', {
      "uid": uid,
    });
  }

  /// Listen to room created event
  Stream<dynamic> listenToRoomCreated() {
    StreamController<dynamic> controller = StreamController<dynamic>();

    socket.on("room-created", (roomID) {
      controller.add(roomID);
    });

    controller.onCancel = (() {
      debugPrint("Closing the listen to event controller");
      controller.close();
    });

    // Return the stream from the StreamController
    return controller.stream;
  }

  /// listen to room not found event
  Stream<dynamic> listenToRoomNotFound() {
    StreamController<dynamic> controller = StreamController<dynamic>();

    socket.on("room-not-found", (roomID) {
      controller.add(roomID);
    });

    controller.onCancel = (() {
      controller.close();
    });

    // Return the stream from the StreamController
    return controller.stream;
  }

  /// Listen to game-init event
  Stream<dynamic> listenToGameInit() {
    StreamController<dynamic> controller = StreamController<dynamic>();

    socket.on("game-init", (data) {
      debugPrint("Game init socket data provider: $data");
      controller.add(data);
    });

    // Return the stream from the StreamController
    return controller.stream;
  }

  Stream<dynamic> listenToEvent() {
    // Create a StreamController to manage the stream of events
    StreamController<dynamic> controller = StreamController<dynamic>();

    // Register a callback with socket.on to handle "temp" events
    socket.on("temp", (data) {
      debugPrint("Data provider: $data");
      controller.add(data); // Add received data to the stream
    });

    controller.onCancel = (() {
      debugPrint("Closing the listen to event controller");
      controller.close();
    });

    // Return the stream from the StreamController
    return controller.stream;
  }

  void joinRoom({required String roomID, required String uid}) {
    debugPrint("Joining room");

    socket.emit('join-room', {
      "uid": "sulabhhh",
      "roomID": roomID,
    });
  }

  void sendQrScannedEvent({required String roomID}) {
    debugPrint("Sending QR scanned event");
    socket.emit("qr-scanned", {
      "roomID": roomID,
    });
  }

  void sendEvent() {
    socket.emit("temp", {
      "text": "Hello from client",
    });
  }
}
