import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/all_players_provider.dart';
import 'package:mobile/providers/game_conclusion_provider.dart';
import 'package:mobile/providers/room_details_provider.dart';

import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/utils/tic_tac_utils.dart';
import 'package:mobile/views/game_page/widgets/bold_first_word.dart';
import 'package:mobile/views/homepage/widgets/loading_button_with_text.dart';

class DisplayGameConclusion extends ConsumerStatefulWidget {
  final SocketWebServices socketWebServices;
  const DisplayGameConclusion({
    super.key,
    required this.socketWebServices,
  });

  @override
  ConsumerState<DisplayGameConclusion> createState() =>
      _DisplayGameConclusionState();
}

class _DisplayGameConclusionState extends ConsumerState<DisplayGameConclusion> {
  bool hasClicked = false;

  @override
  Widget build(BuildContext context) {
    var gameConclusion = ref.watch(gameConclusionProvider);

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
              if (gameConclusion["conclusion"] == GameConclusion.draw)
                const Text("Draw"),

              if (gameConclusion["conclusion"] == GameConclusion.win)
                BoldFirstWord(
                  boldWord: getKeyFromValue(gameConclusion["winner"])!,
                  remainingWords: " won the game",
                ),

              const SizedBox(height: 8),

              LoadingButtonWithText(
                  text: "Play Again",
                  onTap: () {
                    widget.socketWebServices.sendPlayAgainEvent(
                      roomID: ref.read(roomDetailsProvider),
                      uid: ref.read(userIdProvider),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  String? getKeyFromValue(dynamic targetValue) {
    var map = ref.read(allPlayersProvider);
    for (var entry in map.entries) {
      if (entry.value == targetValue) {
        return entry.key;
      }
    }
    return null;
  }
}
