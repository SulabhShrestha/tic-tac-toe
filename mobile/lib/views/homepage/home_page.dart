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

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void dispose() {
    debugPrint("Widget disposing");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  SocketWebServices()
                    ..init()
                    ..createRoom(myUid: "123")
                    ..roomCreated((roomId) {
                      try {
                        ref.read(roomDetailsProvider.notifier).state = roomId;
                        ref.read(waitingForConnectionProvider.notifier).state =
                            true;

                        Navigator.of(context).pushNamed("/game");
                      } catch (e) {
                        log("Something");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Something went wrong. Restart the app.")));
                      }
                    });
                },
                child: const Text("Create Game"),
              ),
              ElevatedButton(
                onPressed: () {
                  log("Ref: ${ref.read(userIdProvider)}");

                  // alert dialog
                  showDialog(
                      context: context,
                      builder: (context) {
                        return _askForRoomId(context);
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

  Widget _askForRoomId(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter Room ID"),
      content: const TextField(
        decoration: InputDecoration(hintText: "Enter Room ID"),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            // joining the user to the game
            SocketWebServices socketWebServices = SocketWebServices()
              ..init()
              ..joinRoom(myUid: "123", roomID: "room");

            // joining the game on correct room id
            socketWebServices.socket.on("game-init", (gameInit) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GamePage()));
            });
          },
          child: const Text("Join"),
        )
      ],
    );
  }
}
