import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/cubit/bot_cubit/bot_cubit.dart';
import 'package:mobile/utils/game_helper.dart';
import 'package:mobile/views/bot_game_page/widget/game_over_dialog.dart';
import 'package:mobile/views/bot_game_page/widget/round_indicator_bot.dart';
import 'package:mobile/views/bot_game_page/widget/tic_tac_board_bot.dart';
import 'package:mobile/views/game_page/widgets/round_indicator_socket.dart';
import 'package:mobile/views/homepage/widgets/gradient_button.dart';

import 'widget/player_profile_card_bot.dart';

class BotGamePage extends StatelessWidget {
  const BotGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final botCubit = context.read<BotCubit>();
    final players = botCubit.getPlayers();

    debugPrint("Inside BotGamePage: $players");

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        GameHelper().showBackDialog(context, () {
          botCubit.clearData();
          Navigator.pushNamedAndRemoveUntil(context, "/", (route) => true);
        });
      },
      child: Scaffold(
        body: BlocListener<BotCubit, Map<String, dynamic>>(
          listener: (_, state) {
            if (state["game-end"] != null) {
              var conclusionText = "";
              if (state["game-end"] == "Bot") {
                conclusionText = "Bot won";
              } else if (state["game-end"] == "Draw") {
                conclusionText = "Draw";
              } else {
                conclusionText = "You won";
              }
              if (Navigator.canPop(context)) {
                Future.delayed(Duration(milliseconds: 200), () {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return Dialog(
                          child: GameOverDialog(conclusionText: conclusionText),
                        );
                      });
                });
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game information, player and bot
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PlayerProfileCardBot(player: players.first, position: 0),

                    // Round indicator
                    const RoundIndicatorBot(),

                    PlayerProfileCardBot(player: players.last, position: 1),
                  ],
                ),

                SizedBox(height: 16.h),

                const TicTacBoardBot(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
