import 'dart:io';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Kiểm tra GPS có được bật không (chỉ Android)
  Future<bool> isLocationServiceEnabled() async {
    if (!Platform.isAndroid) return true;
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Mở Location Settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Listen to location service status changes
  Stream<ServiceStatus> get serviceStatusStream {
    if (!Platform.isAndroid) {
      // iOS không cần GPS cho BLE scanning
      return Stream.value(ServiceStatus.enabled);
    }
    return Geolocator.getServiceStatusStream();
  }
}
