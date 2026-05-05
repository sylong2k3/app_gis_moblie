import 'package:app_core/data/models/notification_model.dart';
import 'package:app_core/shared/constants/api_endpoints.dart';
import 'package:dio/dio.dart';

abstract class UserNotificationRemoteDatasource {
  Future<NotificationListResponseModel> getNotifications({
    required int page,
    required int limit,
    required bool unreadOnly,
  });

  Future<void> markAsRead(int notificationId);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(int notificationId);

  Future<void> deleteAllNotifications();
}

class UserNotificationRemoteDatasourceImpl
    implements UserNotificationRemoteDatasource {
  final Dio dio;

  UserNotificationRemoteDatasourceImpl(this.dio);

  @override
  Future<NotificationListResponseModel> getNotifications({
    required int page,
    required int limit,
    required bool unreadOnly,
  }) async {
    final response = await dio.get(
      '${ApiEndpoints.notifications}/me',
      queryParameters: {
        'page': page,
        'limit': limit,
        'unread_only': unreadOnly,
      },
    );

    return NotificationListResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await dio.patch('${ApiEndpoints.notifications}/$notificationId/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await dio.patch('${ApiEndpoints.notifications}/read-all');
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    await dio.delete('${ApiEndpoints.notifications}/$notificationId');
  }

  @override
  Future<void> deleteAllNotifications() async {
    await dio.delete(ApiEndpoints.notifications);
  }
}
