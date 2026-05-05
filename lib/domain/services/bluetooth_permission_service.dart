import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum BluetoothPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

class BluetoothPermissionService {
  /// Kiểm tra platform hiện tại
  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;

  /// Kiểm tra tất cả Bluetooth permissions
  Future<BluetoothPermissionStatus> checkBluetoothPermissions() async {
    if (isAndroid) {
      return await _checkAndroidBluetoothPermissions();
    } else if (isIOS) {
      return await _checkIOSBluetoothPermissions();
    }
    return BluetoothPermissionStatus.denied;
  }

  /// Android: Kiểm tra Bluetooth Scan & Connect permissions
  Future<BluetoothPermissionStatus> _checkAndroidBluetoothPermissions() async {
    // Android 12+ requires BLUETOOTH_SCAN and BLUETOOTH_CONNECT
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 31) {
        // Android 12+
        final scanStatus = await Permission.bluetoothScan.status;
        final connectStatus = await Permission.bluetoothConnect.status;

        if (scanStatus.isPermanentlyDenied ||
            connectStatus.isPermanentlyDenied) {
          return BluetoothPermissionStatus.permanentlyDenied;
        }

        if (scanStatus.isDenied || connectStatus.isDenied) {
          return BluetoothPermissionStatus.denied;
        }

        if (scanStatus.isGranted && connectStatus.isGranted) {
          return BluetoothPermissionStatus.granted;
        }
      } else {
        // Android < 12: Chỉ cần BLUETOOTH permission (tự động granted)
        return BluetoothPermissionStatus.granted;
      }
    }

    return BluetoothPermissionStatus.denied;
  }

  /// iOS: Kiểm tra Bluetooth permission
  Future<BluetoothPermissionStatus> _checkIOSBluetoothPermissions() async {
    final status = await Permission.bluetooth.status;

    if (status.isPermanentlyDenied) {
      return BluetoothPermissionStatus.permanentlyDenied;
    } else if (status.isDenied) {
      return BluetoothPermissionStatus.denied;
    } else if (status.isGranted) {
      return BluetoothPermissionStatus.granted;
    } else if (status.isRestricted) {
      return BluetoothPermissionStatus.restricted;
    }

    return BluetoothPermissionStatus.denied;
  }

  /// Request Bluetooth permissions
  Future<BluetoothPermissionStatus> requestBluetoothPermissions() async {
    if (isAndroid) {
      return await _requestAndroidBluetoothPermissions();
    } else if (isIOS) {
      return await _requestIOSBluetoothPermissions();
    }
    return BluetoothPermissionStatus.denied;
  }

  Future<BluetoothPermissionStatus>
  _requestAndroidBluetoothPermissions() async {
    final androidInfo = await _getAndroidVersion();

    if (androidInfo >= 31) {
      // Android 12+
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      final scanStatus = statuses[Permission.bluetoothScan]!;
      final connectStatus = statuses[Permission.bluetoothConnect]!;

      if (scanStatus.isPermanentlyDenied || connectStatus.isPermanentlyDenied) {
        return BluetoothPermissionStatus.permanentlyDenied;
      }

      if (scanStatus.isGranted && connectStatus.isGranted) {
        return BluetoothPermissionStatus.granted;
      }

      return BluetoothPermissionStatus.denied;
    }

    return BluetoothPermissionStatus.granted;
  }

  Future<BluetoothPermissionStatus> _requestIOSBluetoothPermissions() async {
    final status = await Permission.bluetooth.request();

    if (status.isPermanentlyDenied) {
      return BluetoothPermissionStatus.permanentlyDenied;
    } else if (status.isGranted) {
      return BluetoothPermissionStatus.granted;
    } else if (status.isRestricted) {
      return BluetoothPermissionStatus.restricted;
    }

    return BluetoothPermissionStatus.denied;
  }

  /// Android: Kiểm tra Location permission (cần cho BLE scan trên Android < 12)
  Future<BluetoothPermissionStatus> checkLocationPermission() async {
    if (!isAndroid) return BluetoothPermissionStatus.granted;

    final androidInfo = await _getAndroidVersion();

    // Android 12+ không cần location permission cho BLE
    if (androidInfo >= 31) {
      return BluetoothPermissionStatus.granted;
    }

    final status = await Permission.location.status;

    if (status.isPermanentlyDenied) {
      return BluetoothPermissionStatus.permanentlyDenied;
    } else if (status.isDenied) {
      return BluetoothPermissionStatus.denied;
    } else if (status.isGranted) {
      return BluetoothPermissionStatus.granted;
    }

    return BluetoothPermissionStatus.denied;
  }

  /// Android: Request Location permission
  Future<BluetoothPermissionStatus> requestLocationPermission() async {
    if (!isAndroid) return BluetoothPermissionStatus.granted;

    final androidInfo = await _getAndroidVersion();
    if (androidInfo >= 31) {
      return BluetoothPermissionStatus.granted;
    }

    final status = await Permission.location.request();

    if (status.isPermanentlyDenied) {
      return BluetoothPermissionStatus.permanentlyDenied;
    } else if (status.isGranted) {
      return BluetoothPermissionStatus.granted;
    }

    return BluetoothPermissionStatus.denied;
  }

  /// Mở App Settings
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Mở Bluetooth Settings
  Future<void> openBluetoothSettings() async {
    if (isAndroid) {
      try {
        // Open Android Bluetooth settings using platform channel
        const platform = MethodChannel('aqua_farm_mobile/bluetooth');
        await platform.invokeMethod('openBluetoothSettings');
      } catch (e) {
        // Fallback: Open general settings
        await openAppSettings();
      }
    } else if (isIOS) {
      // iOS: Cannot open Bluetooth settings directly, open app settings
      await openAppSettings();
    }
  }

  /// Helper: Get Android SDK version
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    // You'll need to use device_info_plus package
    // import 'package:device_info_plus/device_info_plus.dart';
    // final deviceInfo = DeviceInfoPlugin();
    // final androidInfo = await deviceInfo.androidInfo;
    // return androidInfo.version.sdkInt;

    // For now, return a safe default
    return 31; // Assume Android 12+
  }
}
