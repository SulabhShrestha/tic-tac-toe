import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile/cubit/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/views/game_page/widgets/color_changing_loading_widget.dart';
import 'package:mobile/views/game_page/widgets/qr_code_widget.dart';
import 'package:mobile/views/homepage/widgets/gradient_button.dart';


class WaitingLoadingIndicator extends HookConsumerWidget {
  final GlobalKey keyForQrCode;
  const WaitingLoadingIndicator({
    super.key,
    required this.keyForQrCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomID = context.read<GameDetailsCubit>().getRoomID();
    // if the room id is copied
    final _isCopied = useValueNotifier(false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        const Text(
          "Waiting for opponent",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const ColorChangingLoadingWidget(),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            secondWordBold("Room ID: ", roomID),
            ValueListenableBuilder(
              valueListenable: _isCopied,
              builder: (_, isCopied, __) {
                return IconButton(
                    onPressed: isCopied
                        ? null
                        : () {
                
                              _isCopied.value = true;
                
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
                    ));
              }
            ),
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
                  keyForQrCode: keyForQrCode,
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
