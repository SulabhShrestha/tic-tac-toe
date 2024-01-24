import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/waiting_for_connection_provider.dart';
import 'package:mobile/services/socket_web_services.dart';

class LoadingButtonWithText extends ConsumerStatefulWidget {
  final String text;
  final VoidCallback onTap;

  const LoadingButtonWithText({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  ConsumerState<LoadingButtonWithText> createState() =>
      _LoadingButtonWithTextState();
}

class _LoadingButtonWithTextState extends ConsumerState<LoadingButtonWithText> {
  bool isLoading = false;

  @override
  void initState() {
    // [isLoading] depends primarily on waitingConnection
    isLoading = ref.read(waitingForConnectionProvider);

    SocketWebServices()
      ..init()
      ..socket.on("room-not-found", (_) {
        debugPrint("Room not found");
        setState(() {
          isLoading = false;
        });
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isLoading = true;
        });
        widget.onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) CircularProgressIndicator(),
          Text(widget.text),
        ],
      ),
    );
  }
}
