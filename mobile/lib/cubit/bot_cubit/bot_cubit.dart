import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/models/tic_tac_model.dart';

class BotCubit extends Cubit<Map<String, dynamic>> {
  BotCubit()
      : super({
          "round": 1,
          "score": {"Bot": 0, "You": 0},
          "playerTurn": "Bot",
          "players": <String>[],
          "selectedCells": <TicTacModel>[],
        });

  void initGame() {
    // generate random number and pick player
    var player = ["Bot", "You"][Random().nextInt(2)];

    // first chosen player, second the remain one
    emit({
      ...state,
      "players": [player, player == "Bot" ? "You" : "Bot"],
      "playerTurn": player
    });

    // return the first selected value if it is the bot
    if (player == "Bot") {
      emit({
        ...state,
        "selectedCells": [
          TicTacModel(uid: "Bot", selectedIndex: Random().nextInt(9))
        ]
      });
    }

    debugPrint("Player: $state");
  }

  void clearData() {
    emit({
      "round": 1,
      "score": {"Bot": 0, "You": 0},
      "playerTurn": "Bot",
      "players": <String>[],
      "selectedCells": <TicTacModel>[],
    });
  }

  List<String> getPlayers() => state["players"];

  int getScore(String player) => state["score"][player];

  void addSelectedCell(TicTacModel model) {
    emit({
      ...state,
      "selectedCells": [...state["selectedCells"], model]
    });

    if (model.uid != "Bot") {
      _findNextBestMove();
    }
  }

  List<dynamic> getSelectedCells() => state["selectedCells"];

  void _findNextBestMove() {
    // getting selected cells
    var selectedCells = getSelectedCells();

    var bestScore = -1000;
    var bestMove = -1000;

    // looping through all the cells indexes to find the best move
    for (int i = 0; i < 9; i++) {
      // if cells is vacant
      if (selectedCells.every((element) => element.selectedIndex != i)) {
        var score = _minimax();

        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }

    emit({
      ...state,
      "selectedCells": [
        ...state["selectedCells"],
        TicTacModel(uid: "Bot", selectedIndex: bestMove)
      ]
    });
  }

  int _minimax() {
    return 1;
  }
}
