import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/views/game_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text("Create Game"),
            ),
            ElevatedButton(
              onPressed: () {
                // alert dialog
                showDialog(
                    context: context,
                    builder: (context) {
                      return _askForRoomId(context);
                    });
              },
              child: const Text("Join Game"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _askForRoomId(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter Room ID"),
      content: TextField(
        decoration: const InputDecoration(hintText: "Enter Room ID"),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            // joining the user to the game
            SocketWebServices socketWebServices = SocketWebServices()
              ..init()
              ..joinRoom(myUid: "123", otherUserId: "456");

            // joining the game on correct room id
            socketWebServices.socket.on("game-init", (gameInit) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GamePage()));
            });
          },
          child: const Text("Join"),
        )
      ],
    );
  }
}
