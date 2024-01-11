import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
