import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationDatasource {
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  Future<String?> getToken() {
    return _messaging.getToken();
  }

  Stream<String> onTokenRefresh() {
    return _messaging.onTokenRefresh;
  }

  Stream<RemoteMessage> onMessage() {
    return FirebaseMessaging.onMessage;
  }

  Stream<RemoteMessage> onMessageOpenedApp() {
    return FirebaseMessaging.onMessageOpenedApp;
  }

  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  Future<NotificationSettings> requestPermission() async {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> setForegroundPresentationOptions() {
    return _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
