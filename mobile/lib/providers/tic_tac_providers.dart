import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/tic_tac_model.dart';

// Stores all private chat messages
final ticTacProvider =
    StateNotifierProvider.autoDispose<TicTacProvider, List<TicTacModel>>((ref) {
  return TicTacProvider();
});

class TicTacProvider extends StateNotifier<List<TicTacModel>> {
  TicTacProvider() : super([]);

  void addTicTac(TicTacModel model) {
    state = [...state, model];
  }

  void removeAll() {
    state = [];
  }
}
