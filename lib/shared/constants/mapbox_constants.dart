import 'package:app_core/shared/configs/env_config.dart';

class MapboxConstants {
  // Lấy Access Token từ .env
  static String get accessToken => EnvConfig.mapboxToken;

  // Map Styles - Sử dụng custom styles từ .env
  static const String styleStreet = 'mapbox://styles/mapbox/streets-v12';
  static const String styleSatellite = 'mapbox://styles/mapbox/satellite-v9';

  // Custom styles từ .env
  static String get styleSatelliteStreets =>
      EnvConfig.mapboxStyleSatelliteStreet;
  static String get styleOutdoors => EnvConfig.mapboxStyleOutdoor;

  // Fallback styles
  static const String styleDark = 'mapbox://styles/mapbox/dark-v11';
  static const String styleLight = 'mapbox://styles/mapbox/light-v11';

  // Default Map Settings
  static const double defaultZoom = 8.5;
  static const double defaultLatitude = 13.1820; // Đắk Lắk (Buôn Ma Thuột)
  static const double defaultLongitude = 107.8065;

  // API Endpoints
  static const String directionsBaseUrl =
      'https://api.mapbox.com/directions/v5';
  static const String geocodingBaseUrl = 'https://api.mapbox.com/geocoding/v5';

  // Layer IDs
  static const String pointLayerId = 'point-layer';
  static const String lineLayerId = 'line-layer';
  static const String polygonLayerId = 'polygon-layer';
  static const String routeLayerId = 'route-layer';
}

class AppConstants {
  static const String appName = 'Mapbox Flutter App';
  static const int cacheTimeout = 3600; // seconds
  static const double measurementPrecision = 0.001; // km
}
