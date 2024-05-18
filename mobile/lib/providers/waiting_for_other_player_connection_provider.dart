import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores if the user is waiting for other people to join
final waitingForOtherPlayerConnectionProvider =
    StateProvider<bool>((ref) => false);
