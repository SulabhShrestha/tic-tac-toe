part of 'socket_bloc.dart';

@immutable
abstract class SocketEvent {}

class InitSocket extends SocketEvent {}

class JoinRoom extends SocketEvent {
  final String roomID;
  final String myUid;

  JoinRoom({
    required this.roomID,
    required this.myUid,
  });
}

class ListenToGameInitEvent extends SocketEvent {}

class ListenToRoomNotFoundEvent extends SocketEvent {}

class CreateRoom extends SocketEvent {
  final String myUid;

  CreateRoom({required this.myUid});
}

class QrScanned extends SocketEvent {
  final String roomID;

  QrScanned({required this.roomID});
}

class UpdateGameDetails extends SocketEvent {
  final String? roomID;

  UpdateGameDetails({this.roomID});
}

class ListenToEvent extends SocketEvent {}

class SendEvent extends SocketEvent {}

class DisconnectSocket extends SocketEvent {}
