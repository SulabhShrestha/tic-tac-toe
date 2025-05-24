import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/service/activity_logger.dart';
import 'package:mobile/cubit/bot_cubit/bot_cubit.dart';
import 'package:mobile/cubit/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/mixins/activity_logger_mx.dart';
import 'package:mobile/providers/any_button_clicked.dart';
import 'package:mobile/providers/join_button_loading_provider.dart';
import 'package:mobile/providers/waiting_for_other_player_connection_provider.dart';
import 'package:mobile/socket_bloc/socket_bloc.dart';
import 'package:mobile/views/homepage/widgets/ask_room_ID.dart';
import 'package:mobile/views/homepage/widgets/gradient_button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'widgets/loading_button_with_text.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with ActivityLoggerMx {
  @override
  Widget build(BuildContext context) {
    var anyButtonClickedProv = ref.watch(anyButtonClickedProvider);
    var joiningButtonLoadingProv = ref.watch(joinButtonLoadingProvider);

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
                ref
                    .read(anyButtonClickedProvider.notifier)
                    .update((state) => false);

                ref
                    .read(waitingForOtherPlayerConnectionProvider.notifier)
                    .update((state) => true);

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
                        ? () {
                            logActivity(
                                activityType: ActivityType.cancelCreateGame);
                            debugPrint("Loading should be cancelled");
                            ref
                                .read(anyButtonClickedProvider.notifier)
                                .update((state) => false);
                            context.read<SocketBloc>().add(DisconnectSocket());
                          }
                        : () {
                            logActivity(activityType: ActivityType.createGame);
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
                      onTap: joiningButtonLoadingProv
                          ? () {
                              logActivity(
                                  activityType: ActivityType.cancelJoinGame);
                              debugPrint("Loading should be cancelled");
                              ref
                                  .read(joinButtonLoadingProvider.notifier)
                                  .update((state) => false);
                              context
                                  .read<SocketBloc>()
                                  .add(DisconnectSocket());
                            }
                          : () {
                              // alert dialog
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const AskRoomID();
                                  });
                            },
                      child: joiningButtonLoadingProv
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(),
                            )
                          : const Text("Join Game")),

                  // Playing with Bot
                  const SizedBox(height: 42),
                  GradientButton(
                      linearGradient: const LinearGradient(
                          colors: [Colors.green, Colors.blue]),
                      onTap: anyButtonClickedProv
                          ? () {}
                          : () {
                              logActivity(
                                  activityType: ActivityType.playWithBot);
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
}
