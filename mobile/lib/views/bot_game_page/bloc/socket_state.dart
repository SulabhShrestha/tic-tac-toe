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
  TicTacModel model = TicTacModel.empty();
  String playerTurn = "";
}

class GameEnd extends SocketState {}

class GameError extends SocketState {}
