import 'package:flutter_riverpod/flutter_riverpod.dart';

/// For storing if the any action button is clicked so that, other button is disabled
///
final anyButtonClickedProvider = StateProvider<bool>((ref) => false);
