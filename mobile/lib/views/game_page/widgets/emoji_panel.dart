import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/cubit/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/socket_bloc/socket_bloc.dart';

class EmojiPanel extends ConsumerWidget {
  const EmojiPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emojiMenuController = MenuController();

    List<String> emojis = [
      "images/emojis/cry.svg",
      "images/emojis/laugh.svg",
      "images/emojis/angry.svg",
      "images/emojis/joker.svg",
      "images/emojis/poop.svg",
      "images/emojis/squinting.svg",
    ];
    return MenuAnchor(
      controller: emojiMenuController,
      alignmentOffset: const Offset(0, -12),
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

                        emojiMenuController.close();

                        final gameDetailsCubit =
                            context.read<GameDetailsCubit>();

                        context.read<SocketBloc>().add(SendEmoji(
                              emojiPath: emoji,
                              uid: gameDetailsCubit.getUserId(),
                              roomID: gameDetailsCubit.getRoomID(),
                            ));
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
