import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/cubit/bot_cubit/bot_cubit.dart';
import 'package:mobile/cubit/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/providers/any_button_clicked.dart';
import 'package:mobile/providers/join_button_loading_provider.dart';
import 'package:mobile/providers/waiting_for_connection_provider.dart';
import 'package:mobile/socket_bloc/socket_bloc.dart';
import 'package:mobile/views/homepage/widgets/gradient_button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'widgets/loading_button_with_text.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var anyButtonClickedProv = ref.watch(anyButtonClickedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDDCE6),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: BlocConsumer<SocketBloc, SocketState>(
            listener: (context, state) {
              if (state is RoomCreated) {
                context.read<GameDetailsCubit>().setRoomID(state.roomID);

                // resetting the button clicked value
                ref.read(anyButtonClickedProvider.notifier).state = false;

                ref.read(waitingForConnectionProvider.notifier).state = true;

                Navigator.of(context).pushNamed("/game", arguments: {
                  "players": <String, dynamic>{},
                });
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LoadingButtonWithText(
                    text: "Create Game",
                    onTap: anyButtonClickedProv
                        ? null
                        : () {
                            // setting the value of any button clicked
                            ref.read(anyButtonClickedProvider.notifier).state =
                                true;

                            debugPrint("Loading");

                            context.read<SocketBloc>()
                              ..add(InitSocket())
                              ..add(CreateRoom(
                                  myUid: context
                                      .read<GameDetailsCubit>()
                                      .getUserId()));
                          },
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                      linearGradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.deepOrange]),
                      onTap: anyButtonClickedProv
                          ? () {}
                          : () {
                              // alert dialog
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return _askForRoomId(context, ref);
                                  });
                            },
                      child: const Text("Join Game")),

                  // Playing with Bot
                  const SizedBox(height: 42),
                  GradientButton(
                      linearGradient: const LinearGradient(
                          colors: [Colors.green, Colors.blue]),
                      onTap: anyButtonClickedProv
                          ? () {}
                          : () {
                              context.read<BotCubit>().initGame();
                              Navigator.of(context).pushNamed("/bot-game");
                            },
                      child: const Text("Play with Bot")),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _askForRoomId(BuildContext context, WidgetRef ref) {
    final TextEditingController roomIDController = TextEditingController();
    final FocusNode focusNode = FocusNode();
    return BlocConsumer<SocketBloc, SocketState>(
      listener: (context, state) {
        if (state is GameStart) {
          debugPrint("Game started");
          // vibrating the device
          Future(() async {
            await HapticFeedback.vibrate();
            await SystemSound.play(SystemSoundType.click);
          });

          // listen to event
          context.read<SocketBloc>().add(ListenToEvent());

          // adding players info to the game details cubit
          context.read<GameDetailsCubit>().setPlayers(state.playersInfo);
          context
              .read<GameDetailsCubit>()
              .setPlayerTurn(state.playersInfo["Player 1"]);

          Navigator.of(context).pushNamed("/game", arguments: {
            "players": state.playersInfo,
          });
        } else if (state is RoomNotFound) {
          debugPrint("Room not found");
          Navigator.pop(context);

          // resetting value
          ref.read(anyButtonClickedProvider.notifier).state = false;

          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Room not found")));
        }
      },
      builder: (context, state) {
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
      },
    );
  }

  void joinSocketRoom(BuildContext context, WidgetRef ref, String roomID,
      {bool isFromQR = false}) {
    ref.read(anyButtonClickedProvider.notifier).state = true;

    if (isFromQR) {
      // triggering loading button
      ref.read(joinButtonLoadingProvider.notifier).state = true;
    }
    context.read<SocketBloc>()
      ..add(InitSocket())
      ..add(JoinRoom(
          roomID: roomID, myUid: context.read<GameDetailsCubit>().getUserId()));
    context.read<SocketBloc>().add(ListenToRoomNotFoundEvent());
    context.read<SocketBloc>().add(ListenToGameInitEvent());

    context.read<GameDetailsCubit>().setRoomID(roomID);
  }
}
