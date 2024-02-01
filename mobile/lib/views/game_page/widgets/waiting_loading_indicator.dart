import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/room_details_provider.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Waiting for opponent",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        CircularProgressIndicator(
          valueColor: _controller.drive(
            ColorTween(
              begin: Colors.white,
              end: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            secondWordBold("Room ID: ", ref.watch(roomDetailsProvider)),
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
                        Clipboard.setData(ClipboardData(
                            text: ref.watch(roomDetailsProvider)));
                      },
                icon: Icon(
                  Icons.content_copy,
                  color:
                      isCopied ? Colors.grey.shade500 : const Color(0xFF2D4BFF),
                )),
          ],
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
