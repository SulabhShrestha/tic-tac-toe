import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/player_turn_provider.dart';
import 'package:mobile/providers/user_id_provider.dart';

class PlayerIcon extends ConsumerWidget {
  final String playerTitle;
  final String playerUid;

  const PlayerIcon({
    super.key,
    required this.playerUid,
    required this.playerTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var playerTurnProv = ref.read(playerTurnProvider);
    var userIdProv = ref.read(userIdProvider);
    return Column(
      children: [
        Container(
          width: playerUid == playerTurnProv ? 60 : 40,
          height: playerUid == playerTurnProv ? 60 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: playerUid == playerTurnProv ? Colors.blue : Colors.green,
          ),
        ),
        Text(userIdProv == playerUid ? "You" : playerTitle),
      ],
    );
  }
}
