import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/cubit/bot_cubit/bot_cubit.dart';
import 'package:mobile/utils/game_helper.dart';
import 'package:mobile/views/bot_game_page/widget/tic_tac_board_bot.dart';
import 'package:mobile/views/game_page/widgets/round_indicator_socket.dart';

import 'widget/player_profile_card_bot.dart';

class BotGamePage extends StatelessWidget {
  const BotGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final botCubit = context.read<BotCubit>();
    final players = botCubit.getPlayers();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        GameHelper().showBackDialog(context, () {
          botCubit.clearData();
          Navigator.pushNamedAndRemoveUntil(context, "/", (route) => true);
        });
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game information, player and bot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PlayerProfileCardBot(player: players.first, position: 0),

                // Round indicator
                const RoundIndicatorSocket(),

                PlayerProfileCardBot(player: players.last, position: 1),
              ],
            ),

            const TicTacBoardBot(),
          ],
        ),
      ),
    );
  }
}
