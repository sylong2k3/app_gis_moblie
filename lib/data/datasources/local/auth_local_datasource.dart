import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_core/shared/constants/shared_preferences_key.dart';

class AuthLocalDatasource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDatasource(this.secureStorage, this.sharedPreferences);

  /// Save user session after successful sign in
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    String? idToken,
    required String email,
    int? expiresAt,
  }) async {
    await Future.wait([
      secureStorage.write(
        key: SharedPreferencesKey.keyAccessToken,
        value: accessToken,
      ),
      secureStorage.write(
        key: SharedPreferencesKey.keyRefreshToken,
        value: refreshToken,
      ),
      if (idToken != null)
        secureStorage.write(
          key: SharedPreferencesKey.keyIdToken,
          value: idToken,
        ),
      secureStorage.write(key: SharedPreferencesKey.keyEmail, value: email),
      if (expiresAt != null)
        secureStorage.write(
          key: SharedPreferencesKey.keyTokenExpiration,
          value: expiresAt.toString(),
        ),
    ]);
  }

  /// Update tokens after refresh
  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
    String? idToken,
    int? expiresAt,
  }) async {
    final futures = <Future<void>>[
      secureStorage.write(
        key: SharedPreferencesKey.keyAccessToken,
        value: accessToken,
      ),
    ];

    if (refreshToken != null) {
      futures.add(
        secureStorage.write(
          key: SharedPreferencesKey.keyRefreshToken,
          value: refreshToken,
        ),
      );
    }

    if (idToken != null) {
      futures.add(
        secureStorage.write(
          key: SharedPreferencesKey.keyIdToken,
          value: idToken,
        ),
      );
    }

    if (expiresAt != null) {
      futures.add(
        secureStorage.write(
          key: SharedPreferencesKey.keyTokenExpiration,
          value: expiresAt.toString(),
        ),
      );
    }

    await Future.wait(futures);
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: SharedPreferencesKey.keyAccessToken);
  }

  /// Get stored ID token
  Future<String?> getIdToken() async {
    return await secureStorage.read(key: SharedPreferencesKey.keyIdToken);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: SharedPreferencesKey.keyRefreshToken);
  }

  /// Get stored token expiration as timestamp
  Future<int?> getTokenExpiration() async {
    final expirationStr = await secureStorage.read(
      key: SharedPreferencesKey.keyTokenExpiration,
    );
    if (expirationStr == null) return null;

    try {
      return int.parse(expirationStr);
    } catch (e) {
      return null;
    }
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    return await secureStorage.read(key: SharedPreferencesKey.keyEmail);
  }

  /// Check if user has valid session (not expired)
  Future<bool> hasValidSession() async {
    final expiresAt = await getTokenExpiration();
    if (expiresAt == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return expiresAt > now;
  }

  /// Check if any session exists (valid or expired)
  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored authentication data
  Future<void> clearSession() async {
    await Future.wait([
      secureStorage.delete(key: SharedPreferencesKey.keyAccessToken),
      secureStorage.delete(key: SharedPreferencesKey.keyIdToken),
      secureStorage.delete(key: SharedPreferencesKey.keyRefreshToken),
      secureStorage.delete(key: SharedPreferencesKey.keyEmail),
      secureStorage.delete(key: SharedPreferencesKey.keyTokenExpiration),
      secureStorage.delete(key: SharedPreferencesKey.keySessionData),
    ]);
  }

  /// Save user attributes/profile data
  Future<void> saveUserAttributes(Map<String, dynamic> attributes) async {
    final jsonStr = jsonEncode(attributes);
    await sharedPreferences.setString(
      SharedPreferencesKey.keyUserAttributes,
      jsonStr,
    );
  }

  /// Get user attributes/profile data
  Future<Map<String, dynamic>?> getUserAttributes() async {
    final jsonStr = sharedPreferences.getString(
      SharedPreferencesKey.keyUserAttributes,
    );
    if (jsonStr == null) return null;

    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Save pending verification email (for resend code feature)
  Future<void> savePendingVerificationEmail(String email) async {
    await sharedPreferences.setString(
      SharedPreferencesKey.keyPendingVerificationEmail,
      email,
    );
  }

  /// Get pending verification email
  Future<String?> getPendingVerificationEmail() async {
    return sharedPreferences.getString(
      SharedPreferencesKey.keyPendingVerificationEmail,
    );
  }

  /// Clear pending verification email
  Future<void> clearPendingVerificationEmail() async {
    await sharedPreferences.remove(
      SharedPreferencesKey.keyPendingVerificationEmail,
    );
  }

  /// Check if user is authenticated (has session)
  Future<bool> isAuthenticated() async {
    return await hasValidSession();
  }

  /// Get complete cached session data for reconstruction
  Future<Map<String, String?>?> getCachedSessionData() async {
    final accessToken = await getAccessToken();
    final idToken = await getIdToken();
    final refreshToken = await getRefreshToken();
    final email = await getUserEmail();

    if (accessToken == null || idToken == null || refreshToken == null) {
      return null;
    }

    return {
      'accessToken': accessToken,
      'idToken': idToken,
      'refreshToken': refreshToken,
      'email': email,
    };
  }

  /// Save last login timestamp
  Future<void> saveLastLoginTime() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await sharedPreferences.setString(
      SharedPreferencesKey.keyLastLoginTime,
      timestamp,
    );
  }

  /// Get last login timestamp
  Future<DateTime?> getLastLoginTime() async {
    final timestampStr = sharedPreferences.getString(
      SharedPreferencesKey.keyLastLoginTime,
    );
    if (timestampStr == null) return null;

    try {
      final timestamp = int.parse(timestampStr);
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }
}
