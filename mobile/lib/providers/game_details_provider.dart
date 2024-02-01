import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores whose game conclusion
final gameDetailsProvider =
    StateNotifierProvider.autoDispose<GameDetails, Map<String, dynamic>>((ref) {
  return GameDetails();
});

class GameDetails extends StateNotifier<Map<String, dynamic>> {
  GameDetails()
      : super({
          "round": "1",
          "player1Won": "0",
          "player2Won": "0",
        });

  void reset() {
    state = {};
  }

  void incrementPlayer1Won() {
    var player1Won = int.parse(state["player1Won"]);
    state = {
      ...state,
      "player1Won": (player1Won + 1).toString(),
    };
  }

  void incrementPlayer2Won() {
    var player2Won = int.parse(state["player2Won"]);
    state = {
      ...state,
      "player2Won": (player2Won + 1).toString(),
    };
  }

  void incrementRound() {
    var round = int.parse(state["round"]);
    state = {
      ...state,
      "round": (round + 1).toString(),
    };
  }
}
