import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mobile/views/bot_game_page/socket_data_provider/socket_data_provider.dart';

class SocketRepository {
  final SocketDataProvider socketDataProvider;
  SocketRepository(this.socketDataProvider);

  void init() {
    socketDataProvider.init();
  }

  /// Disconnect the socket
  void disconnect() {
    socketDataProvider.disconnect();
  }

  /// Creates room
  void createRoom({required String uid}) {
    socketDataProvider.createRoom(uid: uid);
  }

  /// Listen to room created event
  Stream<dynamic> listenToRoomCreated() {
    final streamController = StreamController<dynamic>();
    socketDataProvider.listenToRoomCreated().listen((roomID) {
      debugPrint("Bloc Room created $roomID");
      streamController.add(roomID);
    });

    streamController.onCancel = (() {
      debugPrint("Closing the listen to event controller");
      streamController.close();
    });

    return streamController.stream;
  }

  /// listen to room not found event
  Stream<dynamic> listenToRoomNotFound() {
    final streamController = StreamController<dynamic>();
    socketDataProvider.listenToRoomNotFound().listen((roomID) {
      debugPrint("Bloc Room not found $roomID");
      streamController.add(roomID);
    });

    streamController.onCancel = (() {
      streamController.close();
    });

    return streamController.stream;
  }

  /// Listen to game-init event
  Stream<dynamic> listenToGameInit() {
    final streamController = StreamController<dynamic>();
    socketDataProvider.listenToGameInit().listen((data) {
      debugPrint("Bloc Game init $data");
      streamController.add(data);
    });

    streamController.onCancel = (() {
      debugPrint("Closing the listen to event controller");
      streamController.close();
    });

    return streamController.stream;
  }

  Stream<String> listenToEvent() {
    final streamController = StreamController<String>();

    socketDataProvider.listenToEvent().listen((event) {
      debugPrint("Socket repository : $event");
      streamController.add(event["text"]);
    });

    streamController.onCancel = (() {
      debugPrint("Closing the listen to event controller");
      streamController.close();
    });

    return streamController.stream;
  }

  void joinRoom(String roomID, String myUid) {
    socketDataProvider.joinRoom(roomID: roomID, uid: myUid);
  }

  void sendQrScannedEvent({required String roomID}) {
    socketDataProvider.sendQrScannedEvent(roomID: roomID);
  }

  void sendEvent() {
    socketDataProvider.sendEvent();
  }
}
