import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/models/tic_tac_model.dart';

// Stores
class GameDetailsCubit extends Cubit<Map<String, dynamic>> {
  GameDetailsCubit()
      : super({
          "round": 1,
          "score": {"Player 1": 0, "Player 2": 0},
          "playerTurn": "4567",
          "selectedCells": <TicTacModel>[],
          "players": <String, dynamic>{
            "Iron Man": "1234", // p1
            "Spider Man": "4567" // p2
          },
        });

  void setUserId(String uid) {
    debugPrint("Uid cubit: $uid");
    emit({...state, "uid": uid}); // setting the state
  }

  String getUserId() {
    return state["uid"].toString();
  } // getting the state

  void setRoomID(String roomID) {
    debugPrint("RoomID cubit: $roomID");
    emit({...state, "roomID": roomID}); // setting the state
  }

  String getRoomID() {
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
  }

  void setPlayerTurn(String playerTurn) {
    debugPrint("New player turn set: $playerTurn");
    emit({...state, "playerTurn": playerTurn}); // setting the state
  }

  String getCurrentPlayerTurn() {
    return state["playerTurn"].toString(); // getting the state
  }

  List<TicTacModel> getSelectedCellsDetails(int index) {
    return state["selectedCells"][index];
  }

  int getScore(String player) {
    // if doesn't exist return 0
    if (state["score"][player] == null) return 0;
    return state["score"][player];
  }

  void incrementRound() {
    emit({...state, "round": state["round"] + 1});
  }

  void incrementWinnerScore(String winnerID) {
    // getting the player name from the id
    for (var player in state["players"].entries) {
      if (player.value == winnerID) {
        // incrementing the score
        emit({
          ...state,
          "score": {
            ...state["score"],
            player.key: state["score"][player.key] + 1
          }
        });

        break;
      }
    }
  }

  void clearSelectedCells() {
    emit({...state, "selectedCells": []});
  }
}
