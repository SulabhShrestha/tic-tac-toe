import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/cubit/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/socket_bloc/socket_bloc.dart';
import 'package:mobile/utils/colors.dart';
import 'package:mobile/views/game_page/utils/custom_toast.dart';

class PlayerProfileCardSocket extends StatelessWidget {
  final MapEntry<String, dynamic> playerInfo;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;

  const PlayerProfileCardSocket({
    super.key,
    required this.playerInfo,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final gameDetailsCubit = context.read<GameDetailsCubit>();

    // Player 1 -> P1
    var playerAbbreviation =
        playerInfo.key.split(" ")[0][0] + playerInfo.key.split(" ")[1][0];
    // again if the player is me, then show "You"
    playerAbbreviation = playerInfo.value == gameDetailsCubit.getUserId()
        ? "You"
        : playerAbbreviation;

    return BlocConsumer<SocketBloc, SocketState>(
      listener: (context, state) {
        if (state is OtherPlayerDisconnectedState) {
          CustomToast.show("${playerInfo.key} left the game"); 
        }
      },
      builder: (context, state) {
        var leftChat = state is OtherPlayerDisconnectedState &&
            state.uid == playerInfo.value;
        return Opacity(
          opacity: leftChat ? 0.5 : 1,
          child: Column(
            children: [
              // card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 134,
                    padding:
                        EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                      color: ConstantColors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          gameDetailsCubit.getUserId() == playerInfo.value
                              ? "You"
                              : playerInfo.key,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: const BoxDecoration(
                            color: ConstantColors.red,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: Image.asset(
                              playerInfo.key == "Player 1"
                                  ? "images/close.png"
                                  : "images/circle.png",
                              height: 24),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -26,
                    right: 0,
                    left: 0,
                    child: Container(
                      width: 56.r,
                      height: 56.r,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE4C34E), Color(0xFF21CA94)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          playerAbbreviation,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // score
              SizedBox(height: 14.h),
              BlocBuilder<SocketBloc, SocketState>(
                builder: (context, state) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: ConstantColors.white,
                          border: Border.all(
                            color: ConstantColors.blue,
                            width: 1,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 9,
                              blurStyle: BlurStyle.outer,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            const Text("Won: "),
                            Text(
                              gameDetailsCubit
                                  .getScore(playerInfo.key.toString())
                                  .toString(),
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: ConstantColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // emoji displaying
                      if (state is EmojiReceivedBlocState &&
                          state.emojiModel.senderUid ==
                              playerInfo.value.toString())
                        AnimatedPositioned(
                          top: -32,
                          duration: const Duration(seconds: 1),
                          child: SvgPicture.asset(state.emojiModel.emojiPath),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
