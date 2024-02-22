import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/views/bot_game_page/repository/socket_repository.dart';

part 'socket_event.dart';
part 'socket_state.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  final SocketRepository socketRepository;

  SocketBloc(this.socketRepository) : super(SocketInitial()) {
    on<InitSocket>((event, emit) {
      socketRepository.init();
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

    // on<UpdateGameDetails>((event, emit) {
    //   debugPrint("UpdateGameDetails event called");
    //   emit(GameDetails(roomID: event.roomID));
    //
    //   debugPrint("UpdateGameDetails event called ${GameDetails().toString()}");
    // });

    on<ListenToEvent>((event, emit) async {
      debugPrint("ListenToEvent event called");
      await for (var eventData in socketRepository.listenToEvent()) {
        emit(CellsDetailsBlocState()
          ..model = eventData['model']
          ..playerTurn = eventData['player-turn']);
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
        roomID: "sulabhRoom",
        uid: event.uid,
      );
    });

    on<DisconnectSocket>((event, emit) {
      debugPrint("DisconnectSocket event called");
      socketRepository.disconnect();
    });
  }
}
