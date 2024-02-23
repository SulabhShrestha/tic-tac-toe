import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/all_players_provider.dart';
import 'package:mobile/providers/any_button_clicked.dart';
import 'package:mobile/providers/game_conclusion_provider.dart';
import 'package:mobile/providers/room_details_provider.dart';
import 'package:mobile/providers/socket_web_service_provider.dart';

import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/views/bloc/game_details_cubit/game_details_cubit.dart';

import 'package:mobile/views/game_page/widgets/bold_first_word.dart';
import 'package:mobile/views/homepage/widgets/loading_button_with_text.dart';

class DisplayGameConclusion extends ConsumerWidget {
  final String gameConclusion; // win or draw
  final String? winner; // player id or null
  const DisplayGameConclusion(
      {super.key, required this.gameConclusion, this.winner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade600, Colors.green],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // conclusion text
              if (gameConclusion == "draw")
                RichText(
                    text: const TextSpan(
                        text: "Draw",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500))),

              if (gameConclusion == "win")
                BoldFirstWord(
                  boldWord: getWinner(context: context)!,
                  remainingWords: " won the game",
                ),

              const SizedBox(height: 16),

              LoadingButtonWithText(
                  text: "Play Again",
                  onTap: ref.read(anyButtonClickedProvider)
                      ? null
                      : () {
                          ref.read(anyButtonClickedProvider.notifier).state =
                              true;
                          // socketWebServices.sendPlayAgainEvent(
                          //   roomID: ref.read(roomDetailsProvider),
                          //   uid: ref.read(userIdProvider),
                          // );
                        }),
            ],
          ),
        ),
      ),
    );
  }

  // return either Player 1 or Player 2 or You
  String? getWinner({required BuildContext context, String? wonBy}) {
    var uid = context.read<GameDetailsCubit>().getUserId();

    if (gameConclusion == "win" && uid == wonBy) {
      return "You";
    }

    for (var entry in context.read<GameDetailsCubit>().getPlayers().entries) {
      if (entry.value == winner) {
        return entry.key;
      }
    }

    return null;
  }
}
