import 'package:app_core/data/models/notification_payload.dart';
import 'package:app_core/domain/repositories/notification_repository.dart';

class ListenNotification {
  final NotificationRepository repository;

  ListenNotification(this.repository);

  Stream<NotificationPayload> call() {
    return repository.onNotificationReceived();
  }
}
