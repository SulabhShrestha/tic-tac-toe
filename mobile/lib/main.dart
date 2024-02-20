import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/user_id_provider.dart';
import 'package:mobile/services/socket_web_services.dart';
import 'package:mobile/views/bloc/user_id_cubit/user_id_cubit.dart';
import 'package:mobile/views/bot_game_page/bloc/socket_bloc.dart';
import 'package:mobile/views/bot_game_page/bot_game_page.dart';
import 'package:mobile/views/bot_game_page/socket_data_provider/socket_data_provider.dart';
import 'package:mobile/views/game_page/game_page.dart';

import 'views/bot_game_page/bloc/socket_bloc_observer.dart';
import 'views/bot_game_page/repository/socket_repository.dart';
import 'views/homepage/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  Bloc.observer = SocketBlocObserver();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));

  generateRandomString(); // generate random uid and stores in cache
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepositoryProvider<SocketRepository>(
      create: (context) => SocketRepository(
        SocketDataProvider(),
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SocketBloc(context.read<SocketRepository>()),
          ),
          BlocProvider(
              create: (_) => UserIdCubit()..setUserId(generateRandomString())),
        ],
        child: MaterialApp(
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
        ),
      ),
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

String generateRandomString() {
  debugPrint("Random string");
  String characters =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~!@#%^&*()+=[]{}<>?";
  String result = "";

  for (int i = 0; i < 16; i++) {
    result += characters[Random().nextInt(characters.length)];
  }

  return result;
}
