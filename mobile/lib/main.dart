import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/views/game_page/game_page.dart';

import 'views/homepage/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));

  generateRandomString(); // generate random uid and stores in cache
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("Uid: ${ref.watch(userIdProvider)}");
    debugPrint("Uid: ${ref.watch(userIdProvider)}");

    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: "/",
        routes: {
          "/game": (context) => const GamePage(),
          "/": (context) => const HomePage(),
        });
  }
}
