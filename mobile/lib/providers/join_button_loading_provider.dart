import 'package:flutter_riverpod/flutter_riverpod.dart';

/// This stores bool value, useful to show loading button when joining through qr code
///

final joinButtonLoadingProvider = StateProvider<bool>((ref) => false);
