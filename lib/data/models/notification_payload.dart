import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPayload {
  final String title;
  final String body;
  final Map<String, dynamic> data;

  NotificationPayload({
    required this.title,
    required this.body,
    required this.data,
  });

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    return NotificationPayload(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: message.data,
    );
  }
}
