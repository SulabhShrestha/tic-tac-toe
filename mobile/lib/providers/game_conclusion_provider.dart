import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores whose game conclusion
final gameConclusionProvider =
    StateProvider.autoDispose<Map<String, dynamic>>((ref) => {});
