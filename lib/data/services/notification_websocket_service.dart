import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_core/data/datasources/local/auth_local_datasource.dart';
import 'package:app_core/shared/utils/logger.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class NotificationWebSocketService {
  static const String _wsUrl = 'ws://103.163.119.247:8881/ws';

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  final AuthLocalDatasource _authLocalDatasource;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  NotificationWebSocketService(this._authLocalDatasource);

  /// Stream of incoming WebSocket messages
  Stream<Map<String, dynamic>> get messages {
    _messageController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _messageController!.stream;
  }

  /// Check if WebSocket is connected
  bool get isConnected => _channel != null;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnecting || isConnected) {
      AppLogger.info('WebSocket already connecting or connected');
      return;
    }

    _isConnecting = true;
    _shouldReconnect = true;

    try {
      // Get access token
      final token = await _authLocalDatasource.getAccessToken();

      if (token == null || token.isEmpty) {
        AppLogger.warning('No access token available for WebSocket connection');
        _isConnecting = false;
        return;
      }

      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.info('🔌 Connecting to WebSocket...');
      AppLogger.info('URL: $_wsUrl');
      AppLogger.info('Token: ${token.substring(0, 20)}...');
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Create WebSocket with Authorization header
      final socket = await WebSocket.connect(
        _wsUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      AppLogger.info('✅ WebSocket socket created');

      // Wrap in IOWebSocketChannel
      _channel = IOWebSocketChannel(socket);

      AppLogger.info('✅ WebSocket channel wrapped');

      // Initialize message controller if needed
      _messageController ??= StreamController<Map<String, dynamic>>.broadcast();

      // Listen to WebSocket messages
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _reconnectAttempts = 0;
      _isConnecting = false;

      AppLogger.info('✅ WebSocket connected successfully');
    } catch (e) {
      AppLogger.error('❌ WebSocket connection error: $e');
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  /// Handle incoming WebSocket messages
  void _onMessage(dynamic message) {
    try {
      // Log raw message first
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.info('📨 RAW WebSocket Message:');
      AppLogger.info('Type: ${message.runtimeType}');
      AppLogger.info('Content: $message');
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final messageString = _normalizeMessageToString(message);
      if (messageString == null || messageString.isEmpty) {
        AppLogger.warning('⚠️ Empty/unsupported WebSocket message payload');
        return;
      }

      final decoded = jsonDecode(messageString);
      if (decoded is! Map<String, dynamic>) {
        AppLogger.warning('⚠️ WebSocket message is not a JSON object');
        AppLogger.warning('Payload: $decoded');
        return;
      }

      final data = decoded;

      AppLogger.info('📦 PARSED WebSocket Data:');
      AppLogger.info('Full JSON: ${jsonEncode(data)}');
      AppLogger.info('Event: ${data['event']}');
      AppLogger.info('Data: ${data['data']}');
      AppLogger.info('Timestamp: ${data['timestamp']}');
      AppLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Handle different event types
      final event = _normalizeEvent(data['event']);

      switch (event) {
        case 'connected':
          AppLogger.info('✅ WebSocket CONNECTED event');
          AppLogger.info('User ID: ${data['data']?['userId']}');
          AppLogger.info('Message: ${data['data']?['message']}');
          break;
        case 'notification_read':
        case 'notification:read':
          AppLogger.info('👁️ NOTIFICATION READ event');
          AppLogger.info('Read data: ${data['data']}');
          _messageController?.add(data);
          break;
        case 'notification_deleted':
        case 'notification:deleted':
          AppLogger.info('🗑️ NOTIFICATION DELETED event');
          AppLogger.info('Delete data: ${data['data']}');
          _messageController?.add(data);
          break;
        default:
          if (_isIncomingNotificationEvent(event)) {
            AppLogger.info('🔔 NEW NOTIFICATION event');
            AppLogger.info('Notification ID: ${data['data']?['id']}');
            AppLogger.info('Type: ${data['data']?['type']}');
            AppLogger.info('Title: ${data['data']?['title']}');
            AppLogger.info('Message: ${data['data']?['message']}');
            AppLogger.info('Is Read: ${data['data']?['is_read']}');
            AppLogger.info('Created At: ${data['data']?['created_at']}');
            AppLogger.info(
              'Full notification data: ${jsonEncode(data['data'])}',
            );
          } else {
            AppLogger.info('❓ UNKNOWN event: $event');
            AppLogger.info('Unknown data: ${data['data']}');
          }
          _messageController?.add(data);
      }
    } catch (e, stackTrace) {
      AppLogger.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      AppLogger.error('❌ ERROR parsing WebSocket message');
      AppLogger.error('Error: $e');
      AppLogger.error('Stack trace: $stackTrace');
      AppLogger.error('Raw message: $message');
      AppLogger.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  String? _normalizeMessageToString(dynamic message) {
    if (message is String) {
      return message;
    }

    if (message is List<int>) {
      return utf8.decode(message);
    }

    return message?.toString();
  }

  String? _normalizeEvent(dynamic event) {
    if (event == null) return null;
    return event.toString().trim().toLowerCase();
  }

  bool _isIncomingNotificationEvent(String? event) {
    if (event == null || event.isEmpty) {
      return false;
    }

    if (event == 'notification' || event == 'notification:new') {
      return true;
    }

    return event.startsWith('notification:') &&
        event != 'notification:read' &&
        event != 'notification:deleted';
  }

  /// Handle WebSocket errors
  void _onError(dynamic error) {
    AppLogger.error('❌ WebSocket error: $error');
    _scheduleReconnect();
  }

  /// Handle WebSocket connection closed
  void _onDone() {
    AppLogger.warning('⚠️ WebSocket connection closed');
    _channel = null;

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.warning('Max reconnect attempts reached or reconnect disabled');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    AppLogger.info(
      'Scheduling WebSocket reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts in ${_reconnectDelay.inSeconds}s',
    );

    _reconnectTimer = Timer(_reconnectDelay, () {
      AppLogger.info('Attempting to reconnect WebSocket...');
      connect();
    });
  }

  /// Send message to WebSocket server
  void send(Map<String, dynamic> message) {
    if (!isConnected) {
      AppLogger.warning('Cannot send message: WebSocket not connected');
      return;
    }

    try {
      final jsonMessage = jsonEncode(message);
      _channel?.sink.add(jsonMessage);
      AppLogger.info('📤 WebSocket message sent: ${message['event']}');
    } catch (e) {
      AppLogger.error('Error sending WebSocket message: $e');
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    AppLogger.info('Disconnecting WebSocket...');

    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _channel?.sink.close(status.goingAway);
    _channel = null;

    AppLogger.info('✅ WebSocket disconnected');
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnect();
    await _messageController?.close();
    _messageController = null;
  }

  /// Reset reconnect attempts (useful after successful reconnection)
  void resetReconnectAttempts() {
    _reconnectAttempts = 0;
  }
}
