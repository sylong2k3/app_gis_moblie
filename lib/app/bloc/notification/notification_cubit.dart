import 'dart:async';
import 'package:app_core/app/notification/notification_service.dart';
import 'package:app_core/data/services/notification_websocket_service.dart';
import 'package:app_core/domain/entities/notification.dart';
import 'package:app_core/domain/usecases/notification/get_notifications.dart';
import 'package:app_core/domain/usecases/notification/mark_notification_as_read.dart';
import 'package:app_core/domain/usecases/notification/mark_all_notifications_as_read.dart';
import 'package:app_core/domain/usecases/notification/delete_notification.dart';
import 'package:app_core/domain/usecases/notification/delete_all_notifications.dart';
import 'package:app_core/shared/utils/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotifications getNotifications;
  final MarkNotificationAsRead markNotificationAsRead;
  final MarkAllNotificationsAsRead markAllNotificationsAsRead;
  final DeleteNotification deleteNotification;
  final DeleteAllNotifications deleteAllNotifications;
  final NotificationWebSocketService? webSocketService;
  final NotificationService? notificationService;

  StreamSubscription<Map<String, dynamic>>? _wsSubscription;
  final Set<int> _shownNotificationIds = <int>{};
  bool _isLoadingMore = false;

  NotificationCubit({
    required this.getNotifications,
    required this.markNotificationAsRead,
    required this.markAllNotificationsAsRead,
    required this.deleteNotification,
    required this.deleteAllNotifications,
    this.webSocketService,
    this.notificationService,
  }) : super(NotificationInitial()) {
    _initWebSocket();
  }

  Future<void> loadNotifications({
    int page = 1,
    int limit = 10,
    bool unreadOnly = false,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      emit(NotificationLoading());
    }

    final result = await getNotifications(
      GetNotificationsParams(page: page, limit: limit, unreadOnly: unreadOnly),
    );

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (response) => emit(NotificationLoaded(response)),
    );
  }

  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadMoreNotifications() async {
    final currentState = state;
    if (currentState is! NotificationLoaded || _isLoadingMore) return;

    final currentPage = currentState.response.page;
    final totalPages = currentState.response.totalPages;

    if (currentPage >= totalPages) {
      return;
    }

    _isLoadingMore = true;

    final nextPage = currentPage + 1;
    final result = await getNotifications(
      GetNotificationsParams(
        page: nextPage,
        limit: currentState.response.limit,
        unreadOnly: false,
      ),
    );

    result.fold((_) {}, (response) {
      final existing = currentState.response.notifications;
      final combined = [...existing, ...response.notifications];
      final seenIds = <int>{};
      final deduped = <Notification>[];

      for (final notification in combined) {
        if (seenIds.add(notification.id)) {
          deduped.add(notification);
        }
      }

      emit(
        NotificationLoaded(
          NotificationListResponse(
            notifications: deduped,
            total: response.total,
            unreadCount: response.unreadCount,
            page: response.page,
            limit: response.limit,
            totalPages: response.totalPages,
          ),
        ),
      );
    });

    _isLoadingMore = false;
  }

  Future<void> markAsRead(int notificationId) async {
    final result = await markNotificationAsRead(notificationId);

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      // Reload notifications after marking as read
      loadNotifications();
    });
  }

  Future<void> markAllAsRead() async {
    final result = await markAllNotificationsAsRead(NoParams());

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      // Reload notifications after marking all as read
      loadNotifications();
    });
  }

  Future<void> deleteNotificationById(int notificationId) async {
    final result = await deleteNotification(notificationId);

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      // Reload notifications after deleting
      loadNotifications();
    });
  }

  Future<void> deleteAll() async {
    final result = await deleteAllNotifications(NoParams());

    result.fold((failure) => emit(NotificationError(failure.message)), (_) {
      // Reload notifications after deleting all
      loadNotifications();
    });
  }

  /// Initialize WebSocket connection
  void _initWebSocket() {
    if (webSocketService == null) return;

    // Connect to WebSocket
    webSocketService!.connect();

    // Listen to WebSocket messages
    _wsSubscription = webSocketService!.messages.listen(
      (message) {
        final event = _normalizeEvent(message['event']);
        final latestNotification = _extractLatestNotification(message);
        final notificationData = latestNotification ?? _extractDataMap(message);
        final hasNotificationListPayload = latestNotification != null;
        final isIncomingNotificationEvent =
            hasNotificationListPayload ||
            _isIncomingNotificationEvent(
              event,
              notificationData: notificationData,
            );
        final isMutationEvent = _isNotificationMutationEvent(event);

        // Reload notifications when receiving real-time updates
        if (!isIncomingNotificationEvent && !isMutationEvent) {
          return;
        }

        if (isIncomingNotificationEvent && notificationData != null) {
          _showNotificationIfNeeded(notificationData);
          _applyRealtimeNotificationToState(notificationData);
        }

        loadNotifications(showLoading: false);
      },
      onError: (error) {
        // Handle WebSocket errors silently
      },
    );
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    webSocketService?.disconnect();
    return super.close();
  }

  Map<String, dynamic>? _extractLatestNotification(
    Map<String, dynamic> message,
  ) {
    final data = message['data'];
    if (data is! Map) return null;

    final dataMap = Map<String, dynamic>.from(data);
    final notifications = dataMap['notifications'];
    if (notifications is! List || notifications.isEmpty) return null;

    final first = notifications.first;
    if (first is Map<String, dynamic>) return first;
    if (first is Map) return Map<String, dynamic>.from(first);
    return null;
  }

  Map<String, dynamic>? _extractDataMap(Map<String, dynamic> message) {
    final data = message['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  String? _normalizeEvent(dynamic value) {
    if (value == null) return null;
    return value.toString().trim().toLowerCase();
  }

  bool _isIncomingNotificationEvent(
    String? event, {
    Map<String, dynamic>? notificationData,
  }) {
    if (event == 'notification' || event == 'notification:new') {
      return true;
    }

    if (event != null &&
        event.startsWith('notification:') &&
        !_isNotificationMutationEvent(event)) {
      return true;
    }

    return _looksLikeNotificationPayload(notificationData);
  }

  bool _isNotificationMutationEvent(String? event) {
    return event == 'notification_read' ||
        event == 'notification:read' ||
        event == 'notification_deleted' ||
        event == 'notification:deleted';
  }

  bool _looksLikeNotificationPayload(Map<String, dynamic>? notificationData) {
    if (notificationData == null) return false;

    final id = _parseNotificationId(notificationData['id']);
    final title = (notificationData['title'] ?? '').toString().trim();
    final message = (notificationData['message'] ?? '').toString().trim();

    return id != null && (title.isNotEmpty || message.isNotEmpty);
  }

  int? _parseNotificationId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  void _showNotificationIfNeeded(Map<String, dynamic> mapData) {
    final id = _parseNotificationId(mapData['id']);
    if (id != null && _shownNotificationIds.contains(id)) {
      return;
    }

    final title = (mapData['title'] ?? '').toString();
    final body = (mapData['message'] ?? '').toString();

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    notificationService?.showLocalNotification(
      title: title,
      body: body,
      payload: mapData,
    );

    if (id != null) {
      _shownNotificationIds.add(id);
      if (_shownNotificationIds.length > 100) {
        _shownNotificationIds.remove(_shownNotificationIds.first);
      }
    }
  }

  void _applyRealtimeNotificationToState(Map<String, dynamic> mapData) {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    final notification = _mapToNotification(mapData);
    if (notification == null) return;

    final alreadyExists = currentState.response.notifications.any(
      (item) => item.id == notification.id,
    );
    if (alreadyExists) return;

    final updatedNotifications = [
      notification,
      ...currentState.response.notifications,
    ];

    emit(
      NotificationLoaded(
        NotificationListResponse(
          notifications: updatedNotifications,
          total: currentState.response.total + 1,
          unreadCount: notification.isRead
              ? currentState.response.unreadCount
              : currentState.response.unreadCount + 1,
          page: currentState.response.page,
          limit: currentState.response.limit,
          totalPages: currentState.response.totalPages,
        ),
      ),
    );
  }

  Notification? _mapToNotification(Map<String, dynamic> mapData) {
    final id = _parseNotificationId(mapData['id']);
    final userId = _parseNotificationId(mapData['user_id']);
    final title = (mapData['title'] ?? '').toString();
    final message = (mapData['message'] ?? '').toString();
    final type = (mapData['type'] ?? '').toString();

    if (id == null || userId == null || title.isEmpty) {
      return null;
    }

    final rawData = mapData['data'];
    final rawPayload = mapData['payload'];
    Map<String, dynamic>? data;

    if (rawData is Map<String, dynamic>) {
      data = rawData;
    } else if (rawData is Map) {
      data = Map<String, dynamic>.from(rawData);
    } else if (rawPayload is Map<String, dynamic>) {
      data = rawPayload;
    } else if (rawPayload is Map) {
      data = Map<String, dynamic>.from(rawPayload);
    }

    return Notification(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      data: data,
      isRead: _parseBool(mapData['is_read']),
      createdAt: _parseDateTime(mapData['created_at']),
    );
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
