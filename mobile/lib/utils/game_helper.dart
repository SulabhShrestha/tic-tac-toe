import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/line_painter.dart';

class GameHelper {
  Future<void> showBackDialog(BuildContext context, VoidCallback onTap) async {
    await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text(
              'Are you sure you want to leave this page?',
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Nevermind'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                onPressed: onTap,
                child: const Text('Leave'),
              ),
            ],
          );
        });
  }

  WinLineType getWinLineType(List<int> sequence){
    const winningSequences = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8], // Rows
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8], // Columns
      [0, 4, 8],
      [2, 4, 6], // Diagonals
    ];

    WinLineType winLineType = WinLineType.horizontal;

    for (var i = 0; i < winningSequences.length; i++) {
      final sequenceSet = winningSequences[i].toSet();
      if (sequenceSet.containsAll(sequence.toSet())) {
        if(i <= 2){
          winLineType = WinLineType.horizontal;
        } else if(i <= 5){
          winLineType = WinLineType.vertical;
        } else if(i == 6){
          winLineType = WinLineType.diagonalLeft;
        } else if(i == 7){
          winLineType = WinLineType.diagonalRight;
        }
      }
    }
    return winLineType;

  }

}
