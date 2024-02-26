import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/cubit/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/providers/qr_closed_provider.dart';
import 'package:mobile/utils/colors.dart';
import 'package:mobile/views/homepage/widgets/gradient_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WaitingLoadingIndicator extends ConsumerStatefulWidget {
  const WaitingLoadingIndicator({super.key});

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
            ref.read(qrClosedProvider.notifier).state = true;

            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: SizedBox(
                    width: 400,
                    height: 400,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 50,
                          bottom: 0,
                          child: Container(
                            height: 200,
                            width: 200,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  ConstantColors.yellow,
                                  ConstantColors.yellow,
                                  Colors.lime,
                                ],
                              ),
                            ),
                            child: QrImageView(
                              data: roomID,
                              version: QrVersions.auto,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.red.shade200,
                                Colors.red.shade600
                              ]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                ref.read(qrClosedProvider.notifier).state =
                                    true;
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
