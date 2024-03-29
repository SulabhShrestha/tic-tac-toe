// Stores all private chat messages

import 'package:flutter_riverpod/flutter_riverpod.dart';

final allPlayersProvider =
    StateNotifierProvider<AllPlayersProvider, Map<String, dynamic>>((ref) {
  return AllPlayersProvider();
});

class AllPlayersProvider extends StateNotifier<Map<String, dynamic>> {
  AllPlayersProvider() : super({});

  void addPlayers(Map<String, dynamic> allPlayers) {
    state = allPlayers;
  }

  void empty() {
    state = {};
  }
}
