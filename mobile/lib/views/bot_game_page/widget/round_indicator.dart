import 'package:flutter/material.dart';

class RoundIndicator extends StatelessWidget {
  const RoundIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.amber, Colors.amber.shade700],
        ),
      ),
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Round", style: TextStyle(fontSize: 16)),
          Text(
            "69",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
