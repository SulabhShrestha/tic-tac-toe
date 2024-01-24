import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/providers/all_players_provider.dart';
import 'package:mobile/providers/game_conclusion_provider.dart';
import 'package:mobile/providers/player_turn_provider.dart';
import 'package:mobile/providers/room_details_provider.dart';
import 'package:mobile/providers/tic_tac_providers.dart';
import 'package:mobile/providers/waiting_for_connection_provider.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/utils/tic_tac_utils.dart';
import 'package:mobile/views/game_page/widgets/player_icon.dart';
import 'package:mobile/views/game_page/widgets/waiting_loading_indicator.dart';
import 'package:mobile/views/homepage/home_page.dart';

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
    socketWebServices.socket.on("game-init", (gameInit) {
      debugPrint("Inside game init $gameInit");

      ref.watch(allPlayersProvider.notifier).addPlayers(gameInit);
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

    socketWebServices.socket.on("winner", (user) {
      ref.watch(gameConclusionProvider.notifier).state = {
        "winner": user,
        "conclusion": GameConclusion.win,
      };
    });

    socketWebServices.socket.on("draw", (_) {
      ref.watch(gameConclusionProvider.notifier).state = {
        "conclusion": GameConclusion.draw,
      };
    });

    socketWebServices.socket.on("user-disconnected", (uid) {
      log("User disconnected $uid");
    });
    super.initState();
  }

  Future<void> _showBackDialog() async {
    await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text(
              'Are you sure you want to leave this page?',
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Nevermind'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Leave'),
                onPressed: () async {
                  socketWebServices.disconnect();

                  // removing global state data
                  ref.read(roomDetailsProvider.notifier).state = "";
                  ref.read(waitingForConnectionProvider.notifier).state = false;
                  ref.read(gameConclusionProvider.notifier).state = {};
                  ref.read(ticTacProvider.notifier).removeAll();
                  ref.read(playerTurnProvider.notifier).state = "";
                  ref.read(allPlayersProvider.notifier).empty();

                  Navigator.pushNamedAndRemoveUntil(
                      context, "/", (route) => true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var playerTurnProv = ref.read(playerTurnProvider);

    debugPrint("Player turn: ${ref.read(allPlayersProvider)}");

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        await _showBackDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tic Tac Toe"),
          leading: IconButton(
            onPressed: () async {
              await _showBackDialog();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // game grid
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // who's turn
                  Text(
                      "${playerTurnProv == "123" ? "Your" : playerTurnProv} turn"),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final entry in ref.read(allPlayersProvider).entries)
                        PlayerIcon(
                            playerTitle: entry.key, playerUid: entry.value),
                    ],
                  ),

                  GridView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    children: [
                      for (int a = 0; a < 9; a++) _buildGridCell(a),
                    ],
                  ),
                ],
              ),

              // show loading indicator when waiting for opponent, and make background blur
              if (ref.watch(waitingForConnectionProvider))
                BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.blue.shade600, Colors.green],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const WaitingLoadingIndicator(),
                      ),
                    )),

              // show either win or draw
              if (ref.watch(gameConclusionProvider).isNotEmpty)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue.shade600, Colors.green],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // conclusion text
                          if (ref.watch(gameConclusionProvider)["conclusion"] ==
                              GameConclusion.draw)
                            const Text("Draw"),

                          if (ref.watch(gameConclusionProvider)["conclusion"] ==
                              GameConclusion.win)
                            Text(
                                "${ref.watch(gameConclusionProvider)["winner"]} won the game"),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text("Play Again"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
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
      // it should be both player turn and cell should be empty
      onTap: model.selectedIndex != index && playerTurn == "123"
          ? () {
              socketWebServices.sendData(data: {
                "uid": "123",
                "roomID": ref.watch(roomDetailsProvider),
                "selectedIndex": index,
              });
            }
          : null,

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
