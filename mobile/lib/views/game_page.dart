import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/providers/player_turn_provider.dart';
import 'package:mobile/providers/tic_tac_providers.dart';
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
    socketWebServices.joinRoom(myUid: "123", otherUserId: "456");

    socketWebServices.socket.on("game-init", (gameInit) {
      log("Player turn $gameInit");
      ref.watch(playerTurnProvider.notifier).state = gameInit["player1"];
    });

    socketWebServices.socket.on("event", (data) {
      // changing player state
      ref.watch(playerTurnProvider.notifier).state = data["player-turn"];

      // adding to selected
      ref.watch(ticTacProvider.notifier).addTicTac(TicTacModel(
          myUID: data["to"],
          otherUID: data["from"],
          selectedBy: data["selectedBy"],
          selectedIndex: data["selectedIndex"]));
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  socketWebServices.joinRoom(myUid: "123", otherUserId: "456");
                },
                child: Text("Again")),
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
              myUID: "xxx",
              otherUID: "xx",
              selectedBy: "xx",
              selectedIndex: -1,
            ));

    return GestureDetector(
      onTap: model.selectedIndex == index
          ? null
          : () {
              socketWebServices.sendData(data: {
                "from": "123",
                "to": "456",
                "selectedBy": "123",
                "selectedIndex": index,
              });
            },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: Center(
          child: model.selectedIndex == index
              ? _buildSomething(model.selectedBy)
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
