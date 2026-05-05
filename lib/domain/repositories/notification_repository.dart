import 'package:app_core/data/models/notification_payload.dart';

abstract class NotificationRepository {
  Future<String?> getFcmToken();
  Stream<NotificationPayload> onNotificationReceived();
}
