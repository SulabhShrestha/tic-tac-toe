import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/cubit/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/utils/colors.dart';
import 'package:mobile/views/game_page/widgets/qr_code_widget.dart';
import 'package:mobile/views/homepage/widgets/gradient_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WaitingLoadingIndicator extends ConsumerStatefulWidget {
  final GlobalKey keyForQrCode;
  const WaitingLoadingIndicator({
    super.key,
    required this.keyForQrCode,
  });

  @override
  ConsumerState<WaitingLoadingIndicator> createState() =>
      _WaitingLoadingIndicatorState();
}

class _WaitingLoadingIndicatorState
    extends ConsumerState<WaitingLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // if the room id is copied
  bool isCopied = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomID = context.read<GameDetailsCubit>().getRoomID();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const Text(
          "Waiting for opponent",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        CircularProgressIndicator(
          valueColor: _controller.drive(
            ColorTween(
              begin: ConstantColors.red,
              end: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            secondWordBold("Room ID: ", roomID),
            IconButton(
                onPressed: isCopied
                    ? null
                    : () {
                        setState(() {
                          isCopied = true;
                        });
                        // showing snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Copied to clipboard"),
                          ),
                        );
                        Clipboard.setData(ClipboardData(text: roomID));
                      },
                icon: Icon(
                  Icons.content_copy,
                  color:
                      isCopied ? Colors.grey.shade500 : const Color(0xFF2D4BFF),
                )),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        GradientButton(
          onTap: () {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return QrCodeWidget(
                  keyForQrCode: widget.keyForQrCode,
                  roomID: roomID,
                );
              },
            );
          },
          child: const Text("Show QR"),
        ),
      ],
    );
  }

  Widget secondWordBold(String firstWord, String secondWord) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
              text: firstWord, style: const TextStyle(color: Colors.black)),
          TextSpan(
            text: secondWord,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
