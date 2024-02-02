import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/room_details_provider.dart';
import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/providers/waiting_for_connection_provider.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/views/game_page/widgets/player_profile_card.dart';
import 'package:mobile/views/homepage/widgets/loading_button_with_text.dart';
import 'package:mobile/views/homepage/widgets/gradient_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDDCE6),
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
                  debugPrint("Loading");
                  var socketWebServices = SocketWebServices()
                    ..init()
                    ..createRoom(myUid: ref.read(userIdProvider));

                  socketWebServices.onRoomCreated((roomId) {
                    ref.read(roomDetailsProvider.notifier).state = roomId;
                    ref.read(waitingForConnectionProvider.notifier).state =
                        true;

                    Navigator.of(context).pushNamed("/game", arguments: {
                      "socketWebServices": socketWebServices,
                      "players": <String, dynamic>{},
                    });
                  });
                },
              ),
              const SizedBox(height: 20),
              GradientButton(
                  linearGradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.deepOrange]),
                  onTap: () {
                    log("Ref: ${ref.read(userIdProvider)}");

                    // alert dialog
                    showDialog(
                        context: context,
                        builder: (context) {
                          return _askForRoomId(context, ref);
                        });
                  },
                  child: const Text("Join Game")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _askForRoomId(BuildContext context, WidgetRef ref) {
    final TextEditingController roomIDController = TextEditingController();
    return AlertDialog(
      title: const Text("Enter Room ID"),
      content: TextField(
        controller: roomIDController,
        decoration: const InputDecoration(hintText: "Enter Room ID"),
      ),
      actions: [
        LoadingButtonWithText(
            text: "Join",
            onTap: () {
              debugPrint(roomIDController.text);

              // joining the user to the game
              SocketWebServices socketWebServices = SocketWebServices()
                ..init()
                ..joinRoom(
                    myUid: ref.read(userIdProvider),
                    roomID: roomIDController.text);

              // when room not found
              socketWebServices.socket.on("room-not-found", (data) {
                debugPrint("Room not found");
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Room not found")));
              });

              // joining the game on correct room id
              socketWebServices.socket.on("game-init", (players) {
                debugPrint("Game init $players");

                ref.read(roomDetailsProvider.notifier).state =
                    roomIDController.text;

                Navigator.of(context).pushNamed("/game", arguments: {
                  "socketWebServices": socketWebServices,
                  "players": players,
                });
              });
            }),
      ],
    );
  }
}
