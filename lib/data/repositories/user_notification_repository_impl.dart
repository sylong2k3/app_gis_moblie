import 'package:app_core/data/datasources/remote/user_notification_remote_datasource.dart';
import 'package:app_core/data/models/notification_model.dart';
import 'package:app_core/domain/entities/notification.dart';
import 'package:app_core/domain/repositories/user_notification_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class UserNotificationRepositoryImpl implements UserNotificationRepository {
  final UserNotificationRemoteDatasource remoteDatasource;

  UserNotificationRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, NotificationListResponse>> getNotifications({
    required int page,
    required int limit,
    required bool unreadOnly,
  }) async {
    try {
      final response = await remoteDatasource.getNotifications(
        page: page,
        limit: limit,
        unreadOnly: unreadOnly,
      );
      return Right(response);
    } on DioException catch (e) {
      // If it's a parsing error or null data, return empty list
      if (e.type == DioExceptionType.unknown &&
          e.message?.contains('null') == true) {
        return const Right(
          NotificationListResponseModel(
            notifications: [],
            total: 0,
            unreadCount: 0,
            page: 1,
            limit: 10,
            totalPages: 0,
          ),
        );
      }

      return Left(
        ServerFailure(
          message:
              e.response?.data['message'] ?? 'Failed to load notifications',
        ),
      );
    } on TypeError catch (e) {
      // Handle null casting errors - return empty list
      if (e.toString().contains('null')) {
        return const Right(
          NotificationListResponseModel(
            notifications: [],
            total: 0,
            unreadCount: 0,
            page: 1,
            limit: 10,
            totalPages: 0,
          ),
        );
      }
      return Left(ApplicationFailure(message: 'Lỗi xử lý dữ liệu: $e'));
    } catch (e) {
      // For any unexpected error with null, return empty list
      if (e.toString().contains('null')) {
        return const Right(
          NotificationListResponseModel(
            notifications: [],
            total: 0,
            unreadCount: 0,
            page: 1,
            limit: 10,
            totalPages: 0,
          ),
        );
      }
      return Left(ApplicationFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int notificationId) async {
    try {
      await remoteDatasource.markAsRead(notificationId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data['message'] ?? 'Failed to mark as read',
        ),
      );
    } catch (e) {
      return Left(ApplicationFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDatasource.markAllAsRead();
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data['message'] ?? 'Failed to mark all as read',
        ),
      );
    } catch (e) {
      return Left(ApplicationFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(int notificationId) async {
    try {
      await remoteDatasource.deleteNotification(notificationId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message:
              e.response?.data['message'] ?? 'Failed to delete notification',
        ),
      );
    } catch (e) {
      return Left(ApplicationFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications() async {
    try {
      await remoteDatasource.deleteAllNotifications();
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message:
              e.response?.data['message'] ??
              'Failed to delete all notifications',
        ),
      );
    } catch (e) {
      return Left(ApplicationFailure(message: 'Unexpected error: $e'));
    }
  }
}
