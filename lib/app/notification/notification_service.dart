import 'dart:convert';

import 'package:app_core/app/notification/notification_handler.dart';
import 'package:app_core/data/datasources/remote/firebase_notification_datasource.dart';
import 'package:app_core/domain/usecases/notification/save_device_token.dart';
import 'package:app_core/firebase_options.dart';
import 'package:app_core/shared/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // ignore - Firebase may already be initialized in some cases
  }

  AppLogger.info(
    'Background message received: ${message.messageId} data=${message.data}',
  );
}

class NotificationService {
  final FirebaseNotificationDatasource firebaseDatasource;
  final FlutterLocalNotificationsPlugin localNotifications;
  final SaveDeviceToken? saveDeviceToken;

  NotificationService({
    required this.firebaseDatasource,
    required this.localNotifications,
    this.saveDeviceToken,
  });

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Used for important notifications.',
        importance: Importance.max,
      );

  bool _initialized = false;
  bool _localNotificationsInitialized = false;

  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _ensureLocalNotificationsInitialized();

    final permission = await firebaseDatasource.requestPermission();
    AppLogger.info('FCM permission status: ${permission.authorizationStatus}');

    await firebaseDatasource.setForegroundPresentationOptions();

    // Token
    final token = await firebaseDatasource.getToken();
    AppLogger.info('FCM token: $token');
    await saveDeviceToken?.call(token);

    firebaseDatasource.onTokenRefresh().listen((newToken) async {
      AppLogger.info('FCM token refreshed: $newToken');
      await saveDeviceToken?.call(newToken);
    });

    // Terminated -> opened by tapping notification
    final initialMessage = await firebaseDatasource.getInitialMessage();
    if (initialMessage != null) {
      NotificationHandler.handleRemoteMessageTap(initialMessage);
    }

    // Background -> opened by tapping notification
    firebaseDatasource.onMessageOpenedApp().listen((message) {
      NotificationHandler.handleRemoteMessageTap(message);
    });

    // Foreground: show local notification so user sees it
    firebaseDatasource.onMessage().listen((message) async {
      await _showForegroundNotification(message);
    });
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        NotificationHandler.handleLocalNotificationTap(response.payload);
      },
    );

    final androidPlugin = localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(_androidChannel);
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_localNotificationsInitialized) return;
    await _initLocalNotifications();
    _localNotificationsInitialized = true;
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      await _ensureLocalNotificationsInitialized();

      final notification = message.notification;
      final title = notification?.title ?? (message.data['title'] as String?);
      final body = notification?.body ?? (message.data['body'] as String?);

      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        // Data-only message with no visible content
        return;
      }

      final androidDetails = AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      final details = NotificationDetails(android: androidDetails);

      await localNotifications.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: details,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      AppLogger.error('Failed to show foreground notification: $e');
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _ensureLocalNotificationsInitialized();

      if (title.isEmpty && body.isEmpty) {
        return;
      }

      final androidDetails = AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      final details = NotificationDetails(android: androidDetails);

      await localNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload == null ? null : jsonEncode(payload),
      );
    } catch (e) {
      AppLogger.error('Failed to show local notification: $e');
    }
  }
}
