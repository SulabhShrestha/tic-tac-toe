import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/views/bot_game_page/utils/bot_game_helper.dart';
part 'bot_state.dart';

class BotCubit extends Cubit<BotState> {
  BotCubit()
      : super(BotState(
          round: 1,
          score: Score(bot: 0, player: 0),
          playerTurn: "Bot",
          players: [],
          startedBy: "",
          selectedCells: [],
          winningSequence: [],
        ));

  void initGame() {
    var player = ["Bot", "You"][Random().nextInt(2)];

    emit(state.copyWith(
      players: [player, player == "Bot" ? "You" : "Bot"],
      playerTurn: player,
      startedBy: player,
      selectedCells: <TicTacModel>[],
    ));

    if (player == "Bot") {
      _findNextBestMove();
    }
  }

  void clearData() {
    emit(BotState());
  }

  void incrementRound({String winner = ""}) {
    String currentPlayer = state.startedBy ?? '';

    String nextPlayer = (state.players as List)
        .firstWhere((element) => element != currentPlayer);

    emit(state.copyWith(
      round: state.round! + 1,
      score: Score(
        bot: winner == "Bot" ? state.score!.bot + 1 : state.score!.bot,
        player: winner == "You" ? state.score!.player + 1 : state.score!.player,
      ),
      gameEnd: BotGameConclusion.notYet,
      playerTurn: nextPlayer,
      startedBy: nextPlayer,
      selectedCells: <TicTacModel>[],
    ));

    if (nextPlayer == "Bot") {
      _findNextBestMove();
    }
  }

  List<String> getPlayers() => state.players!;
  int getScore(String player) =>
      player == "Bot" ? state.score!.bot : state.score!.player;

  void addSelectedCell(TicTacModel model) {
    // Add user's move
    emit(state.copyWith(
      selectedCells: [...state.selectedCells!, model],
      playerTurn: "Bot",
    ));

    // Check if game ended after user's move
    var result = BotGameHelper().checkForWinner(getSelectedCells());
    if (_handleGameEnd(result)) {
      return;
    }

    // Make bot's move
    _findNextBestMove();

    // Check if game ended after bot's move
    result = BotGameHelper().checkForWinner(getSelectedCells());
    _handleGameEnd(result);
  }

  bool _handleGameEnd(BotGameConclusion result) {
    if (result == BotGameConclusion.notYet) {
      return false;
    }

    BotState newState = state;

    List ticTacModels = (newState.selectedCells as List);

    if (result == BotGameConclusion.botWin) {
      List<int> botSelectedIndex = [];

      for (var element in ticTacModels) {
        if (element.uid == "Bot") {
          botSelectedIndex.add(element.selectedIndex);
        }
      }

      newState = newState.copyWith(
        gameEnd: BotGameConclusion.botWin,
        winningSequence: BotGameHelper().getWinningSequence(botSelectedIndex),
        score: Score(
          bot: getScore("Bot") + 1,
          player: getScore("You"),
        ),
      );
    } else if (result == BotGameConclusion.playerWin) {
      List<int> playerSelectedIndex = [];

      for (var element in ticTacModels) {
        if (element.uid == "You") {
          playerSelectedIndex.add(element.selectedIndex);
        }
      }

      newState = newState.copyWith(
        gameEnd: BotGameConclusion.playerWin,
        winningSequence:
            BotGameHelper().getWinningSequence(playerSelectedIndex),
        score: Score(
          bot: getScore("Bot"),
          player: getScore("You") + 1,
        ),
      );
    } else if (result == BotGameConclusion.draw) {
      newState = newState.copyWith(
        gameEnd: BotGameConclusion.draw,
      );
    }

    emit(newState);
    return true;
  }

  List<dynamic> getSelectedCells() => state.selectedCells ?? [];

  void _findNextBestMove() {
    var selectedCells = getSelectedCells();
    var bestScore = -1000;
    int bestMove = -1;
    var unSelectedIndexes = _getUnselectedIndexes(selectedCells);

    for (int index in unSelectedIndexes) {
      var dupCells = [...selectedCells];
      dupCells.add(TicTacModel(selectedIndex: index, uid: 'Bot'));
      var score = _minimax(dupCells, 0, false, -1000, 1000);

      if (score > bestScore) {
        bestScore = score;
        bestMove = index;
      }
    }

    if (bestMove != -1) {
      emit(state.copyWith(
        selectedCells: [
          ...state.selectedCells!,
          TicTacModel(uid: "Bot", selectedIndex: bestMove)
        ],
        playerTurn: "You",
      ));
    }
  }

  int _minimax(
      List<dynamic> board, int depth, bool isMaximizing, int alpha, int beta) {
    var result = BotGameHelper().checkForWinner(board);

    if (result == BotGameConclusion.botWin) {
      return 10 - depth; // Prefer winning in fewer moves
    } else if (result == BotGameConclusion.playerWin) {
      return depth - 10; // Prefer losing in more moves
    } else if (result == BotGameConclusion.draw) {
      return 0;
    }

    var unselectedIndexes = _getUnselectedIndexes(board);

    if (isMaximizing) {
      int bestScore = -1000;
      for (int index in unselectedIndexes) {
        var dupBoard = [...board];
        dupBoard.add(TicTacModel(selectedIndex: index, uid: 'Bot'));
        int eval = _minimax(dupBoard, depth + 1, false, alpha, beta);
        bestScore = max(bestScore, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int index in unselectedIndexes) {
        var dupBoard = [...board];
        dupBoard.add(TicTacModel(selectedIndex: index, uid: 'You'));
        int eval = _minimax(dupBoard, depth + 1, true, alpha, beta);
        bestScore = min(bestScore, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return bestScore;
    }
  }

  List<int> _getUnselectedIndexes(List<dynamic> ticModels) {
    List<int> unselectedIndexes = [];
    for (int i = 0; i < 9; i++) {
      bool found = false;
      for (var model in ticModels) {
        if (model.selectedIndex == i) {
          found = true;
          break;
        }
      }
      if (!found) {
        unselectedIndexes.add(i);
      }
    }
    return unselectedIndexes;
  }
}
