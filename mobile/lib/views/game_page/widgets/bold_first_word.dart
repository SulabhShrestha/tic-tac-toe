import 'package:flutter/material.dart';

class BoldFirstWord extends StatelessWidget {
  final String boldWord;
  final String remainingWords;
  const BoldFirstWord({
    super.key,
    required this.boldWord,
    required this.remainingWords,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: boldWord,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
        children: [
          TextSpan(
              text: remainingWords,
              style: const TextStyle(fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }
}
