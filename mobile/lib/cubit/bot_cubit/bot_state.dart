part of 'bot_cubit.dart';

class BotState {
  final int? round;
  final Score? score;
  final String? playerTurn;
  final List<String>? players;
  final String? startedBy;
  final List<TicTacModel>? selectedCells;
  final List<int>? winningSequence;
  final BotGameConclusion? gameEnd;

  BotState({
    this.round = 1,
    this.score,
    this.playerTurn,
    this.players,
    this.startedBy,
    this.selectedCells,
    this.winningSequence,
    this.gameEnd,
  });

  // copy with method
  BotState copyWith({
    int? round,
    Score? score,
    String? playerTurn,
    List<String>? players,
    String? startedBy,
    List<TicTacModel>? selectedCells,
    List<int>? winningSequence,
    BotGameConclusion? gameEnd,
  }) {
    return BotState(
      round: round ?? this.round,
      score: score ?? this.score,
      playerTurn: playerTurn ?? this.playerTurn,
      players: players ?? this.players,
      startedBy: startedBy ?? this.startedBy,
      selectedCells: selectedCells ?? this.selectedCells,
      winningSequence: winningSequence ?? this.winningSequence,
      gameEnd: gameEnd ?? this.gameEnd,
    );
  }
}

class Score {
  final int bot;
  final int player;

  Score({this.bot =0, this.player = 0});
}

