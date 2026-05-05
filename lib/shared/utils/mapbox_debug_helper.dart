import 'package:app_core/shared/configs/env_config.dart';
import 'package:app_core/shared/utils/logger.dart';

class MapboxDebugHelper {
  static void validateMapboxSetup() {
    AppLogger.info('=== MAPBOX CONFIGURATION DEBUG ===');
    
    // Check environment token
    final envToken = EnvConfig.mapboxToken;
    AppLogger.info('Environment token: ${envToken.isNotEmpty ? "EXISTS (${envToken.length} chars)" : "MISSING"}');
    
    if (envToken.isNotEmpty) {
      AppLogger.info('Token preview: ${envToken.substring(0, envToken.length > 20 ? 20 : envToken.length)}...');
      
      // Validate token format
      if (envToken.startsWith('pk.')) {
        AppLogger.info('Token format: Valid (starts with pk.)');
      } else if (envToken.startsWith('sk.')) {
        AppLogger.warn('Token format: Secret token detected (should use public token)');
      } else {
        AppLogger.error('Token format: Invalid (should start with pk. or sk.)');
      }
    }
    
    AppLogger.info('Mapbox configured: ${EnvConfig.isMapboxConfigured}');
    AppLogger.info('=== END MAPBOX DEBUG ===');
  }

  static String getValidatedToken() {
    final token = EnvConfig.mapboxToken;
    
    if (token.isEmpty) {
      AppLogger.error('Mapbox token is empty!');
      return '';
    }
    
    if (!token.startsWith('pk.')) {
      AppLogger.error('Invalid Mapbox token format. Must start with "pk."');
      return '';
    }
    
    return token;
  }
}