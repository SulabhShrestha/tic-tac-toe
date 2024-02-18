import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// stores list of path of emojis received from the server
///

final emojiReceivedProvider =
    StateNotifierProvider<EmojiReceivedProvider, Map<String, dynamic>>(
        (ref) => EmojiReceivedProvider());

class EmojiReceivedProvider extends StateNotifier<Map<String, dynamic>> {
  EmojiReceivedProvider() : super({});

  void addEmoji(Map<String, dynamic> emojiPath) async {
    state = emojiPath;

    await Future.delayed(
      const Duration(seconds: 1),
      () {
        state = {};

        debugPrint("Emoji removed: $emojiPath $state");
      },
    );
  }
}
