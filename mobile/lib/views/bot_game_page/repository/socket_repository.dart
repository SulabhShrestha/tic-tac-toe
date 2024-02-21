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

  /// Listen to room created event, and return roomID
  Future<String> listenToRoomCreated() async {
    final roomID = await socketDataProvider.listenToRoomCreated().first;

    return roomID;
  }

  /// listen to room not found event, true means not found
  /// false means found
  Future<bool> listenToRoomNotFound() async {
    final roomNotFound = await socketDataProvider.listenToRoomNotFound().first;

    if (roomNotFound != null) {
      return true;
    }
    return false;
  }

  /// Listen to game-init event
  Future<Map<String, dynamic>> listenToGameInit() async {
    final gamePlayersData = await socketDataProvider.listenToGameInit().first;

    debugPrint("Socket repository: $gamePlayersData");

    if (gamePlayersData == null) {
      throw Exception("Room not found");
    }

    return gamePlayersData;
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

  void sendEvent(
      {required String uid,
      required String roomID,
      required int selectedIndex}) {
    socketDataProvider.sendEvent(
        uid: uid, roomID: roomID, selectedIndex: selectedIndex);
  }

  void sendEmojiPath(
      {required String emojiPath,
      required String roomID,
      required String uid}) {
    socketDataProvider.sendEmojiPath(
        roomID: roomID, emojiPath: emojiPath, uid: uid);
  }
}
