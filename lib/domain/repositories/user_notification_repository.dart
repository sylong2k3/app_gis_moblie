import 'package:app_core/domain/entities/notification.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:dartz/dartz.dart';

abstract class UserNotificationRepository {
  Future<Either<Failure, NotificationListResponse>> getNotifications({
    required int page,
    required int limit,
    required bool unreadOnly,
  });

  Future<Either<Failure, void>> markAsRead(int notificationId);

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, void>> deleteNotification(int notificationId);

  Future<Either<Failure, void>> deleteAllNotifications();
}
