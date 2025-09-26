import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  // making this singleton class
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() {
    return _instance;
  }
  DeviceInfoService._internal();

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  String _deviceId = "";

  String get deviceId => _deviceId;

  Future<void> getDeviceFingerprint() async {
    var deviceInfo = await _deviceInfoPlugin.deviceInfo;

    _deviceId = deviceInfo.data["fingerprint"];
  }
}
