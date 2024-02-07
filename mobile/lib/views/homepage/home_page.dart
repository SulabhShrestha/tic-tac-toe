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
import 'package:mobile_scanner/mobile_scanner.dart';
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
    final FocusNode focusNode = FocusNode();
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Enter Room ID"),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return Dialog(
                      child: SizedBox(
                        height: 250,
                        width: 250,
                        child: MobileScanner(
                          fit: BoxFit.cover,
                          onDetect: (capturedData) {
                            Navigator.pop(context);

                            debugPrint(
                                "Captured data: ${capturedData.barcodes.first.displayValue!}");

                            joinSocketRoom(context, ref,
                                capturedData.barcodes.first.displayValue!,
                                isFromQR: true);
                          },
                        ),
                      ),
                    );
                  });
            },
            icon: const Icon(Icons.qr_code_scanner),
          )
        ],
      ),
      content: TextField(
        controller: roomIDController,
        focusNode: focusNode,
        decoration: const InputDecoration(hintText: "Enter Room ID"),
      ),
      actions: [
        LoadingButtonWithText(
            text: "Join",
            onTap: () {
              focusNode.unfocus();
              joinSocketRoom(context, ref, roomIDController.text);
            }),
      ],
    );
  }

  void joinSocketRoom(BuildContext context, WidgetRef ref, String roomID,
      {bool isFromQR = false}) {
    // joining the user to the game
    SocketWebServices socketWebServices = SocketWebServices()
      ..init()
      ..joinRoom(myUid: ref.read(userIdProvider), roomID: roomID);

    // when room not found
    socketWebServices.socket.on("room-not-found", (data) {
      debugPrint("Room not found");
      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Room not found")));
    });

    // joining the game on correct room id
    socketWebServices.socket.on("game-init", (players) {
      debugPrint("Game init $players");

      // sending qr scanned event to pop the qr diplayed on other device
      if (isFromQR) {
        debugPrint("Sent qr scanned event");
        socketWebServices.sendQRscannedEvent(roomID: roomID);
      }

      ref.read(roomDetailsProvider.notifier).state = roomID;

      Navigator.of(context).pushNamed("/game", arguments: {
        "socketWebServices": socketWebServices,
        "players": players,
      });
    });
  }
}
