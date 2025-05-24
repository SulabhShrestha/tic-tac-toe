import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum ActivityType {
  appOpen,
  cancelCreateGame,
  createGame,
  cancelJoinGame,
  joinGame,
  joinGameViaQR,
  playWithBot,
  gameStart,
}

abstract class ActivityLogger {
  void logActivity({
    required ActivityType activityType,
    required String deviceId,
    Map<String, dynamic>? additionalData,
  });
}

class ActivityLoggerImpl implements ActivityLogger {
  final _loggerEndpoint =
      "${dotenv.env['ANALYTICS_URL']}/api/analytics/tictactoe";

  @override
  void logActivity({
    required ActivityType activityType,
    required String deviceId,
    Map<String, dynamic>? additionalData,
  }) {
    final activityData = {
      'eventType': activityType.name,
      'deviceId': deviceId,
      if (additionalData != null) "metadata": additionalData,
    };

    var data = jsonEncode(activityData);
    log("Logging activity: $data");

    http
        .post(Uri.parse(_loggerEndpoint),
            headers: {
              'Content-Type': 'application/json',
            },
            body: data)
        .then((response) {
      if (response.statusCode == 200) {
        log('Activity logged successfully');
      } else {
        log('Failed to log activity: ${response.statusCode}');
      }
    }).catchError((error) {
      log('Error logging activity: $error');
    });
  }
}
