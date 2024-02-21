import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Stores
class GameDetailsCubit extends Cubit<Map<String, dynamic>> {
  GameDetailsCubit()
      : super({
          "round": 2,
          "score": {"Player 1": 11, "Player 2": 22},
          "playerTurn": "4567",
          "selectedCells": [],
        });

  void setUserId(String uid) {
    debugPrint("Uid cubit: $uid");
    emit({...state, "uid": uid}); // setting the state
  }

  String getUserId() {
    debugPrint("GameDetailsCubit : $state");

    return state["uid"].toString();
  } // getting the state

  void setRoomID(String roomID) {
    debugPrint("RoomID cubit: $roomID");
    emit({...state, "roomID": roomID}); // setting the state
  }

  String getRoomID() {
    debugPrint("GameDetailsCubit : $state");
    return state["roomID"].toString(); // getting the state
  }
}
