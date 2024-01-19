import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores if the user is waiting for other people to join
final waitingForConnectionProvider = StateProvider<bool>((ref) => false);
