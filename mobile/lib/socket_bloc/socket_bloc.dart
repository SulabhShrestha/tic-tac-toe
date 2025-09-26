import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/models/emoji_model.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/socket_repository/socket_repository.dart';

part 'socket_event.dart';
part 'socket_state.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  final SocketRepository socketRepository;

  SocketBloc(this.socketRepository) : super(SocketInitial()) {
    on<InitSocket>((event, emit) {
      socketRepository
        ..init()
        ..onConnectionError(
          (error) {
            add(SocketErrorEvent(error));
          },
        );
    });

    on<SocketErrorEvent>((event, emit) {
      emit(ConnectionErrorState(error: event.message));
    });


    on<CreateRoom>((event, emit) async {
      socketRepository.createRoom(uid: event.myUid);

      final roomID = await socketRepository.listenToRoomCreated();
      emit(RoomCreated(roomID: roomID));

      final gameInitData = await socketRepository.listenToGameInit();
      emit(GameStart(playersInfo: gameInitData));
    });

    on<JoinRoom>((event, emit) async {
      socketRepository.joinRoom(event.roomID, event.myUid);
    });

    on<ListenToGameInitEvent>((event, emit) async {
      final gameInitData = await socketRepository.listenToGameInit();
      debugPrint("ListenToGameInitEvent event called $gameInitData");
      emit(GameStart(playersInfo: gameInitData));
    });

    on<ListenToRoomNotFoundEvent>((event, emit) async {
      final roomNotFound = await socketRepository.listenToRoomNotFound();
      debugPrint("ListenToRoomNotFoundEvent event called $roomNotFound");
      if (roomNotFound) {
        emit(RoomNotFound());
      }
    });

    on<QrScanned>((event, emit) {
      debugPrint("QrScanned event called");
      socketRepository.sendQrScannedEvent(roomID: event.roomID);
    });

    on<ListenToQrScanned>((event, emit) async {
      log("QrScannedReceived event called");
      final qrScanned = await socketRepository.listenToQrScannedReceived();

      emit(QrScannedReceived());
    });

    on<ListenToEvent>((event, emit) async {
      debugPrint("ListenToEvent event called");
      await for (var eventData in socketRepository.listenToEvent()) {
        emit(CellsDetailsBlocState(
            model: eventData['model'], playerTurn: eventData['player-turn']));
      }
    });

    on<SendEvent>((event, emit) {
      debugPrint("SendEvent event called");
      socketRepository.sendEvent(
          uid: event.uid,
          roomID: event.roomID,
          selectedIndex: event.selectedIndex);
    });

    on<SendEmoji>((event, emit) {
      debugPrint(
          "SendEmoji event called ${event.roomID}, ${event.uid}, ${event.emojiPath}");
      socketRepository.sendEmojiPath(
        emojiPath: event.emojiPath,
        roomID: event.roomID,
        uid: event.uid,
      );
    });

    on<ListenToEmojiEvent>((event, emit) async {
      debugPrint("ListenToEvent event called");
      await for (var emojiModel in socketRepository.listenToEmojiEvent()) {
        emit(EmojiReceivedBlocState(emojiModel: emojiModel));

        Future.delayed(const Duration(seconds: 2), () {
          emit(EmojiReceivedBlocState(emojiModel: EmojiModel.empty()));
        });
      }
    });

    on<ListenToGameConclusion>((event, emit) async {
      debugPrint("ListenToGameConclusion event called");

      ListenToPlayAgainRequest();

      await for (var gameConclusion
          in socketRepository.listenToGameConclusion()) {
        emit(GameEndState(
          status: gameConclusion['status'],
          winner: gameConclusion['winner'],
          winnerSequence: gameConclusion["winSequence"] != null
              ? (gameConclusion['winSequence'] as List).cast<int>()
              : null,
        ));
      }
    });

    on<ListenToPlayAgainRequest>((event, emit) async {
      debugPrint("ListenToPlayAgainRequest event called");

      await for (var playerID in socketRepository.listenToPlayAgainRequest()) {
        emit(PlayAgainRequestReceivedState(playerID: playerID));
      }
    });

    on<SendPlayAgainRequest>((event, emit) {
      debugPrint("SendPlayAgainRequest event called");
      socketRepository.sendPlayAgainRequest(
          roomID: event.roomID, uid: event.uid);
    });

    on<ListenToPlayAgainResponse>((event, emit) async {
      debugPrint("ListenToPlayAgainResponse event called");

      await for (var playerTurn
          in socketRepository.listenToPlayAgainAccepted()) {
        emit(PlayAgainResponseReceivedState(playerTurn: playerTurn));
      }
    });

    on<SendPlayAgainResponse>((event, emit) {
      debugPrint("SendPlayAgainResponse event called");
      socketRepository.sendPlayAgainResponse(roomID: event.roomID);
    });

    on<ListenToOtherPlayerDisconnect>((event, emit) async {
      debugPrint("ListenToOtherPlayerDisconnect event called");
      final leftUserID = await socketRepository.listenToOtherPlayerDisconnect();

      emit(OtherPlayerDisconnectedState(uid: leftUserID));
    });

    on<DisconnectSocket>((event, emit) {
      debugPrint("DisconnectSocket event called");
      socketRepository.disconnect();
      emit(SocketInitial());
    });
  }
}
