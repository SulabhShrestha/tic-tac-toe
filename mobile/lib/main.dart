import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/views/bot_game_page/bot_game_page.dart';
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
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.deepPurple,
          ),
        ),
      ),
      initialRoute: "/",
      onGenerateRoute: generateRoute,
    );
  }

  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );

      case '/game':
        return MaterialPageRoute(
          builder: (_) => GamePage(
              players: (settings.arguments as Map<String, dynamic>)["players"]
                  as Map<String, dynamic>),
        );

      case "/bot-game":
        return MaterialPageRoute(builder: (_) => const BotGamePage());
      default:
        // Handle unknown routes
        return null;
    }
  }
}
