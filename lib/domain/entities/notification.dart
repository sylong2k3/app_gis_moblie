import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    message,
    type,
    data,
    isRead,
    createdAt,
  ];
}

class NotificationListResponse extends Equatable {
  final List<Notification> notifications;
  final int total;
  final int unreadCount;
  final int page;
  final int limit;
  final int totalPages;

  const NotificationListResponse({
    required this.notifications,
    required this.total,
    required this.unreadCount,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [
    notifications,
    total,
    unreadCount,
    page,
    limit,
    totalPages,
  ];
}
