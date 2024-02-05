import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/providers/all_players_provider.dart';
import 'package:mobile/providers/game_conclusion_provider.dart';
import 'package:mobile/providers/game_details_provider.dart';
import 'package:mobile/providers/player_turn_provider.dart';
import 'package:mobile/providers/room_details_provider.dart';
import 'package:mobile/providers/tic_tac_providers.dart';
import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/providers/waiting_for_connection_provider.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/utils/colors.dart';
import 'package:mobile/utils/tic_tac_utils.dart';
import 'package:mobile/views/game_page/widgets/player_icon.dart';
import 'package:mobile/views/game_page/widgets/player_profile_card.dart';
import 'package:mobile/views/game_page/widgets/waiting_loading_indicator.dart';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';

import 'widgets/display_game_conclusion.dart';

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

  // for preventing multiple cells to be triggered at once when clicking multiple
  bool isCellSelected = false;

  @override
  void initState() {
    widget.socketWebServices.socket.on("event", (data) {
      // changing player state
      ref.watch(playerTurnProvider.notifier).state = data["player-turn"];

      if (data["player-turn"] == ref.read(userIdProvider)) {
        debugPrint("Player turn: ${data["player-turn"]}");
        isCellSelected = false;
      }

      // adding to selected
      ref.watch(ticTacProvider.notifier).addTicTac(
          TicTacModel(uid: data["uid"], selectedIndex: data["selectedIndex"]));
    });

    widget.socketWebServices.socket.on("winner", (user) {
      if (user == ref.read(allPlayersProvider)["Player 1"].toString()) {
        ref.watch(gameDetailsProvider.notifier).incrementPlayer1Won();
      } else {
        ref.watch(gameDetailsProvider.notifier).incrementPlayer2Won();
      }

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
      ref.watch(gameDetailsProvider.notifier).setLeftChat(uid);
      if (!snackBarShown) {
        snackBarShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Other player left the game.")),
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
        ref.watch(playerTurnProvider.notifier).state = gameInit["Player 1"];
        ref.watch(waitingForConnectionProvider.notifier).state = false;
      });
    } else {
      Future(() {
        ref.watch(allPlayersProvider.notifier).addPlayers(widget.players);
        ref.watch(playerTurnProvider.notifier).state =
            widget.players["Player 1"];
        ref.watch(waitingForConnectionProvider.notifier).state = false;
      });
    }

    // when play again is accepted
    widget.socketWebServices.socket.on("play-again-accepted", (playerTurn) {
      debugPrint("Play again accepted $playerTurn");

      // resetting
      ref.read(gameConclusionProvider.notifier).state = {};
      ref.watch(ticTacProvider.notifier).removeAll();

      ref.watch(playerTurnProvider.notifier).state = playerTurn;

      // incrementing game round
      ref.watch(gameDetailsProvider.notifier).incrementRound();
    });

    widget.socketWebServices.socket.on("qr-scanned", (data) {
      debugPrint("QR scanned event received");
      Navigator.pop(context);
    });

    super.initState();
  }

  void resetAllStateAndMoveBack() {
    widget.socketWebServices.disconnect();

    // removing global state data
    ref.read(roomDetailsProvider.notifier).state = "";
    ref.watch(waitingForConnectionProvider.notifier).state = false;
    ref.read(gameConclusionProvider.notifier).state = {};
    ref.read(ticTacProvider.notifier).removeAll();
    ref.read(playerTurnProvider.notifier).state = "";
    ref.read(allPlayersProvider.notifier).empty();

    Navigator.pushNamedAndRemoveUntil(context, "/", (route) => true);
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
                  resetAllStateAndMoveBack();
                },
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  widget.socketWebServices.sendPlayAgainAccepted(
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
                  resetAllStateAndMoveBack();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    var playerTurnProv = ref.watch(playerTurnProvider);
    var allPlayersEntries = ref.watch(allPlayersProvider).entries;

    debugPrint("Player turn: $playerTurnProv");

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        await _showBackDialog();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDDCE6),
        body: SafeArea(
          child: Stack(
            children: [
              // Opacity when needed
              Opacity(
                opacity: ref.watch(waitingForConnectionProvider) ||
                        ref.watch(gameConclusionProvider).isNotEmpty
                    ? 0.5
                    : 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (allPlayersEntries.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            PlayerProfileCard(
                                playerInfo: allPlayersEntries.first),

                            // Round indicator
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.amber, Colors.amber.shade700],
                                ),
                              ),
                              margin: const EdgeInsets.only(bottom: 32),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text("Round",
                                      style: TextStyle(fontSize: 16)),
                                  Text(
                                    ref.watch(gameDetailsProvider)["round"],
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),

                            PlayerProfileCard(
                                playerInfo: allPlayersEntries.last),
                          ],
                        ),

                      const SizedBox(height: 28),

                      Container(
                        decoration: BoxDecoration(
                          border: RDottedLineBorder.all(
                            color: ConstantColors.red,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ConstantColors.red,
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                            border: Border.all(
                              color: Colors.white,
                              width: 8,
                            ),
                          ),
                          child: GridView(
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
                        ),
                      ),

                      const SizedBox(height: 28),

                      // who's turn
                      if (playerTurnProv.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.amber, Colors.amber.shade700],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: Text(
                            "${playerTurnProv == ref.read(userIdProvider) ? "Your" : getKeyFromValue(playerTurnProv)} turn",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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
                            colors: [
                              Colors.amber.shade300,
                              Colors.amber.shade700
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const WaitingLoadingIndicator(),
                      ),
                    )),

              // show either win or draw
              if (ref.watch(gameConclusionProvider).isNotEmpty)
                DisplayGameConclusion(
                    socketWebServices: widget.socketWebServices),
            ],
          ),
        ),
      ),
    );
  }

  String? getKeyFromValue(dynamic targetValue) {
    var map = ref.read(allPlayersProvider);
    for (var entry in map.entries) {
      if (entry.value == targetValue) {
        return entry.key;
      }
    }
    return null;
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

    // list of indexes for border
    List<int> borderBottomIndexes = [0, 1, 2, 3, 4, 5];
    List<int> borderRightIndexes = [0, 1, 3, 4, 6, 7];

    debugPrint(
        " building something; $index s: ${model.selectedIndex} pt:${playerTurn} cell: ${isCellSelected}");

    return GestureDetector(
      // it should be both player turn and cell should be empty
      onTap: model.selectedIndex != index && playerTurn == userIdProv
          ? () {
              if (isCellSelected) return;

              widget.socketWebServices.sendData(data: {
                "uid": userIdProv,
                "roomID": ref.watch(roomDetailsProvider),
                "selectedIndex": index,
              });

              isCellSelected = true;
            }
          : null,

      child: Container(
        decoration: BoxDecoration(
          border: RDottedLineBorder(
            dottedLength: 6,
            dottedSpace: 4,
            right: borderRightIndexes.contains(index)
                ? const BorderSide(
                    color: ConstantColors.white,
                    width: 1,
                  )
                : BorderSide.none,
            bottom: borderBottomIndexes.contains(index)
                ? const BorderSide(
                    color: ConstantColors.white,
                    width: 1,
                  )
                : BorderSide.none,
          ),
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
    var allPlayers = ref.read(allPlayersProvider);
    return Image.asset(
        selectedBy == allPlayers["Player 1"]
            ? "images/close.png"
            : "images/circle.png",
        height: 54);
  }
}
