import 'dart:developer';

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

import 'utils/bot_game_helper.dart';
import 'widget/player_profile_card_bot.dart';

class BotGamePage extends StatefulWidget {
  const BotGamePage({super.key});

  @override
  State<BotGamePage> createState() => _BotGamePageState();
}

class _BotGamePageState extends State<BotGamePage> {
  @override
  void initState() {
    log("Inside BotGamePage initState");
    super.initState();
  }

  @override
  void dispose() {
    log("Inside BotGamePage dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final botCubit = context.read<BotCubit>();
    final players = botCubit.getPlayers();

    debugPrint("Inside BotGamePage: $players");

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        GameHelper().showBackDialog(context, () {
          botCubit.clearData();
          Navigator.popUntil(context, (route) => route.isFirst);
        });
      },
      child: Scaffold(
        body: BlocListener<BotCubit, BotState>(
          listener: (_, state) {
            if (state.gameEnd != null &&
                state.gameEnd != BotGameConclusion.notYet) {
              var conclusionText = "";
              if (state.gameEnd == BotGameConclusion.botWin) {
                conclusionText = "Bot won";
              } else if (state.gameEnd == BotGameConclusion.draw) {
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
