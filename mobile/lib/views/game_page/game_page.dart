import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/providers/all_players_provider.dart';
import 'package:mobile/providers/any_button_clicked.dart';
import 'package:mobile/providers/emoji_received_provider.dart';
import 'package:mobile/providers/game_conclusion_provider.dart';
import 'package:mobile/providers/game_details_provider.dart';
import 'package:mobile/providers/player_turn_provider.dart';
import 'package:mobile/providers/qr_closed_provider.dart';
import 'package:mobile/providers/room_details_provider.dart';
import 'package:mobile/providers/tic_tac_providers.dart';
import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/providers/waiting_for_connection_provider.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/utils/colors.dart';
import 'package:mobile/views/bloc/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/views/bot_game_page/bloc/socket_bloc.dart';
import 'package:mobile/views/bot_game_page/widget/round_indicator.dart';
import 'package:mobile/views/game_page/widgets/emoji_panel.dart';
import 'package:mobile/views/game_page/widgets/player_icon.dart';
import 'package:mobile/views/game_page/widgets/player_profile_card.dart';
import 'package:mobile/views/game_page/widgets/waiting_loading_indicator.dart';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';

import 'widgets/display_game_conclusion.dart';

class GamePage extends ConsumerStatefulWidget {
  // players value is only available when joining game
  final Map<String, dynamic> players;

  const GamePage({
    super.key,
    required this.players,
  });

  @override
  ConsumerState<GamePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<GamePage> {
  bool snackBarShown = false;

  // for preventing multiple cells to be triggered at once when clicking multiple
  bool isCellSelected = false;

  bool showEmojiContainer = false;

  void resetAllStateAndMoveBack() {
    // ref.read(socketWebServiceProvider).disconnect();

    // removing global state data
    ref.read(roomDetailsProvider.notifier).state = "";
    ref.watch(waitingForConnectionProvider.notifier).state = false;
    ref.read(gameConclusionProvider.notifier).state = {};
    ref.read(ticTacProvider.notifier).removeAll();
    ref.read(playerTurnProvider.notifier).state = "";
    ref.read(allPlayersProvider.notifier).empty();
    ref.read(anyButtonClickedProvider.notifier).state = false;

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

                  // ref.read(socketWebServiceProvider).sendPlayAgainAccepted(
                  //    roomID: ref.read(roomDetailsProvider));
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
  void initState() {
    context.read<SocketBloc>().add(ListenToEmojiEvent(
        roomID: context.read<GameDetailsCubit>().getRoomID()));
    context.read<SocketBloc>().add(ListenToGameConclusion());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        _showBackDialog();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDDCE6),
        body: SafeArea(
          child: BlocConsumer<SocketBloc, SocketState>(
            listener: (context, socketBlocState) {
              if (socketBlocState is GameStart) {
                debugPrint("Bloc game started: ${socketBlocState.playersInfo}");

                // vibrating the device
                Future(() async {
                  await HapticFeedback.heavyImpact();
                  await SystemSound.play(SystemSoundType.alert);
                });

                // adding players info to cubit
                context
                    .read<GameDetailsCubit>()
                    .setPlayers(socketBlocState.playersInfo);

                // listening to event
                context.read<SocketBloc>().add(ListenToEvent());

                ref
                    .watch(allPlayersProvider.notifier)
                    .addPlayers(socketBlocState.playersInfo);
                ref.watch(playerTurnProvider.notifier).state =
                    socketBlocState.playersInfo["Player 1"];
                ref.watch(waitingForConnectionProvider.notifier).state = false;
              }

              if (socketBlocState is CellsDetailsBlocState) {
                context
                    .read<GameDetailsCubit>()
                    .setPlayerTurn(socketBlocState.playerTurn);
                context
                    .read<GameDetailsCubit>()
                    .addSelectedCells(socketBlocState.model);
              }

              if (socketBlocState is GameEnd) {
                debugPrint(
                    "Game conclusion: ${socketBlocState.status}, ${socketBlocState.winner}");
              }
            },
            listenWhen: (previous, current) {
              if (previous is CellsDetailsBlocState && current is GameEnd) {
                debugPrint("Previous: $previous, Current: $current");

                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return DisplayGameConclusion(
                          gameConclusion: current.status,
                          winner: current.winner);
                    });

                return false; // no need to listen to listener now
              }

              return true;
            },
            builder: (context, socketBlocState) {
              return Stack(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              PlayerProfileCard(
                                  playerInfo: context
                                      .read<GameDetailsCubit>()
                                      .state["players"]
                                      .entries
                                      .first),

                              // Round indicator
                              const RoundIndicator(),

                              PlayerProfileCard(
                                  playerInfo: context
                                      .read<GameDetailsCubit>()
                                      .state["players"]
                                      .entries
                                      .last),
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
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(24)),
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
                                  for (int a = 0; a < 9; a++)
                                    _buildGridCell(a, context),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // who's turn
                          BlocBuilder<GameDetailsCubit, Map<String, dynamic>>(
                            builder: (context, state) {
                              if (state["playerTurn"] != null) {
                                return Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.amber,
                                              Colors.amber.shade700
                                            ],
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 16),
                                        child: Text(
                                          "${state["playerTurn"] == state["uid"] ? "Your" : getKeyFromValue(state["playerTurn"])} turn",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Align(
                                      alignment: Alignment.bottomRight,
                                      child: EmojiPanel(),
                                    ),
                                  ],
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String? getKeyFromValue(dynamic targetValue) {
    var players = context.read<GameDetailsCubit>().state["players"];

    for (var entry in players.entries) {
      if (entry.value == targetValue) {
        return entry.key;
      }
    }
    return null;
  }

  Widget _buildGridCell(int index, BuildContext context) {
    var ticTacProv = ref.watch(ticTacProvider);

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

    return BlocListener<SocketBloc, SocketState>(
      listener: (context, state) {
        if (state is CellsDetailsBlocState &&
            state.playerTurn == context.read<GameDetailsCubit>().getUserId()) {
          isCellSelected = false;
        }
      },
      child: BlocBuilder<GameDetailsCubit, Map<String, dynamic>>(
        builder: (context, state) {
          var selectedCellsDetails = state["selectedCells"]
              .firstWhere((element) => element.selectedIndex == index,
                  orElse: () => TicTacModel(
                        uid: "xx",
                        selectedIndex: -1,
                      ));

          return GestureDetector(
            // it should be both player turn and cell should be empty
            // model.selectedIndex != index && playerTurn == userIdProv
            onTap: selectedCellsDetails.selectedIndex == -1 &&
                    state["playerTurn"] == state["uid"]
                ? () {
                    if (isCellSelected) return;

                    context.read<SocketBloc>().add(SendEvent(
                        roomID: state["roomID"],
                        selectedIndex: index,
                        uid: state["uid"]));

                    isCellSelected = true;
                  }
                : () {
                    debugPrint("Cell already selected");
                  },

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
                child: selectedCellsDetails.selectedIndex != -1
                    ? _buildSomething(selectedCellsDetails.uid)
                    : const Text(" "),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSomething(String selectedBy) {
    var allPlayers = context.read<GameDetailsCubit>().state["players"];
    debugPrint(
        "All players $allPlayers, $selectedBy, ${allPlayers["Player 1"]}");

    return Image.asset(
        selectedBy == allPlayers["Player 1"]
            ? "images/close.png"
            : "images/circle.png",
        height: 54);
  }
}
