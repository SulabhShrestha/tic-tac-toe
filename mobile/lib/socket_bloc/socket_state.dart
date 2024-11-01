part of 'socket_bloc.dart';

@immutable
abstract class SocketState {}

class SocketInitial extends SocketState {}

class RoomCreated extends SocketState {
  final dynamic roomID;

  RoomCreated({required this.roomID});
}

class RoomNotFound extends SocketState {}

class GameStart extends SocketState {
  final Map<String, dynamic> playersInfo;

  GameStart({required this.playersInfo});
}

class QrScannedReceived extends SocketState {}

class CellsDetailsBlocState extends SocketState {
  final TicTacModel model;
  final String playerTurn;

  CellsDetailsBlocState({required this.model, required this.playerTurn});
}

class EmojiReceivedBlocState extends SocketState {
  final EmojiModel emojiModel;

  EmojiReceivedBlocState({required this.emojiModel});
}

class PlayAgainRequestReceivedState extends SocketState {
  final String playerID;

  PlayAgainRequestReceivedState({required this.playerID});
}

class PlayAgainResponseReceivedState extends SocketState {
  final String playerTurn;

  PlayAgainResponseReceivedState({required this.playerTurn});
}

class GameEndState extends SocketState {
  final String status; // for win, draw, lose
  final String? winner; // can be null in the case of draw
  final List<int>? winnerSequence; // so does this. 

  GameEndState({
    required this.status,
    this.winner,
    this.winnerSequence,
  });
}

class OtherPlayerDisconnectedState extends SocketState {
  final String uid;

  OtherPlayerDisconnectedState({required this.uid});
}

class GameError extends SocketState {}
