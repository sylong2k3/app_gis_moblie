import 'package:app_core/domain/entities/notification.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.message,
    required super.type,
    super.data,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final rawPayload = json['payload'];

    return NotificationModel(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      data: rawData is Map<String, dynamic>
          ? rawData
          : rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : rawPayload is Map<String, dynamic>
          ? rawPayload
          : rawPayload is Map
          ? Map<String, dynamic>.from(rawPayload)
          : null,
      isRead: _asBool(json['is_read']),
      createdAt: _asDateTime(json['created_at']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static DateTime _asDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class NotificationListResponseModel extends NotificationListResponse {
  const NotificationListResponseModel({
    required super.notifications,
    required super.total,
    required super.unreadCount,
    required super.page,
    required super.limit,
    required super.totalPages,
  });

  factory NotificationListResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle case when data is null or empty
    final data = json['data'] as Map<String, dynamic>?;

    if (data == null) {
      return const NotificationListResponseModel(
        notifications: [],
        total: 0,
        unreadCount: 0,
        page: 1,
        limit: 10,
        totalPages: 0,
      );
    }

    final notificationsJson = data['notifications'] as List? ?? [];
    final paginationRaw = data['pagination'];
    final pagination = paginationRaw is Map
        ? Map<String, dynamic>.from(paginationRaw)
        : <String, dynamic>{};

    int readInt(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    return NotificationListResponseModel(
      notifications: notificationsJson
          .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
          .toList(),
      total: readInt(
        pagination['total'] ?? data['total'],
        fallback: notificationsJson.length,
      ),
      unreadCount: readInt(
        data['unread_count'],
        fallback: notificationsJson
            .where(
              (n) =>
                  NotificationModel.fromJson(
                    n as Map<String, dynamic>,
                  ).isRead ==
                  false,
            )
            .length,
      ),
      page: readInt(pagination['page'] ?? data['page'], fallback: 1),
      limit: readInt(pagination['limit'] ?? data['limit'], fallback: 10),
      totalPages: readInt(
        pagination['totalPages'] ??
            pagination['total_pages'] ??
            data['total_pages'],
      ),
    );
  }
}
