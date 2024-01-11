import 'package:flutter/material.dart';
import 'package:mobile/services/socket_web_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    SocketWebServices().init();
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
              _buildGridCell(),
              _buildGridCell(),
              _buildGridCell(),
              _buildGridCell(),
              _buildGridCell(),
              _buildGridCell(),
              _buildGridCell(),
              _buildGridCell(),
              _buildGridCell(),
            ],
          ),
        ],
      )),
    );
  }

  Widget _buildGridCell() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: const Center(
        child: Text("Hello"),
      ),
    );
  }
}
