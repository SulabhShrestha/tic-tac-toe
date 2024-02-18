// this returns instance of socket web service provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/services/socket_web_services.dart';

final socketWebServiceProvider = Provider<SocketWebServices>((ref) {
  return SocketWebServices()..init();
});
