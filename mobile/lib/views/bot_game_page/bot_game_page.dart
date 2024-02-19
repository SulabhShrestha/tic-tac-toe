import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/views/bot_game_page/widget/round_indicator.dart';
import 'package:mobile/views/bot_game_page/widget/tic_tac_board.dart';
import 'package:mobile/views/game_page/widgets/player_profile_card.dart';

import 'bloc/socket_bloc.dart';

class BotGamePage extends StatelessWidget {
  const BotGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final playerInfo = {"Player 1": "uid1", "Player 2": "uid2"}.entries;
    final socketBloc = BlocProvider.of<SocketBloc>(context);

    socketBloc.add(InitSocket());
    socketBloc.add(SendEvent());
    socketBloc.add(ListenToEvent());
    socketBloc.add(CreateRoom(myUid: '11212'));
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<SocketBloc, SocketState>(
            bloc: socketBloc,
            builder: (context, state) {
              if (state is RoomCreated) {
                return Text("State: ${state.roomID}");
              }
              return SizedBox();
            },
          ),
          // Game information, player and bot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PlayerProfileCard(playerInfo: playerInfo.first),

              // Round indicator
              const RoundIndicator(),

              PlayerProfileCard(playerInfo: playerInfo.last),
            ],
          ),

          TicTacBoard(),
        ],
      ),
    );
  }
}
