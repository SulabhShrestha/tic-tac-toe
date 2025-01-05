import 'package:mobile/models/tic_tac_model.dart';

class BotGameHelper {
  // Define the winning sequences
  List<List<int>> winningSequences = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8], // Rows
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8], // Columns
    [0, 4, 8],
    [2, 4, 6], // Diagonals
  ];

  BotGameConclusion _checkForDraw(List<dynamic> selectedCells) {
    if (selectedCells.length == 9) {
      return BotGameConclusion.draw;
    }
    return BotGameConclusion.notYet;
  }

  Map<String, List<int>> _groupSelectedCellsByUser(
      List<dynamic> selectedCells) {
    Map<String, List<int>> groupedCells = {
      "Bot": [],
      "You": [],
    };

    for (var cell in selectedCells) {
      var model = cell as TicTacModel;
      if (model.uid == "Bot") {
        groupedCells["Bot"]!.add(model.selectedIndex.toInt());
      } else {
        groupedCells["You"]!.add(model.selectedIndex.toInt());
      }
    }

    return groupedCells;
  }

  bool _hasWinningSequence(List<int> selectedCellsIndex) {
    // Check if any winning sequence is a subset of the provided selectedIndexes
    return winningSequences.any((sequence) =>
        sequence.every((index) => selectedCellsIndex.contains(index)));
  }

  List<int> getWinningSequence(List<int> selectedCellsIndex) {
    // Check if any winning sequence is a subset of the provided selectedIndexes
    return winningSequences.firstWhere(
        (sequence) =>
            sequence.every((index) => selectedCellsIndex.contains(index)),
        orElse: () => []);
  }

  // checking for the winner
  BotGameConclusion checkForWinner(List<dynamic> selectedCells) {
    // finding if draw exists
    var drawConclusion = _checkForDraw(selectedCells);
    if (drawConclusion == BotGameConclusion.draw) {
      return drawConclusion;
    }

    // finding if winner exists
    var groupedCells = _groupSelectedCellsByUser(selectedCells);
    if (_hasWinningSequence(groupedCells["Bot"]!)) {
      return BotGameConclusion.botWin;
    } else if (_hasWinningSequence(groupedCells["You"]!)) {
      return BotGameConclusion.playerWin;
    }

    return BotGameConclusion.notYet;
  }
}

enum BotGameConclusion {
  draw,
  botWin,
  playerWin,
  notYet,
}
