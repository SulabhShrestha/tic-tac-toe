import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/providers/room_details_provider.dart';
import 'package:mobile/providers/socket_web_service_provider.dart';

class EmojiPanel extends ConsumerWidget {
  EmojiPanel({super.key});

  final _emojiMenuController = MenuController();

  List<String> emojis = ["images/emojis/cry.svg", "images/emojis/laugh.svg"];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socketWebServices = ref.read(socketWebServiceProvider);
    return MenuAnchor(
      controller: _emojiMenuController,
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_horiz),
          tooltip: 'Show menu',
        );
      },
      menuChildren: [
        MenuItemButton(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                for (var emoji in emojis)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        debugPrint("Emoji clicked: $emoji");

                        _emojiMenuController.close();

                        socketWebServices.sendEmojiEvent(
                            roomID: ref.read(roomDetailsProvider),
                            emojiPath: emoji);
                      },
                      child: SvgPicture.asset(
                        emoji,
                        height: 42,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
