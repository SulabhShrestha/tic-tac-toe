import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/tic_tac_model.dart';
import 'package:mobile/providers/tic_tac_providers.dart';
import 'package:mobile/services/socket_web_services.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late SocketWebServices socketWebServices;

  @override
  void initState() {
    socketWebServices = SocketWebServices()..init();
    socketWebServices.joinRoom(myUid: "123", otherUserId: "456");

    socketWebServices.socket.on("event", (data) {
      ref.watch(ticTacProvider.notifier).addTicTac(TicTacModel(
          myUID: data["to"],
          otherUID: data["from"],
          selectedIndex: data["selectedIndex"]));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // who's turn
          const Text("Your turn"),

          GridView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            children: [
              for (int a = 0; a < 9; a++) _buildGridCell(a),
            ],
          ),
        ],
      )),
    );
  }

  Widget _buildGridCell(int index) {
    var ticTacProv = ref.watch(ticTacProvider); // Assuming you are using hooks

    bool isSelected = ticTacProv.any((model) => model.selectedIndex == index);

    return GestureDetector(
      onTap: () {
        socketWebServices.sendData(data: {
          "from": "123",
          "to": "456",
          "selectedIndex": index,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: Center(
          child: isSelected ? Text("hy") : Text("Hello"),
        ),
      ),
    );
  }
}
