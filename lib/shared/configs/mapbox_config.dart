import 'package:app_core/shared/configs/env_config.dart';

class MapboxConfig {
  // Private constructor
  MapboxConfig._();

  /// Mapbox access token from environment
  static String get accessToken => EnvConfig.mapboxToken;

  /// Downloads token (same as access token for simplicity)
  static String get downloadsToken => EnvConfig.mapboxToken;

  /// Check if Mapbox is properly configured
  static bool get isConfigured => EnvConfig.isMapboxConfigured;

  /// Default map style
  static const String defaultStyle = 'mapbox://styles/mapbox/streets-v11';

  /// Map configuration
  static const double defaultZoom = 11.0;
  static const double minZoom = 1.0;
  static const double maxZoom = 20.0;

  /// Default camera position (Ho Chi Minh City)
  static const double defaultLatitude = 21.0278;
  static const double defaultLongitude = 105.8342;

  /// Validate token format
  static bool isValidToken(String token) {
    return token.isNotEmpty && token.startsWith('pk.') && token.length > 20;
  }

  /// Get error message if token is invalid
  static String? getConfigError() {
    if (!isConfigured) {
      return 'Mapbox token not found in environment variables';
    }

    if (!isValidToken(accessToken)) {
      return 'Invalid Mapbox token format';
    }

    return null;
  }
}
