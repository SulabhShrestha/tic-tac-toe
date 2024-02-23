import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/models/tic_tac_model.dart';

// Stores
class GameDetailsCubit extends Cubit<Map<String, dynamic>> {
  GameDetailsCubit()
      : super({
          "round": 2,
          "score": {"Player 1": 11, "Player 2": 22},
          "playerTurn": "4567",
          "selectedCells": <TicTacModel>[],
          "players": <String, dynamic>{
            "Iron Man": "1234",
            "Spider Man": "4567"
          },
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

  void setPlayers(Map<String, dynamic> players) {
    debugPrint("Players added to cubit: $players");
    emit({...state, "players": players}); // setting the state
  }

  Map<String, dynamic> getPlayers() {
    return state["players"];
  }

  void addSelectedCells(TicTacModel model) {
    emit({
      ...state,
      "selectedCells": [...state["selectedCells"], model]
    });
    debugPrint("Selected cells cubit: ${state["selectedCells"]}");
  }

  void setPlayerTurn(String playerTurn) {
    debugPrint("PlayerTurn cubit: $playerTurn");
    emit({...state, "playerTurn": playerTurn}); // setting the state
  }

  List<TicTacModel> getSelectedCellsDetails(int index) {
    return state["selectedCells"][index];
  }
}
