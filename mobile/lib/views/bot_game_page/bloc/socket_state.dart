part of 'socket_bloc.dart';

@immutable
abstract class SocketState {}

class SocketInitial extends SocketState {}

class RoomCreated extends SocketState {
  final dynamic roomID;

  RoomCreated({required this.roomID});
}

class RoomNotFound extends SocketState {
  final String message;

  RoomNotFound({required this.message});
}

class GameStart extends SocketState {
  final Map<String, dynamic> playersInfo;

  GameStart({required this.playersInfo});
}

class GameDetails extends SocketState {
  final String? roomID;

  GameDetails({this.roomID});
}

class GameEnd extends SocketState {}

class GameError extends SocketState {}
