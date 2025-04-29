import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile/utils/colors.dart';

class ColorChangingLoadingWidget extends HookWidget {
  const ColorChangingLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    return CircularProgressIndicator(
      valueColor: controller.drive(
        ColorTween(
          begin: ConstantColors.red,
          end: Colors.white,
        ),
      ),
    );
  }
}
