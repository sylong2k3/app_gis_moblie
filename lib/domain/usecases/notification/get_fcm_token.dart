import 'package:app_core/domain/repositories/notification_repository.dart';

class GetFcmToken {
  final NotificationRepository repository;

  GetFcmToken(this.repository);

  Future<String?> call() {
    return repository.getFcmToken();
  }
}
