import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerIcon extends ConsumerWidget {
  final String playerTitle;
  final String playerUid;

  const PlayerIcon({
    super.key,
    required this.playerUid,
    required this.playerTitle,
  });

  //TODO:
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Container(
          width: playerUid == "12" ? 60 : 40,
          height: playerUid == "12" ? 60 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: playerUid == '12' ? Colors.blue : Colors.green,
          ),
        ),
        Text('12' == playerUid ? "You" : playerTitle),
      ],
    );
  }
}
