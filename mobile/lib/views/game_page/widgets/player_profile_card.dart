import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/utils/colors.dart';

class PlayerProfileCard extends ConsumerWidget {
  final MapEntry<String, dynamic> playerInfo;
  const PlayerProfileCard({
    super.key,
    required this.playerInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var playerAbbreviation = playerInfo.key.split(" ")[0][0] +
        playerInfo.key.split(" ")[1][0]; // Player 1 -> P1
    var myUid = ref.read(userIdProvider);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 134,
          width: 134,
          padding: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
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
                playerInfo.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: const BoxDecoration(
                  color: ConstantColors.red,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Image.asset(
                    playerInfo.value == myUid
                        ? "images/close.png"
                        : "images/circle.png",
                    height: 24),
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          right: 0,
          left: 0,
          child: Container(
            width: 62,
            height: 62,
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
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}