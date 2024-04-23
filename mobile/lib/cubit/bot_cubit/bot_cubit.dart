import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/views/bot_game_page/utils/bot_game_helper.dart';

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
    // var player = ["Bot", "You"][Random().nextInt(2)];
    var player = "Bot";

    // first chosen player, second the remain one
    emit({
      ...state,
      "players": [player, player == "Bot" ? "You" : "Bot"],
      "playerTurn": player
    });

    // return the first selected value if it is the bot
    if (player == "Bot") {
      _findNextBestMove();
    }
  }

  void clearData() {
    emit({
      "round": 1,
      "score": {"Bot": 0, "You": 0},
      "playerTurn": "Bot",
      "players": <String>[],
      "selectedCells":
          List.generate(9, (index) => TicTacModel(selectedIndex: -1, uid: '')),
    });
  }

  // increment and reset value
  void incrementRound({String winner = ""}) {
    emit({
      ...state,
      "round": state["round"] + 1,
      "score": {
        "Bot": winner == "Bot" ? getScore("Bot") + 1 : getScore("Bot"),
        "You": winner == "You" ? getScore("You") + 1 : getScore("You"),
      },
      "game-end": null,
      "playerTurn": "Bot",
      "selectedCells": <TicTacModel>[],
    });
    _findNextBestMove();
  }

  List<String> getPlayers() => state["players"];

  int getScore(String player) => state["score"][player];

  void addSelectedCell(TicTacModel model) {
    emit({
      ...state,
      "selectedCells": [...state["selectedCells"], model],
    });

    debugPrint("Selected cells: ${state["selectedCells"]}");

    var result = BotGameHelper().checkForWinner(getSelectedCells());

    // checking for the winner
    if (result == BotGameConclusion.notYet) {
      _findNextBestMove();
    }

    result = BotGameHelper().checkForWinner(getSelectedCells());
    if (result == BotGameConclusion.botWin) {
      emit({
        ...state,
        "score": {
          "Bot": getScore("Bot") + 1,
          "You": getScore("You"),
        },
        "game-end": "Bot",
      });
    } else if (result == BotGameConclusion.youWin) {
      emit({
        ...state,
        "score": {
          "Bot": getScore("Bot"),
          "You": getScore("You") + 1,
        },
        "game-end": "You",
      });
    } else if (result == BotGameConclusion.draw) {
      emit({
        ...state,
        "game-end": "Draw",
      });
    }
  }

  List<dynamic> getSelectedCells() => state["selectedCells"];

  void _findNextBestMove() {
    debugPrint("Going for best move");
    // getting selected cells
    var selectedCells = getSelectedCells();

    var bestScore = -1000;
    int botMove = -2;

    var unSelectedIndexes = _getUnselectedIndexes(selectedCells);

    var dupCells = [...selectedCells];

    for (int index in unSelectedIndexes) {
      dupCells.add(TicTacModel(selectedIndex: index, uid: 'Bot'));
      var score = _minimax([...dupCells], 0, false, -1, 1);
      dupCells.remove(TicTacModel(selectedIndex: index, uid: 'Bot'));
      debugPrint("selected cells: $dupCells, ${dupCells.length}");
      if (score > bestScore) {
        bestScore = score;
        botMove = index;
      }
    }

    emit({
      ...state,
      "selectedCells": [
        ...state["selectedCells"],
        TicTacModel(uid: "Bot", selectedIndex: botMove)
      ]
    });
  }

  /// board: current board
  /// depth: depth of the tree
  /// isMaximizing: if it is the bot's turn
  int _minimax(
      List<dynamic> board, int depth, bool isMaximizing, int alpha, int beta) {
    // finding the winner
    var result = BotGameHelper().checkForWinner(board);
    if (result == BotGameConclusion.botWin) {
      return 1;
    } else if (result == BotGameConclusion.youWin) {
      return -1;
    } else if (result == BotGameConclusion.draw) {
      return 0;
    }

    var unselectedIndexes = _getUnselectedIndexes(board);

    // if it is the bot's turn
    if (isMaximizing) {
      int bestScore = -100;

      for (int index in unselectedIndexes) {
        board.add(TicTacModel(selectedIndex: index, uid: 'Bot'));
        int eval = _minimax(board, depth + 1, false, alpha, beta);
        board.remove(TicTacModel(selectedIndex: index, uid: 'Bot'));

        bestScore = max(bestScore, eval);

        // for more efficient handling
        alpha = max(alpha, eval);

        if (beta <= alpha) break;
      }

      return bestScore;
    } else {
      int bestScore = 100;
      for (int index in unselectedIndexes) {
        board.add(TicTacModel(selectedIndex: index, uid: 'You'));
        int eval = _minimax(board, depth + 1, true, alpha, beta);
        board.remove(TicTacModel(selectedIndex: index, uid: 'You'));
        bestScore = min(bestScore, eval);

        // for more efficient handling
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return bestScore;
    }
  }

  // returns the unselected index only in the form of list
  List<int> _getUnselectedIndexes(List<dynamic> ticModels) {
    // Create a list to store unselected indexes
    List<int> unselectedIndexes = [];

    // Iterate through the ticModels list
    for (int i = 0; i < 9; i++) {
      bool found = false;

      // Check if the index is selected in any of the TicModel objects
      for (int j = 0; j < ticModels.length; j++) {
        if (ticModels[j].selectedIndex == i) {
          found = true;
          break;
        }
      }

      // If the index is not found in any TicModel object, add it to unselectedIndexes
      if (!found) {
        unselectedIndexes.add(i);
      }
    }

    // Return the list of unselectedIndexes
    return unselectedIndexes;
  }
}
