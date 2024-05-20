import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/cubit/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/providers/any_button_clicked.dart';
import 'package:mobile/providers/join_button_loading_provider.dart';
import 'package:mobile/socket_bloc/socket_bloc.dart';
import 'package:mobile/views/homepage/widgets/loading_button_with_text.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AskRoomID extends ConsumerStatefulWidget {
  const AskRoomID({super.key});

  @override
  ConsumerState<AskRoomID> createState() => _AskRoomIDState();
}

class _AskRoomIDState extends ConsumerState<AskRoomID> {
  final TextEditingController roomIDController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocketBloc, SocketState>(
      listener: (context, state) {
        if (state is GameStart) {
          debugPrint("Game started");

          ref.read(anyButtonClickedProvider.notifier).update((state) => false);

          ref.read(joinButtonLoadingProvider.notifier).update((state) => false);

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
                                if (ref.watch(joinButtonLoadingProvider)) {
                                  return;
                                }

                                Navigator.pop(context);

                                log("message: ${capturedData.barcodes.first.displayValue}");

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
                onTap: ref.watch(joinButtonLoadingProvider)
                    ? () {
                        debugPrint("Loading should be cancelled");
                        ref
                            .read(joinButtonLoadingProvider.notifier)
                            .update((state) => false);
                        context.read<SocketBloc>().add(DisconnectSocket());
                      }
                    : () {
                        focusNode.unfocus();
                        joinSocketRoom(context, ref, roomIDController.text);
                        ref
                            .read(joinButtonLoadingProvider.notifier)
                            .update((state) => true);
                      }),
          ],
        );
      },
    );
  }

  void joinSocketRoom(BuildContext context, WidgetRef ref, String roomID,
      {bool isFromQR = false}) {
    ref.read(joinButtonLoadingProvider.notifier).update((state) => true);

    log("I am joining room");

    context.read<SocketBloc>()
      ..add(InitSocket())
      ..add(JoinRoom(
          roomID: roomID, myUid: context.read<GameDetailsCubit>().getUserId()))
      ..add(ListenToRoomNotFoundEvent())
      ..add(ListenToGameInitEvent());

    context.read<GameDetailsCubit>().setRoomID(roomID);

    if (isFromQR) {
      log("Room ID joiningR: $roomID");

      // sending qr scanned event
      context.read<SocketBloc>().add(QrScanned(roomID: roomID));
    }
  }
}
