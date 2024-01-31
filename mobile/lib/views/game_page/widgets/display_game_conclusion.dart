import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/game_conclusion_provider.dart';
import 'package:mobile/providers/room_details_provider.dart';

import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/utils/tic_tac_utils.dart';

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
              if (ref.watch(gameConclusionProvider)["conclusion"] ==
                  GameConclusion.draw)
                const Text("Draw"),

              if (ref.watch(gameConclusionProvider)["conclusion"] ==
                  GameConclusion.win)
                Text(
                    "${ref.watch(gameConclusionProvider)["winner"]} won the game"),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    hasClicked = true;
                  });
                  widget.socketWebServices.sendPlayAgainEvent(
                    roomID: ref.read(roomDetailsProvider),
                    uid: ref.read(userIdProvider),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasClicked) const CircularProgressIndicator(),
                    const Text("Play Again"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
