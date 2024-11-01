import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/cubit/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/providers/all_players_provider.dart';
import 'package:mobile/providers/any_button_clicked.dart';
import 'package:mobile/providers/qr_opened_provider.dart';
import 'package:mobile/providers/waiting_for_other_player_connection_provider.dart';
import 'package:mobile/socket_bloc/socket_bloc.dart';
import 'package:mobile/utils/colors.dart';
import 'package:mobile/utils/game_helper.dart';
import 'package:mobile/views/game_page/widgets/emoji_panel.dart';
import 'package:mobile/views/game_page/widgets/player_profile_card_socket.dart';
import 'package:mobile/views/game_page/widgets/round_indicator_socket.dart';
import 'package:mobile/views/game_page/widgets/waiting_loading_indicator.dart';
import 'package:mobile/views/widgets/line_painter.dart';
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
    ref
        .read(waitingForOtherPlayerConnectionProvider.notifier)
        .update((state) => false);
    context.read<SocketBloc>().add(DisconnectSocket());
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
                  debugPrint("Initiating play again ");
                  Navigator.pop(context);

                  var roomID = context.read<GameDetailsCubit>().getRoomID();
                  context
                      .read<SocketBloc>()
                      .add(SendPlayAgainResponse(roomID: roomID));

                  // resetting to no button is clicked
                  ref.read(anyButtonClickedProvider.notifier).state = false;
                },
                child: const Text("Yes"),
              ),
            ],
          );
        });
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    context.read<SocketBloc>()
      ..add(ListenToEmojiEvent(
          roomID: context.read<GameDetailsCubit>().getRoomID()))
      ..add(ListenToGameConclusion())
      ..add(ListenToPlayAgainRequest())
      ..add(ListenToPlayAgainResponse())
      ..add(ListenToOtherPlayerDisconnect())
      ..add(ListenToQrScanned());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        GameHelper().showBackDialog(context, resetAllStateAndMoveBack);
      },
      child: Scaffold(
        key: _scaffoldKey,
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
                // adding to player turn to cubit
                context
                    .read<GameDetailsCubit>()
                    .setPlayerTurn(socketBlocState.playersInfo["Player 1"]);

                // listening to event
                context.read<SocketBloc>().add(ListenToEvent());

                ref
                    .watch(allPlayersProvider.notifier)
                    .addPlayers(socketBlocState.playersInfo);

                ref
                    .watch(waitingForOtherPlayerConnectionProvider.notifier)
                    .state = false;
              } else if (socketBlocState is CellsDetailsBlocState) {
                context
                    .read<GameDetailsCubit>()
                    .setPlayerTurn(socketBlocState.playerTurn);
                context
                    .read<GameDetailsCubit>()
                    .addSelectedCells(socketBlocState.model);
              } else if (socketBlocState is PlayAgainResponseReceivedState) {
                debugPrint("inside listen when Play again response");

                // adding to player turn to cubit
                context.read<GameDetailsCubit>()
                  ..setPlayerTurn(socketBlocState.playerTurn)
                  ..incrementRound();

                // resetting to no button is clicked
                ref.watch(anyButtonClickedProvider.notifier).state = false;

                // resetting all selected cells
                context.read<GameDetailsCubit>().clearSelectedCells();
              } else if (socketBlocState is QrScannedReceived) {
                debugPrint("QR scanned received, going to pop the context");

                bool isQrOpened = ref.watch(qrOpenedProvider);

                if (isQrOpened) {
                  Navigator.pop(context);
                }
              }
            },
            listenWhen: (previous, current) {
              if (previous is CellsDetailsBlocState &&
                  current is GameEndState) {
                debugPrint("Previous: $previous, Current: $current");

                Future.delayed(Duration(milliseconds: 400), () {
// incrementing winner
                  if (current.winner != null) {
                    context
                        .read<GameDetailsCubit>()
                        .incrementWinnerScore(current.winner!);
                  }

                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return DisplayGameConclusion(
                            gameConclusion: current.status,
                            winner: current.winner);
                      });
                });

                return false; // no need to listen to listener now
              }

              // other user is requesting to play again
              else if (current is PlayAgainRequestReceivedState) {
                debugPrint(
                    "Previous: $previous, Current: $current let's play again");

                Navigator.pop(context);

                // find player name using playerID
                var playerName = context
                    .read<GameDetailsCubit>()
                    .getPlayerName(current.playerID);

                _showPlayAgainDialog(playerName);

                return false;
              }

              return true;
            },
            builder: (context, socketBlocState) {
              return Stack(
                children: [
                  // Opacity when needed
                  Opacity(
                    opacity: ref.watch(waitingForOtherPlayerConnectionProvider)
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
                              PlayerProfileCardSocket(
                                  playerInfo: context
                                      .read<GameDetailsCubit>()
                                      .state["players"]
                                      .entries
                                      .first),

                              // Round indicator
                              const RoundIndicatorSocket(),

                              PlayerProfileCardSocket(
                                  playerInfo: context
                                      .read<GameDetailsCubit>()
                                      .state["players"]
                                      .entries
                                      .last),
                            ],
                          ),

                          SizedBox(height: 16.h),

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
                          Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
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
                                    "${getCurrentPlayerTurn()} turn",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              // list of emoji
                              const Align(
                                alignment: Alignment.bottomRight,
                                child: EmojiPanel(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // show loading indicator when waiting for opponent, and make background blur
                  if (ref.watch(waitingForOtherPlayerConnectionProvider))
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

  String getCurrentPlayerTurn() {
    var players = context.read<GameDetailsCubit>().state["players"];
    var currentPlayerTurn =
        context.watch<GameDetailsCubit>().getCurrentPlayerTurn();
    var myUid = context.read<GameDetailsCubit>().getUserId();

    if (currentPlayerTurn == myUid) {
      return "Your";
    }

    for (var entry in players.entries) {
      if (entry.value == currentPlayerTurn) {
        return entry.key;
      }
    }
    return "IronMan's";
  }

  Widget _buildGridCell(int index, BuildContext context) {
    // list of indexes for border
    List<int> borderBottomIndexes = [0, 1, 2, 3, 4, 5];
    List<int> borderRightIndexes = [0, 1, 3, 4, 6, 7];

    return BlocListener<GameDetailsCubit, Map<String, dynamic>>(
      listener: (context, state) {
        if (state["playerTurn"] == state["uid"]) {
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
              child: BlocBuilder<SocketBloc, SocketState>(
                builder: (context, cState) {
                  if (cState is GameEndState && cState.status != "draw") {
                    var winLineType =
                        GameHelper().getWinLineType(cState.winnerSequence!);
                    return selectedCellsDetails.selectedIndex != -1
                        ? _buildSomething(selectedCellsDetails.uid,
                            winLineType: winLineType,
                            hasWinner: cState.winnerSequence!.contains(index))
                        : Text("");
                  } else if (cState is GameEndState &&
                      cState.status == "draw") {
                    return selectedCellsDetails.selectedIndex != -1
                        ? _buildSomething(selectedCellsDetails.uid,
                            isDraw: true)
                        : Text("");
                  }
                  return Center(
                    child: selectedCellsDetails.selectedIndex != -1
                        ? _buildSomething(
                            selectedCellsDetails.uid,
                          )
                        : const Text(" "),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// [hasWinner] is used to draw over the cell
  Widget _buildSomething(
    String selectedBy, {
    // for winner
    bool hasWinner = false,
    WinLineType? winLineType,

    // for draw
    bool isDraw = false,
  }) {
    var allPlayers = context.read<GameDetailsCubit>().state["players"];
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Center(
            child: Image.asset(
                selectedBy == allPlayers["Player 1"]
                    ? "images/check.png"
                    : "images/circle.png",
                height: 54),
          ),
          if (hasWinner) ...{
            // Image.asset("images/cross.png", height: 54),
            CustomLinePainter(
              lineType: winLineType!,
            ),
          } else if (isDraw) ...{
            Center(
              child: Image.asset("images/cross.png", height: 54),
            ),
          }
        ],
      );
    });
  }
}
