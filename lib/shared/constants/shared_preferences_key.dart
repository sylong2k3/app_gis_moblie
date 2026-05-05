// lib/shared/constants/auth_constants.dart
class SharedPreferencesKey {
  // Secure Storage Keys
  static const String keyAccessToken = 'cognito_access_token';
  static const String keyIdToken = 'cognito_id_token';
  static const String keyRefreshToken = 'cognito_refresh_token';
  static const String keyEmail = 'user_email';
  static const String keyTokenExpiration = 'token_expiration';
  static const String keySessionData = 'session_data';

  // Shared Preferences Keys
  static const String keyUserAttributes = 'user_attributes';
  static const String keyPendingVerificationEmail =
      'pending_verification_email';
  static const String keyLastLoginTime = 'last_login_time';
  static const String keyThemeMode = 'theme_mode';

  // Notifications
  static const String keyFcmToken = 'fcm_token';
}
