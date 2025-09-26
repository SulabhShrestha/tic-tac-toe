import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile/core/service/activity_logger.dart';
import 'package:mobile/cubit/game_details_cubit/game_details_cubit.dart';
import 'package:mobile/mixins/activity_logger_mx.dart';
import 'package:mobile/providers/any_button_clicked.dart';
import 'package:mobile/providers/join_button_loading_provider.dart';
import 'package:mobile/socket_bloc/socket_bloc.dart';
import 'package:mobile/views/homepage/widgets/ask_room_ID.dart';
import 'package:mobile/views/homepage/widgets/gradient_button.dart';
import 'package:mobile/views/homepage/widgets/loading_button_with_text.dart';

class OnlinePlayOptions extends ConsumerWidget with ActivityLoggerMx {
  const OnlinePlayOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var anyButtonClickedProv = ref.watch(anyButtonClickedProvider);
    var joiningButtonLoadingProv = ref.watch(joinButtonLoadingProvider);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h).copyWith(
          bottom: 16.h + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingButtonWithText(
              text: "Create Game",
              onTap: anyButtonClickedProv
                  ? () {
                      logActivity(activityType: ActivityType.cancelCreateGame);
                      debugPrint("Loading should be cancelled");
                      ref
                          .read(anyButtonClickedProvider.notifier)
                          .update((state) => false);
                      context.read<SocketBloc>().add(DisconnectSocket());
                    }
                  : () {
                      logActivity(activityType: ActivityType.createGame);
                      // setting the value of any button clicked
                      ref.read(anyButtonClickedProvider.notifier).state = true;

                      debugPrint("Loading");

                      context.read<SocketBloc>()
                        ..add(InitSocket())
                        ..add(CreateRoom(
                            myUid:
                                context.read<GameDetailsCubit>().getUserId()));
                    },
            ),
            const SizedBox(height: 20),
            GradientButton(
                linearGradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.deepOrange]),
                onTap: joiningButtonLoadingProv
                    ? () {
                        logActivity(activityType: ActivityType.cancelJoinGame);
                        debugPrint("Loading should be cancelled");
                        ref
                            .read(joinButtonLoadingProvider.notifier)
                            .update((state) => false);
                        context.read<SocketBloc>().add(DisconnectSocket());
                      }
                    : () {
                        // alert dialog
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const AskRoomID();
                            });
                      },
                child: joiningButtonLoadingProv
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Text("Join Game")),
          ],
        ),
      ),
    );
  }
}
