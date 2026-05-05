import 'package:app_core/domain/entities/notification.dart';
import 'package:app_core/domain/repositories/user_notification_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:app_core/shared/utils/usecase.dart';
import 'package:dartz/dartz.dart';

class GetNotifications
    implements UseCase<NotificationListResponse, GetNotificationsParams> {
  final UserNotificationRepository repository;

  GetNotifications(this.repository);

  @override
  Future<Either<Failure, NotificationListResponse>> call(
    GetNotificationsParams params,
  ) async {
    return await repository.getNotifications(
      page: params.page,
      limit: params.limit,
      unreadOnly: params.unreadOnly,
    );
  }
}

class GetNotificationsParams {
  final int page;
  final int limit;
  final bool unreadOnly;

  GetNotificationsParams({
    required this.page,
    required this.limit,
    required this.unreadOnly,
  });
}
