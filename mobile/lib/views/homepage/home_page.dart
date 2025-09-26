import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/core/service/activity_logger.dart';
import 'package:mobile/cubit/bot_cubit/bot_cubit.dart';
import 'package:mobile/cubit/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/mixins/activity_logger_mx.dart';
import 'package:mobile/providers/any_button_clicked.dart';
import 'package:mobile/providers/join_button_loading_provider.dart';
import 'package:mobile/providers/waiting_for_other_player_connection_provider.dart';
import 'package:mobile/socket_bloc/socket_bloc.dart';
import 'package:mobile/utils/colors.dart';
import 'package:mobile/views/homepage/widgets/ask_room_ID.dart';
import 'package:mobile/views/homepage/widgets/gradient_button.dart';
import 'package:mobile/views/homepage/widgets/online_play_options.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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

    WakelockPlus.enable();

    return Scaffold(
      body: SafeArea(
        top: false,
        maintainBottomViewPadding: true,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.center,
              colors: [
                ConstantColors.white,
                Color(0xFFFFE4E1),
              ],
            ),
          ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "images/cross.svg",
                        height: 120.h,
                      ),
                      SvgPicture.asset(
                        "images/circle.svg",
                        height: 120.h,
                      ),
                    ],
                  ),
                  42.verticalSpace,

                  Text(
                    "Choose a play mode",
                    style: TextStyle(
                      color: ConstantColors.blue,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  16.verticalSpace,
                  GradientButton(
                    height: 42.h,
                    width: 0.7.sw,
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          // enableDrag: false,
                          useSafeArea: false,
                          builder: (_) {
                            return const OnlinePlayOptions();
                          });
                    },
                    child: Text(
                      "With Friend",
                      style: TextStyle(
                        fontSize: 16.sp,
                      ),
                    ),
                  ),

                  // Playing with Bot
                  SizedBox(height: 16.h),
                  GradientButton(
                    height: 42.h,
                    width: 0.7.sw,
                    linearGradient: const LinearGradient(
                        colors: [Colors.green, Colors.blue]),
                    onTap: anyButtonClickedProv
                        ? () {}
                        : () {
                            logActivity(activityType: ActivityType.playWithBot);
                            context.read<BotCubit>().initGame();
                            Navigator.of(context).pushNamed("/bot-game");
                          },
                    child: Text(
                      "With Bot",
                      style: TextStyle(
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
