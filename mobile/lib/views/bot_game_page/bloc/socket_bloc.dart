import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mobile/views/bot_game_page/repository/socket_repository.dart';

part 'socket_event.dart';
part 'socket_state.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  final SocketRepository socketRepository;

  SocketBloc(this.socketRepository) : super(SocketInitial()) {
    on<InitSocket>((event, emit) {
      debugPrint("InitSocket event called");
      socketRepository.init();
      emit(GameStart());

      socketRepository.createRoom(uid: "12");
    });

    on<CreateRoom>((event, emit) async {
      // socketRepository.createRoom(uid: event.myUid);

      final roomID = await socketRepository.listenToRoomCreated().first;
      emit(RoomCreated(roomID: roomID));
    });

    on<ListenToEvent>((event, emit) async {
      debugPrint("ListenToEvent event called");
      await for (var eventData in socketRepository.listenToEvent()) {
        emit(RoomCreated(roomID: "hello world"));
      }
    });

    on<JoinRoom>((event, emit) {
      debugPrint("JoinRoom event called");
      socketRepository.joinRoom();
    });

    on<SendEvent>((event, emit) {
      debugPrint("SendEvent event called");
      socketRepository.sendEvent();
    });
  }
}
