import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/utils/tic_tac_utils.dart';

/// Stores whose game conclusion
final gameConclusionProvider = StateProvider<Map<String, dynamic>>((ref) => {});
