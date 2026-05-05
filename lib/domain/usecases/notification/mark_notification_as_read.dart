import 'package:app_core/domain/repositories/user_notification_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:app_core/shared/utils/usecase.dart';
import 'package:dartz/dartz.dart';

class MarkNotificationAsRead implements UseCase<void, int> {
  final UserNotificationRepository repository;

  MarkNotificationAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(int notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}
