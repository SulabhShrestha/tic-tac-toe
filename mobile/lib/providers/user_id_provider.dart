import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores whose turn it is
final userIdProvider = Provider<String>((ref) {
  return generateRandomString();
});

// generate random string
String generateRandomString() {
  String characters =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~!@#%^&*()+=[]{}<>?";
  String result = "";

  for (int i = 0; i < 16; i++) {
    result += characters[Random().nextInt(characters.length)];
  }

  return result;
}
