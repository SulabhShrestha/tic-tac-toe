import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/tic_tac_model.dart';

// Stores all private chat messages
final ticTacProvider =
    StateNotifierProvider<TicTacProvider, List<TicTacModel>>((ref) {
  return TicTacProvider();
});

class TicTacProvider extends StateNotifier<List<TicTacModel>> {
  TicTacProvider() : super([]);

  void addTicTac(TicTacModel model) {
    state = [...state, model];
    log("inside private chat notifier: $model");
  }

  void removeAll() {
    state = [];
  }
}
