import 'package:app_core/shared/configs/mapbox_config.dart';
import 'package:app_core/shared/utils/logger.dart';
import 'package:flutter/services.dart';

class MapboxSetupHelper {
  static const MethodChannel _channel = MethodChannel('mapbox_setup');

  /// Setup Mapbox token for native platforms
  static Future<void> setupNativePlatforms() async {
    try {
      final token = MapboxConfig.accessToken;

      if (!MapboxConfig.isConfigured) {
        AppLogger.error('Cannot setup Mapbox - token not configured');
        return;
      }

      if (!MapboxConfig.isValidToken(token)) {
        AppLogger.error('Cannot setup Mapbox - invalid token format');
        return;
      }

      AppLogger.info('Setting up Mapbox for native platforms...');
      AppLogger.info('Token length: ${token.length}');
      AppLogger.info('Token preview: ${token.substring(0, 20)}...');

      // Try to set token via method channel (if implemented)
      try {
        await _channel.invokeMethod('setAccessToken', {'token': token});
        AppLogger.info('Mapbox token set via method channel');
      } catch (e) {
        AppLogger.warn(
          'Method channel not implemented, relying on platform configuration: $e',
        );
      }

      AppLogger.info('Mapbox native setup completed');
    } catch (e) {
      AppLogger.error('Failed to setup Mapbox for native platforms: $e');
    }
  }

  /// Validate Mapbox setup
  static Future<bool> validateSetup() async {
    try {
      if (!MapboxConfig.isConfigured) {
        AppLogger.error('Mapbox validation failed: Not configured');
        return false;
      }

      final token = MapboxConfig.accessToken;
      if (!MapboxConfig.isValidToken(token)) {
        AppLogger.error('Mapbox validation failed: Invalid token');
        return false;
      }

      // Try to validate via method channel
      try {
        final result = await _channel.invokeMethod('validateToken');
        if (result == true) {
          AppLogger.info('Mapbox token validated successfully');
          return true;
        }
      } catch (e) {
        AppLogger.warn('Could not validate via method channel: $e');
      }

      AppLogger.info('Mapbox setup validation passed (basic checks)');
      return true;
    } catch (e) {
      AppLogger.error('Mapbox validation error: $e');
      return false;
    }
  }

  /// Debug Mapbox configuration
  static void debugConfiguration() {
    AppLogger.info('=== MAPBOX DEBUG ===');
    AppLogger.info('Configured: ${MapboxConfig.isConfigured}');

    if (MapboxConfig.isConfigured) {
      final token = MapboxConfig.accessToken;
      AppLogger.info('Token length: ${token.length}');
      AppLogger.info('Token starts with pk.: ${token.startsWith('pk.')}');
      AppLogger.info(
        'Token preview: ${token.length > 20 ? '${token.substring(0, 20)}...' : token}',
      );
      AppLogger.info('Valid format: ${MapboxConfig.isValidToken(token)}');

      final error = MapboxConfig.getConfigError();
      if (error != null) {
        AppLogger.error('Configuration error: $error');
      }
    } else {
      AppLogger.error('Mapbox not configured');
    }

    AppLogger.info('=== MAPBOX DEBUG END ===');
  }
}
