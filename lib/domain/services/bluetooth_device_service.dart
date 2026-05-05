import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:app_core/shared/utils/logger.dart';

/// Service để giao tiếp với thiết bị IoT qua Bluetooth
class BluetoothDeviceService {
  static const String serviceUUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const String characteristicUUID =
      "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  static const String serviceName = "AQUA_FARM_SERVICE";

  BluetoothCharacteristic? _characteristic;
  BluetoothDevice? _currentDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  bool isConnected() {
    if (_characteristic == null || _currentDevice == null) return false;
    return _currentDevice!.isConnected;
  }

  /// Quét thiết bị BLE với service UUID
  Future<List<BluetoothDevice>> scanDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      AppLogger.warning('Bluetooth is not enabled');
      return [];
    }

    Set<BluetoothDevice> devices = {};
    Completer<List<BluetoothDevice>> completer = Completer();

    await FlutterBluePlus.stopScan();

    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 30),
      withServices: [Guid(serviceUUID)],
    );

    StreamSubscription<List<ScanResult>>? subscription;
    subscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        AppLogger.info('Found device: ${r.device.advName}');
        devices.add(r.device);
      }
    });

    Future.delayed(timeout, () async {
      if (!completer.isCompleted) {
        await FlutterBluePlus.stopScan();
        completer.complete(devices.toList());
        await subscription?.cancel();
      }
    });

    return completer.future;
  }

  /// Force cleanup toàn bộ BLE state
  Future<void> _forceCleanup() async {
    AppLogger.info('🧹 Force cleanup BLE state...');

    // Cancel connection subscription
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    // Disconnect current device
    if (_currentDevice != null) {
      try {
        if (_characteristic != null) {
          await _characteristic!.setNotifyValue(false);
        }
        await _currentDevice!.disconnect();
        AppLogger.info('Disconnected current device');
      } catch (e) {
        AppLogger.error('Error disconnecting current device: $e');
      }
    }

    // Disconnect ALL connected devices
    List<BluetoothDevice> connectedDevices = FlutterBluePlus.connectedDevices;
    for (BluetoothDevice d in connectedDevices) {
      try {
        await d.disconnect();
        AppLogger.info('Force disconnected: ${d.advName}');
      } catch (e) {
        AppLogger.error('Error force disconnecting: $e');
      }
    }

    _characteristic = null;
    _currentDevice = null;

    // Wait for BLE stack to settle
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  /// Kết nối đến thiết bị Bluetooth với error 133 handling
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      AppLogger.error('Bluetooth is not enabled');
      return false;
    }

    // Force cleanup trước khi connect
    await _forceCleanup();

    const maxRetries = 5; // Tăng số lần retry

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        AppLogger.info('🔌 Connecting (attempt ${attempt + 1}/$maxRetries)');

        // Bonded devices có thể gây vấn đề, clear cache nếu cần
        // Note: Không có API official để clear cache, phải làm manual trên Android

        // Connect với timeout dài hơn
        await device.connect(
          timeout: const Duration(seconds: 20),
          mtu: null,
          license: License.values.first,
        );

        AppLogger.info('✅ Connected, waiting for stabilization...');

        // Đợi kết nối ổn định - QUAN TRỌNG để tránh lỗi 133
        await Future.delayed(const Duration(milliseconds: 2000));

        // Check connection state
        if (!device.isConnected) {
          AppLogger.warning('Device not connected after connect call');
          throw Exception('Device not connected');
        }

        // Setup connection monitoring
        _connectionSubscription = device.connectionState.listen((state) {
          AppLogger.info('Connection state changed: $state');
          if (state == BluetoothConnectionState.disconnected) {
            AppLogger.warning('Device disconnected unexpectedly');
            _characteristic = null;
            _currentDevice = null;
          }
        });

        AppLogger.info('🔍 Discovering services...');
        List<BluetoothService> services = await device.discoverServices();

        // Đợi thêm sau discover services
        await Future.delayed(const Duration(milliseconds: 500));

        bool foundCharacteristic = false;
        for (var s in services) {
          AppLogger.info('Found service: ${s.uuid}');
          if (s.uuid.toString() == serviceUUID) {
            for (var c in s.characteristics) {
              AppLogger.info('Found characteristic: ${c.uuid}');
              if (c.uuid.toString() == characteristicUUID) {
                _characteristic = c;
                _currentDevice = device;

                // Enable notifications
                await _characteristic!.setNotifyValue(true);
                await Future.delayed(const Duration(milliseconds: 300));

                foundCharacteristic = true;
                AppLogger.info('✅ Connected successfully!');
                return true;
              }
            }
          }
        }

        if (!foundCharacteristic) {
          AppLogger.warning('⚠️ Characteristic not found');
          await device.disconnect();
          await Future.delayed(const Duration(milliseconds: 500));
          _characteristic = null;
          _currentDevice = null;
        }

        return false;
      } catch (e) {
        AppLogger.error('❌ Connection attempt ${attempt + 1} failed: $e');

        // Cleanup sau lỗi
        try {
          await device.disconnect();
        } catch (_) {}

        _characteristic = null;
        _currentDevice = null;
        await _connectionSubscription?.cancel();
        _connectionSubscription = null;

        // Đặc biệt xử lý lỗi 133
        if (e.toString().contains('133') || e.toString().contains('GATT')) {
          // Wait longer for error 133
          final waitTime = Duration(
            seconds: 3 * (attempt + 1),
          ); // 3s, 6s, 9s, 12s, 15s
          AppLogger.info(
            '⏳ Error 133 detected, waiting ${waitTime.inSeconds}s...',
          );
          await Future.delayed(waitTime);

          // Force cleanup BLE stack
          if (attempt == 1) {
            // Cleanup aggressive ở attempt thứ 2
            AppLogger.info('🔄 Aggressive cleanup...');
            await _forceCleanup();
          }
        } else {
          // Lỗi khác, wait ngắn hơn
          if (attempt < maxRetries - 1) {
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }
    }

    AppLogger.error('💀 Failed to connect after $maxRetries attempts');
    return false;
  }

  /// Gửi configuration với connection check
  Future<bool> _sendConfig(Map<String, dynamic> config) async {
    if (!isConnected()) {
      AppLogger.error('Device is not connected');
      return false;
    }

    // Double check connection state
    if (_currentDevice != null && !_currentDevice!.isConnected) {
      AppLogger.error('Device disconnected before write');
      _characteristic = null;
      _currentDevice = null;
      return false;
    }

    try {
      final jsonStr = jsonEncode(config);
      final dataBytes = utf8.encode(jsonStr);
      const maxChunkSize = 256;

      AppLogger.info('Sending config: ${dataBytes.length} bytes');

      // Gửi theo chunk để tránh data quá lớn
      for (int i = 0; i < dataBytes.length; i += maxChunkSize) {
        if (!isConnected()) {
          AppLogger.error('Lost connection during send');
          return false;
        }

        final end = (i + maxChunkSize < dataBytes.length)
            ? i + maxChunkSize
            : dataBytes.length;
        final chunk = dataBytes.sublist(i, end);

        await _characteristic!.write(chunk, allowLongWrite: true);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      AppLogger.info('Configuration sent successfully');
      return true;
    } catch (e) {
      AppLogger.error('Failed to send configuration: $e');

      // Check connection after error
      if (_currentDevice != null && !_currentDevice!.isConnected) {
        _characteristic = null;
        _currentDevice = null;
      }

      return false;
    }
  }

  /// Gửi cấu hình WiFi với credentials (mqttServer, cert, privateKey) và đợi response từ ESP
  Future<String?> sendWifiAndCredentials({
    required String ssid,
    required String password,
    required String mqttServer,
    required String thingName,
    required String deviceCert,
    required String privateKey,
    Duration timeout = const Duration(seconds: 30),
    int retries = 3,
  }) async {
    if (!isConnected()) {
      AppLogger.error('Device is not connected');
      return null;
    }

    for (int i = 0; i < retries; i++) {
      if (!isConnected()) {
        AppLogger.error('Lost connection, cannot send WiFi');
        return null;
      }

      final completer = Completer<String?>();
      StreamSubscription<List<int>>? sub;

      try {
        // Subscribe to notifications
        sub = _characteristic!.onValueReceived.listen((event) {
          try {
            final response = utf8.decode(event).trim();

            AppLogger.info('📩 Response: $response');

            if (response.isEmpty) {
              AppLogger.warning('⚠️ Empty response');
              return;
            }

            // Xử lý các response từ thiết bị
            if (response == 'wifi_connected') {
              AppLogger.info('🎉 WiFi connected successfully!');
              if (!completer.isCompleted) {
                completer.complete('SUCCESS');
                sub?.cancel();
              }
            } else if (response == 'wifi_failed') {
              AppLogger.warning('❌ WiFi connection failed!');
              if (!completer.isCompleted) {
                completer.complete(null);
                sub?.cancel();
              }
            } else if (response == 'error_too_large') {
              AppLogger.error('❌ Data too large error!');
              if (!completer.isCompleted) {
                completer.complete(null);
                sub?.cancel();
              }
            } else {
              AppLogger.info('ℹ️ Other response: $response');
            }
          } catch (e) {
            AppLogger.error('❌ Listener error: $e');
          }
        });

        // Send WiFi credentials and MQTT config
        final config = {
          "ssid": ssid,
          "password": password,
          "thingName": thingName,
          "mqttServer": mqttServer,
          "deviceCert": deviceCert,
          "privateKey": privateKey,
        };
        final sent = await _sendConfig(config);
        if (!sent) {
          AppLogger.warning('Retry ${i + 1}/$retries - send failed');
          await sub.cancel();
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }

        AppLogger.info('⏳ Waiting for response...');

        final result = await completer.future.timeout(
          timeout,
          onTimeout: () {
            AppLogger.warning('⏰ Timeout waiting for ESP response');
            return null;
          },
        );

        return result;
      } finally {
        await sub?.cancel();
      }
    }

    AppLogger.error('💀 Failed after $retries attempts');
    return null;
  }

  /// Khởi động lại thiết bị
  /// Response: "restarting"
  Future<bool> restartDevice({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!isConnected()) {
      AppLogger.error('Device is not connected');
      return false;
    }

    try {
      final restartCommand = {"restart": true};
      await _characteristic!.write(utf8.encode(jsonEncode(restartCommand)));
      AppLogger.info('Restart command sent');

      final completer = Completer<bool>();
      StreamSubscription<List<int>>? sub;

      sub = _characteristic!.onValueReceived.listen((event) {
        try {
          final response = utf8.decode(event).trim();
          AppLogger.info('Restart response: $response');

          if (response == 'restarting') {
            AppLogger.info('✅ Device is restarting');
            if (!completer.isCompleted) {
              completer.complete(true);
              sub?.cancel();
            }
          }
        } catch (e) {
          AppLogger.error('Parse restart response error: $e');
        }
      });

      return await completer.future.timeout(
        timeout,
        onTimeout: () {
          AppLogger.warning('⏰ Timeout waiting for restart response');
          sub?.cancel();
          return false;
        },
      );
    } catch (e) {
      AppLogger.error('Restart error: $e');
      return false;
    }
  }

  /// Gửi cấu hình thiết bị
  /// Response: "mqtt_registered"
  Future<bool> sendDeviceConfig({
    required Map<String, String> config,
    Duration timeout = const Duration(seconds: 60),
    int retries = 3,
  }) async {
    if (!isConnected()) {
      AppLogger.error('Device is not connected');
      return false;
    }

    try {
      final jsonStr = jsonEncode(config);
      final dataBytes = utf8.encode(jsonStr);
      const maxChunkSize = 256;
      AppLogger.info('Config size: ${dataBytes.length} bytes');

      for (int attempt = 0; attempt < retries; attempt++) {
        if (!isConnected()) {
          AppLogger.error('Lost connection during config send');
          return false;
        }

        bool sendSuccess = true;

        for (int i = 0; i < dataBytes.length; i += maxChunkSize) {
          if (!isConnected()) {
            AppLogger.warning('Lost connection at chunk $i');
            sendSuccess = false;
            break;
          }

          final end = (i + maxChunkSize < dataBytes.length)
              ? i + maxChunkSize
              : dataBytes.length;
          final chunk = dataBytes.sublist(i, end);

          try {
            await _characteristic!.write(chunk, allowLongWrite: true);
            await Future.delayed(const Duration(milliseconds: 100));
          } catch (e) {
            AppLogger.error('Chunk $i send error: $e');
            sendSuccess = false;
            break;
          }
        }

        if (sendSuccess) {
          final completer = Completer<bool>();
          StreamSubscription<List<int>>? sub;

          sub = _characteristic!.onValueReceived.listen((event) {
            try {
              final response = utf8.decode(event).trim();
              AppLogger.info('Config response: $response');

              if (response == 'mqtt_registered') {
                AppLogger.info('✅ Device registered successfully!');
                if (!completer.isCompleted) {
                  completer.complete(true);
                  sub?.cancel();
                }
              } else if (response == 'error_too_large') {
                AppLogger.error('❌ Config data too large!');
                if (!completer.isCompleted) {
                  completer.complete(false);
                  sub?.cancel();
                }
              }
            } catch (e) {
              AppLogger.error('Parse config response error: $e');
            }
          });

          return await completer.future.timeout(
            timeout,
            onTimeout: () {
              AppLogger.warning('⏰ Timeout waiting for config response');
              sub?.cancel();
              return false;
            },
          );
        }

        AppLogger.warning('Config send retry ${attempt + 1}');
        await Future.delayed(const Duration(seconds: 2));
      }

      return false;
    } catch (e) {
      AppLogger.error('Send config error: $e');
      return false;
    }
  }

  /// Ngắt kết nối với thiết bị
  Future<void> disconnect() async {
    await _forceCleanup();
    await FlutterBluePlus.stopScan();
    AppLogger.info('BLE cleanup completed');
  }

  /// Cleanup
  void dispose() {
    disconnect();
  }
}
