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

class GameDetails extends SocketState {
  final int round;
  final Map<String, int> score;
  final String playerTurn;

  GameDetails({
    this.round = 1,
    this.score = const {},
    required this.playerTurn,
  });
}

class GameEnd extends SocketState {}

class GameError extends SocketState {}
