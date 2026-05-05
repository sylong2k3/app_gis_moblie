import 'package:app_core/data/datasources/remote/firebase_notification_datasource.dart';
import 'package:app_core/data/models/notification_payload.dart';
import 'package:app_core/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseNotificationDatasource datasource;

  NotificationRepositoryImpl(this.datasource);

  @override
  Future<String?> getFcmToken() {
    return datasource.getToken();
  }

  @override
  Stream<NotificationPayload> onNotificationReceived() {
    return datasource.onMessage().map(
      (message) => NotificationPayload.fromRemoteMessage(message),
    );
  }
}
