import 'package:mobile/core/service/activity_logger.dart';
import 'package:mobile/core/service/device_info_service.dart';

mixin ActivityLoggerMx {
  void logActivity({
    required ActivityType activityType,
    Map<String, dynamic>? additionalData,
  }) {
    final deviceId = DeviceInfoService().deviceId;
    ActivityLoggerImpl().logActivity(
        activityType: activityType,
        deviceId: deviceId,
        additionalData: additionalData);
  }
}
