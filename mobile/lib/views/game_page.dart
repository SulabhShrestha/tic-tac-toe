import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/providers/player_turn_provider.dart';
import 'package:mobile/providers/room_details_provider.dart';
import 'package:mobile/providers/tic_tac_providers.dart';
import 'package:mobile/providers/waiting_for_connection_provider.dart';
import 'package:mobile/services/socket_web_services.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<GamePage> {
  late SocketWebServices socketWebServices;

  @override
  void initState() {
    socketWebServices = SocketWebServices()..init();
    // socketWebServices.joinRoom(myUid: "123", otherUserId: "456");
    //
    socketWebServices.socket.on("game-init", (gameInit) {
      log("Player turn $gameInit");
      ref.watch(playerTurnProvider.notifier).state = gameInit["player1"];
      ref.watch(waitingForConnectionProvider.notifier).state = false;
    });

    socketWebServices.socket.on("event", (data) {
      // changing player state
      ref.watch(playerTurnProvider.notifier).state = data["player-turn"];

      // adding to selected
      ref.watch(ticTacProvider.notifier).addTicTac(
          TicTacModel(uid: data["uid"], selectedIndex: data["selectedIndex"]));
    });
    super.initState();
  }

  @override
  void dispose() {
    socketWebServices.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var playerTurnProv = ref.watch(playerTurnProvider);

    log("Game page");

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Room id: ${ref.watch(roomDetailsProvider)}"),

            Text(
                "Waiting for opponent: ${ref.watch(waitingForConnectionProvider)}"),
            // who's turn
            Text("${playerTurnProv == "123" ? "Your" : playerTurnProv} turn"),

            GridView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              children: [
                for (int a = 0; a < 9; a++) _buildGridCell(a),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell(int index) {
    var ticTacProv = ref.watch(ticTacProvider);
    var playerTurn = ref.watch(playerTurnProvider);

    TicTacModel? model = ticTacProv.firstWhere((ticTac) {
      return ticTac.selectedIndex == index;
    },
        orElse: () => TicTacModel(
              uid: "xx",
              selectedIndex: -1,
            ));

    return GestureDetector(
      onTap: model.selectedIndex == index
          ? null
          : () {
              log("Selected");
              socketWebServices.sendData(data: {
                "uid": "123",
                "roomID": ref.watch(roomDetailsProvider),
                "selectedIndex": index,
              });
            },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: Center(
          child: model.selectedIndex == index
              ? _buildSomething(model.uid)
              : Text(" "),
        ),
      ),
    );
  }

  Widget _buildSomething(String selectedBy) {
    return Icon(
      selectedBy == "123" ? Icons.done : Icons.close,
      size: 54,
    );
  }
}
