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
      "players": [player, player == "Bot" ? "Player" : "Bot"],
      "playerTurn": player
    });

    debugPrint("Player: $state");
  }

  List<String> getPlayers() => state["players"];

  int getScore(String player) => state["score"][player];

  void addSelectedCell(TicTacModel model) {
    emit({
      ...state,
      "selectedCells": [...state["selectedCells"], model]
    });
  }
}
