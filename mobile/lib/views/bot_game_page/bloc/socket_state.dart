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

class CellsDetailsBlocState extends SocketState {
  final TicTacModel model;
  final String playerTurn;

  CellsDetailsBlocState({required this.model, required this.playerTurn});
}

class EmojiReceivedBlocState extends SocketState {
  final EmojiModel emojiModel;

  EmojiReceivedBlocState({required this.emojiModel});
}

class GameEnd extends SocketState {
  final String status;
  final String? winner;

  GameEnd({required this.status, this.winner});
}

class GameError extends SocketState {}
