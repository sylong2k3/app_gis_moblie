import 'package:app_core/domain/repositories/user_notification_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:app_core/shared/utils/usecase.dart';
import 'package:dartz/dartz.dart';

class DeleteAllNotifications implements UseCase<void, NoParams> {
  final UserNotificationRepository repository;

  DeleteAllNotifications(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAllNotifications();
  }
}
