class AppConstants {
  // Shared Preferences Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // Hive Boxes
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
  static const String translationsBox = 'translations_box';

  // App Settings
  static const String appName =
      'AquaFarm'; // General app name for internal use
  static const String appNameMaterial =
      'AquaFarm Flutter Base'; // Name for MaterialApp title
  static const String appVersion = '1.0.0';

  // Error Messages
  static const String networkErrorMessage =
      'No internet connection. Please check your network settings.';
  static const String generalErrorMessage =
      'Something went wrong. Please try again.';
  static const String timeoutErrorMessage =
      'The request timed out. Please try again.';
  static const String unauthorizedErrorMessage =
      'Authentication failed. Please login again.';
  static const String forbiddenErrorMessage =
      'You don\'t have permission to access this resource.';
  static const String notFoundErrorMessage =
      'The requested resource was not found.';
  static const String serverErrorMessage =
      'A server error occurred. Please try again later.';

  // Network settings
  static const int initialRetryDelayMs = 500;

  // Cache settings
  static const Duration cacheMaxAge = Duration(days: 7);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Search settings
  static const int searchPageSize = 20;

  // Responsiveness Breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 900;

  // Environment Flavor Keys
  static const String envFlavorKey = 'FLAVOR';
  static const String envFlavorDefaultDev = 'dev';
  static const String envFlavorProd = 'prod';
  static const String envFlavorStaging = 'staging';
}

/// Hive box names centralized
class HiveBoxNames {
  static const String settings = AppConstants.settingsBox;
  static const String cache = AppConstants.cacheBox;
}
