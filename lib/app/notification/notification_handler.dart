import 'package:app_core/app/navigation/app_router.dart';
import 'package:app_core/app/notification/notification_payload.dart';
import 'package:app_core/shared/utils/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationHandler {
  static void handleRemoteMessageTap(RemoteMessage message) {
    try {
      final route = message.data['route'] as String?;
      AppLogger.info('Notification tapped. route=$route data=${message.data}');

      if (route != null && route.isNotEmpty) {
        appRouter.go(route);
        return;
      }

      // Default route
      appRouter.go('/notifications');
    } catch (e) {
      AppLogger.error('Failed to handle notification tap: $e');
    }
  }

  static void handleLocalNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) {
      appRouter.go('/notifications');
      return;
    }

    try {
      final parsed = AppNotificationPayload.fromJsonString(payload);
      final route = parsed.route;
      AppLogger.info(
        'Local notification tapped. route=$route data=${parsed.data}',
      );

      if (route != null && route.isNotEmpty) {
        appRouter.go(route);
        return;
      }

      appRouter.go('/notifications');
    } catch (e) {
      AppLogger.error('Failed to parse local notification payload: $e');
      appRouter.go('/notifications');
    }
  }
}
