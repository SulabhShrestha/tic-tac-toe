import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/cubit/bot_cubit/bot_cubit.dart';
import 'package:mobile/views/homepage/widgets/gradient_button.dart';

class GameOverDialog extends StatelessWidget {
  final String conclusionText;

  const GameOverDialog({super.key, required this.conclusionText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Game Over",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          conclusionText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GradientButton(
              width: 80,
              linearGradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade200]),
              onTap: () {
                context.read<BotCubit>().clearData();
                Navigator.pushNamedAndRemoveUntil(
                    context, "/", (route) => true);
              },
              child: const Text("Exit"),
            ),
            const SizedBox(width: 12),
            GradientButton(
              width: 90,
              onTap: () {
                context.read<BotCubit>().incrementRound();
                Navigator.pop(context);
              },
              child: const Text("Again"),
            ),
            16.horizontalSpace,
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
