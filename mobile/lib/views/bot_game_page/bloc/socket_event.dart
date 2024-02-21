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

class SendEvent extends SocketEvent {
  final String roomID;
  final int selectedIndex;
  final String uid;

  SendEvent({
    required this.roomID,
    required this.selectedIndex,
    required this.uid,
  });
}

class SendEmoji extends SocketEvent {
  final String emojiPath;
  final String roomID;
  final String uid;

  SendEmoji({required this.emojiPath, required this.uid, required this.roomID});
}

class DisconnectSocket extends SocketEvent {}
