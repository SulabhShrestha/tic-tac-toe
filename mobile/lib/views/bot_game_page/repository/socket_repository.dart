import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mobile/views/bot_game_page/socket_data_provider/socket_data_provider.dart';

class SocketRepository {
  final SocketDataProvider socketDataProvider;
  SocketRepository(this.socketDataProvider);

  void init() {
    socketDataProvider.init();
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

    return streamController.stream;
  }

  Stream<String> listenToEvent() {
    final streamController = StreamController<String>();

    socketDataProvider.listenToEvent().listen((event) {
      debugPrint("Socket repository : $event");
      streamController.add(event["text"]);
    });

    return streamController.stream;
  }

  void joinRoom() {
    socketDataProvider.joinRoom();
  }

  void sendEvent() {
    socketDataProvider.sendEvent();
  }
}
