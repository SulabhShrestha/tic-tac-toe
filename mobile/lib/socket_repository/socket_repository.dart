import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mobile/models/emoji_model.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/socket_data_provider/socket_data_provider.dart';

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

  /// Returns the tic tac model and player-turn
  Stream<Map<String, dynamic>> listenToEvent() {
    final streamController = StreamController<Map<String, dynamic>>();

    socketDataProvider.listenToEvent().listen((event) {
      debugPrint("Socket repository : $event");
      streamController.add({
        'model': TicTacModel(
            uid: event['uid'], selectedIndex: event['selectedIndex']),
        "player-turn": event["player-turn"],
      });
    });

    streamController.onCancel = (() {
      debugPrint("Closing the listen to event controller, socketRepository");
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

  Future<bool> listenToQrScannedReceived() async {
    final qrScanned =
        await socketDataProvider.listenToQrScannedReceived().first;

    return qrScanned;
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

  /// Listen to emoji event
  Stream<EmojiModel> listenToEmojiEvent() {
    final streamController = StreamController<EmojiModel>();

    socketDataProvider.listenToEmojiReceived().listen((event) {
      debugPrint("Socket repository : $event");
      streamController.add(EmojiModel(
          senderUid: event["sender"], emojiPath: event["emojiPath"]));
    });

    streamController.onCancel = (() {
      debugPrint("Closing the listen to event controller, socketRepository");
      streamController.close();
    });

    return streamController.stream;
  }

  Stream<Map<String, dynamic>> listenToGameConclusion() {
    final streamController = StreamController<Map<String, dynamic>>();

    socketDataProvider.listenToGameConclusion().listen((event) {
      debugPrint("Socket repository : $event");
      streamController.add(event);
    });

    streamController.onCancel = (() {
      streamController.close();
    });

    return streamController.stream;
  }

  Stream<String> listenToPlayAgainRequest() {
    final streamController = StreamController<String>();

    socketDataProvider.listenToPlayAgainRequest().listen((event) {
      debugPrint("Socket repository listen to play again request: $event");
      streamController.add(event);
    });

    streamController.onCancel = (() {
      streamController.close();
    });

    return streamController.stream;
  }

  /// new player turn is received from the backend
  Stream<String> listenToPlayAgainAccepted() {
    final streamController = StreamController<String>();

    socketDataProvider.listenToPlayAgainAccepted().listen((event) {
      debugPrint("Socket repository listen to play again accepted: $event");
      streamController.add(event);
    });

    streamController.onCancel = (() {
      streamController.close();
    });

    return streamController.stream;
  }

  void sendPlayAgainRequest({required String roomID, required String uid}) {
    socketDataProvider.sendPlayAgainRequest(roomID: roomID, uid: uid);
  }

  void sendPlayAgainResponse({required String roomID}) {
    socketDataProvider.sendPlayAgainResponse(roomID: roomID);
  }

  // listening if the user other player has left the chat
  Future<String> listenToOtherPlayerDisconnect() async {
    final leftUserID =
        await socketDataProvider.listenToOtherPlayerDisconnect().first;

    return leftUserID;
  }
}
