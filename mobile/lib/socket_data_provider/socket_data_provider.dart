import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketDataProvider {
  late IO.Socket socket;

  // initialize the socket
  void init() {
    socket = IO.io(
        dotenv.env['URL'],
        // "http://10.0.2.2:3000",
        // "http://192.168.1.66:3000",
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

    // Register a callback with socket.on to handle click "event"
    socket.on("event", (data) {
      debugPrint("Event socket data provider: $data");
      controller.add(data); // Add received data to the stream
    });

    controller.onCancel = (() {
      debugPrint("Closing the listen to Event controller, socketDataProvider");
      controller.close();
    });

    // Return the stream from the StreamController
    return controller.stream;
  }

  void joinRoom({required String roomID, required String uid}) {
    debugPrint("Joining room");

    socket.emit('join-room', {
      "uid": uid,
      "roomID": roomID,
    });
  }

  void sendQrScannedEvent({required String roomID}) {
    debugPrint("Sending QR scanned event");
    socket.emit("qr-scanned", {
      "roomID": roomID,
    });
  }

  void sendEvent(
      {required String uid,
      required String roomID,
      required int selectedIndex}) {
    socket.emit("event", {
      "roomID": roomID,
      "selectedIndex": selectedIndex,
      "uid": uid,
    });
  }

  void sendEmojiPath(
      {required String emojiPath,
      required String roomID,
      required String uid}) {
    socket.emit("emoji", {
      "emojiPath": emojiPath,
      "roomID": roomID,
      "sender": uid,
    });
  }

  /// Listen to game-init event
  Stream<dynamic> listenToEmojiReceived() {
    StreamController<dynamic> controller = StreamController<dynamic>();

    socket.on("emoji", (data) {
      debugPrint("Emoji received: $data");
      controller.add(data);
    });

    controller.onCancel = (() {
      controller.close();
    });

    // Return the stream from the StreamController
    return controller.stream;
  }

  Stream<dynamic> listenToGameConclusion() {
    StreamController<dynamic> controller = StreamController<dynamic>();

    socket.on("game-conclusion", (data) {
      debugPrint("Game conclusion: $data");
      controller.add(data);
    });

    controller.onCancel = (() {
      controller.close();
    });

    // Return the stream from the StreamController
    return controller.stream;
  }

  Stream<bool> listenToQrScannedReceived() {
    StreamController<bool> controller = StreamController<bool>();

    socket.on("qr-scanned", (data) {
      debugPrint("QR scanned received: $data");
      if (controller.isClosed) {
        controller = StreamController<bool>();
      }
      controller.add(true); // data is always true, so doesn't really matters
    });

    controller.onCancel = (() {
      controller.close();
    });

    return controller.stream;
  }

  Stream<dynamic> listenToPlayAgainRequest() {
    StreamController<dynamic> controller = StreamController<dynamic>();

    socket.on("play-again", (data) {
      debugPrint("Play again request: $data");
      controller.add(data);
    });

    controller.onCancel = (() {
      controller.close();
    });

    // Return the stream from the StreamController
    return controller.stream;
  }

  Stream<dynamic> listenToPlayAgainAccepted() {
    StreamController<dynamic> controller = StreamController<dynamic>();

    socket.on("play-again-accepted", (data) {
      debugPrint("Play again response socket data provider: $data");
      controller.add(data);
    });

    controller.onCancel = (() {
      controller.close();
    });

    // Return the stream from the StreamController
    return controller.stream;
  }

  void sendPlayAgainRequest({required String roomID, required String uid}) {
    debugPrint("Socket Data Provider: $roomID, $uid");
    socket.emit("play-again", {
      "roomID": roomID,
      "uid": uid,
    });
  }

  void sendPlayAgainResponse({required String roomID}) {
    socket.emit("play-again-accepted", {"roomID": roomID});
  }

  Stream<dynamic> listenToOtherPlayerDisconnect() {
    StreamController<dynamic> controller = StreamController<dynamic>();

    socket.on("user-disconnected", (data) {
      debugPrint("User disconnected: $data");
      controller.add(data);
    });

    controller.onCancel = (() {
      controller.close();
    });

    return controller.stream;
  }
}
