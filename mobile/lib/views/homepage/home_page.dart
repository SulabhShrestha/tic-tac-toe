import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/room_details_provider.dart';
import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/providers/waiting_for_connection_provider.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/views/game_page/game_page.dart';
import 'package:mobile/views/homepage/loading_button_with_text.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LoadingButtonWithText(
                text: "Create Game",
                onTap: () {
                  SocketWebServices()
                    ..init()
                    ..createRoom(myUid: ref.read(userIdProvider))
                    ..roomCreated((roomId) {
                      ref.read(roomDetailsProvider.notifier).state = roomId;
                      ref.read(waitingForConnectionProvider.notifier).state =
                          true;

                      Navigator.of(context).pushNamed("/game");
                    });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  log("Ref: ${ref.read(userIdProvider)}");

                  // alert dialog
                  showDialog(
                      context: context,
                      builder: (context) {
                        return _askForRoomId(context, ref);
                      });
                },
                child: const Text("Join Game"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _askForRoomId(BuildContext context, WidgetRef ref) {
    final TextEditingController _roomIDController = TextEditingController();
    return AlertDialog(
      title: const Text("Enter Room ID"),
      content: TextField(
        controller: _roomIDController,
        decoration: const InputDecoration(hintText: "Enter Room ID"),
      ),
      actions: [
        LoadingButtonWithText(
            text: "Join",
            onTap: () {
              debugPrint(_roomIDController.text);

              // joining the user to the game
              SocketWebServices socketWebServices = SocketWebServices()
                ..init()
                ..joinRoom(
                    myUid: ref.read(userIdProvider),
                    roomID: _roomIDController.text);

              // when room not found
              socketWebServices.socket.on("room-not-found", (data) {
                debugPrint("Room not found");
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Room not found")));
              });

              // joining the game on correct room id
              socketWebServices.socket.on("game-init", (gameInit) {
                Navigator.of(context).pushNamed("/game");
              });
            }),
      ],
    );
  }
}
