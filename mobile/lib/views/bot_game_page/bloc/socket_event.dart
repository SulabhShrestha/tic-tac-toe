part of 'socket_bloc.dart';

@immutable
abstract class SocketEvent {}

class InitSocket extends SocketEvent {}

class ListenToEvent extends SocketEvent {}

class JoinRoom extends SocketEvent {}

class CreateRoom extends SocketEvent {
  final String myUid;

  CreateRoom({required this.myUid});
}

class DisconnectSocket extends SocketEvent {}

class SendEvent extends SocketEvent {}
