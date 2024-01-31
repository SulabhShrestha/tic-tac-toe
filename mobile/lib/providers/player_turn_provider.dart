import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores whose turn it is
final playerTurnProvider = StateProvider<String>((ref) => "");
