import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketWebServices {
  late IO.Socket socket;

  /// adds the userId in the header location
  void init() {
    log("Uid: ");

    socket = IO.io(
        'http://10.0.2.2:3000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());

    socket.connect(); // connect to the server
    socket.onConnect((_) {
      log("Connected to the server");
    });
  }
}