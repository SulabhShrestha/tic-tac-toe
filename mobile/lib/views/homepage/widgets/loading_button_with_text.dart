import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/any_button_clicked.dart';
import 'package:mobile/providers/join_button_loading_provider.dart';

import 'package:mobile/utils/colors.dart';
import 'package:mobile/views/homepage/widgets/gradient_button.dart';

class LoadingButtonWithText extends ConsumerStatefulWidget {
  final String text;
  final VoidCallback? onTap;

  const LoadingButtonWithText({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  ConsumerState<LoadingButtonWithText> createState() =>
      _LoadingButtonWithTextState();
}

class _LoadingButtonWithTextState extends ConsumerState<LoadingButtonWithText> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onTap: () {
        setState(() {
          isLoading = !isLoading;
        });

        ref
            .read(anyButtonClickedProvider.notifier)
            .update((state) => isLoading);

        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      linearGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [ConstantColors.yellow, ConstantColors.red],
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.text,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.fade,
              ),
            ),
    );
  }
}
