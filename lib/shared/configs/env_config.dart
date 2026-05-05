import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Private constructor
  EnvConfig._();

  static EnvConfig? _instance;
  static EnvConfig get instance {
    _instance ??= EnvConfig._();
    return _instance!;
  }

  // Initialize dotenv
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  // Mapbox Configuration
  static String get mapboxToken => dotenv.env['MAPBOX_TOKEN'] ?? '';

  // Custom Mapbox Styles
  static String get mapboxStyleOutdoor =>
      dotenv.env['MAPBOX_STYLE_Outdoor'] ??
      'mapbox://styles/mapbox/outdoors-v12';
  static String get mapboxStyleSatelliteStreet =>
      dotenv.env['MAPBOX_STYLE_Satellite_Street'] ??
      'mapbox://styles/mapbox/satellite-streets-v12';

  // Validate if mapbox is configured
  static bool get isMapboxConfigured => mapboxToken.isNotEmpty;

  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get openWeatherApiKey =>
      dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  // Environment type
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
}
