import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile/services/socket_web_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SocketWebServices socketWebServices;

  @override
  void initState() {
    socketWebServices = SocketWebServices()..init();
    socketWebServices.joinRoom(myUid: "123", otherUserId: "456");

    socketWebServices.socket.on("event", (data) {
      log("Data from socket $data");
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
        child: const Center(
          child: Text("Hello"),
        ),
      ),
    );
  }
}
