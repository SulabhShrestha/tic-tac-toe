import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/cubit/bot_cubit/bot_cubit.dart';
import 'package:mobile/utils/colors.dart';

class PlayerProfileCardBot extends StatelessWidget {
  final String player;

  /// The position of the player in the game, 0 or 1
  final int position;

  const PlayerProfileCardBot({
    super.key,
    required this.player,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // card
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 134,
              padding: const EdgeInsets.only(bottom: 12.0, left: 24, right: 24),
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
                    player,
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
                        position == 0
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
                    player,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),

        // score
        const SizedBox(height: 12),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: ConstantColors.white,
                border: Border.all(
                  color: ConstantColors.blue,
                  width: 1,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 9,
                    blurStyle: BlurStyle.outer,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const Text("Won: "),
                  Text(
                    context.read<BotCubit>().getScore(player).toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ConstantColors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
