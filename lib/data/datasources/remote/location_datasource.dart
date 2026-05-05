import 'package:app_core/domain/entities/user_location.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationDataSource {
  Future<UserLocation> getCurrentLocation();
  Stream<UserLocation> watchLocation();
  Future<bool> checkPermission();
  Future<bool> requestPermission();
  Future<bool> isServiceEnabled();
  Future<void> openSettings();
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<UserLocation> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp,
      );
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  @override
  Stream<UserLocation> watchLocation() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings).map(
      (position) => UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp,
      ),
    );
  }

  @override
  Future<bool> checkPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<void> openSettings() async {
    await Geolocator.openLocationSettings();
  }
}
