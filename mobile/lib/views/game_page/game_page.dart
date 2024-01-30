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
import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/providers/waiting_for_connection_provider.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/utils/tic_tac_utils.dart';
import 'package:mobile/views/game_page/widgets/player_icon.dart';
import 'package:mobile/views/game_page/widgets/waiting_loading_indicator.dart';
import 'package:mobile/views/homepage/home_page.dart';

class GamePage extends ConsumerStatefulWidget {
  final SocketWebServices socketWebServices;

  // players value is only available when joining game
  final Map<String, dynamic> players;

  const GamePage({
    super.key,
    required this.socketWebServices,
    required this.players,
  });

  @override
  ConsumerState<GamePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<GamePage> {
  bool snackBarShown = false;

  @override
  void initState() {
    widget.socketWebServices.socket.on("event", (data) {
      // changing player state
      ref.watch(playerTurnProvider.notifier).state = data["player-turn"];

      // adding to selected
      ref.watch(ticTacProvider.notifier).addTicTac(
          TicTacModel(uid: data["uid"], selectedIndex: data["selectedIndex"]));
    });

    widget.socketWebServices.socket.on("winner", (user) {
      ref.watch(gameConclusionProvider.notifier).state = {
        "winner": user,
        "conclusion": GameConclusion.win,
      };
    });

    widget.socketWebServices.socket.on("draw", (_) {
      ref.watch(gameConclusionProvider.notifier).state = {
        "conclusion": GameConclusion.draw,
      };
    });

    widget.socketWebServices.socket.on("user-disconnected", (uid) {
      debugPrint("User disconnected: $uid");
      if (!snackBarShown) {
        snackBarShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Other player left the game.")),
        );
      }
    });

    widget.socketWebServices.socket.on("play-again", (uid) {
      String whichPlayer = ref
          .read(allPlayersProvider)
          .entries
          .firstWhere((element) => element.value == uid)
          .key;
      _showPlayAgainDialog(whichPlayer);
    });

    // when coming after creating game, game-init event is triggered
    // joining game has already triggered game-init event
    if (widget.players.isEmpty) {
      widget.socketWebServices.socket.on("game-init", (gameInit) {
        debugPrint("Inside game init $gameInit");

        ref.watch(allPlayersProvider.notifier).addPlayers(gameInit);
        ref.watch(playerTurnProvider.notifier).state = gameInit["player1"];
        ref.watch(waitingForConnectionProvider.notifier).state = false;
      });
    } else {
      Future(() {
        ref.watch(allPlayersProvider.notifier).addPlayers(widget.players);
        ref.watch(playerTurnProvider.notifier).state =
            widget.players["player1"];
        ref.watch(waitingForConnectionProvider.notifier).state = false;
      });
    }
    super.initState();
  }

  Future<void> _showPlayAgainDialog(String whichPlayer) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Play Again?"),
            content: Text("$whichPlayer is challenging you again!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.socketWebServices.sendPlayAgainEvent(
                      roomID: ref.read(roomDetailsProvider));
                },
                child: const Text("Yes"),
              ),
            ],
          );
        });
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
                  widget.socketWebServices.disconnect();

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
                mainAxisSize: MainAxisSize.max,
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
                            onPressed: () {
                              widget.socketWebServices.sendPlayAgainEvent(
                                  roomID: ref.read(roomDetailsProvider));
                            },
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
    var userIdProv = ref.watch(userIdProvider);

    TicTacModel? model = ticTacProv.firstWhere((ticTac) {
      return ticTac.selectedIndex == index;
    },
        orElse: () => TicTacModel(
              uid: "xx",
              selectedIndex: -1,
            ));

    return GestureDetector(
      // it should be both player turn and cell should be empty
      onTap: model.selectedIndex != index && playerTurn == userIdProv
          ? () {
              widget.socketWebServices.sendData(data: {
                "uid": userIdProv,
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
              ? _buildSomething(model.uid, userIdProv)
              : const Text(" "),
        ),
      ),
    );
  }

  Widget _buildSomething(String selectedBy, String myUid) {
    return Icon(
      selectedBy == myUid ? Icons.done : Icons.close,
      size: 54,
    );
  }
}
