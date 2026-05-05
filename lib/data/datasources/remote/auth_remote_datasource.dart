import 'package:app_core/shared/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:app_core/shared/utils/logger.dart';

class AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasource(this.dio);

  /// Register a new user with email and password
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await dio.post(
        ApiEndpoints.pathAuthRegister,
        data: {'email': email, 'password': password},
      );

      // Handle API response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['data'] != null) {
        return responseData['data'];
      }
      return responseData;
    } catch (e) {
      AppLogger.error('Register failed: $e');
      rethrow;
    }
  }

  /// Confirm user email with verification code
  Future<Map<String, dynamic>> confirmEmail(String email, String code) async {
    try {
      final response = await dio.post(
        ApiEndpoints.pathAuthConfirmEmail,
        data: {'email': email, 'code': code},
      );

      // Handle API response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['data'] != null) {
        return responseData['data'];
      }
      return responseData;
    } catch (e) {
      AppLogger.error('Confirm email failed: $e');
      rethrow;
    }
  }

  /// Sign in user and return tokens
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await dio.post(
        ApiEndpoints.pathAuthLogin,
        data: {'login': email, 'password': password},
      );

      AppLogger.info('Sign in API response: ${response.data}');

      // Handle API response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        // Check if response has the expected structure with 'data' field
        if (responseData['data'] != null) {
          final tokenData = responseData['data'] as Map<String, dynamic>;
          AppLogger.info('Sign in successful - extracting token data');
          return tokenData;
        }
        // Fallback: return the response data directly if no 'data' field
        AppLogger.info('Sign in successful - using response directly');
        return responseData;
      }

      throw Exception('Invalid response format from server');
    } catch (e) {
      AppLogger.error('Sign in failed: $e');
      rethrow;
    }
  }

  /// Refresh user session with refresh token
  Future<Map<String, dynamic>> refreshSession(String refreshToken) async {
    try {
      final response = await dio.post(
        ApiEndpoints.pathAuthRefresh,
        data: {'refreshToken': refreshToken},
      );

      AppLogger.info('Session refresh response: ${response.data}');

      // Handle API response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] != null) {
          return responseData['data'];
        }
        return responseData;
      }

      throw Exception('Invalid refresh response format from server');
    } catch (e) {
      AppLogger.error('Session refresh failed: $e');
      rethrow;
    }
  }

  /// Initiate password reset process
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await dio.post(
        ApiEndpoints.pathAuthForgotPassword,
        data: {'email': email},
      );

      // Handle API response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['data'] != null) {
        return responseData['data'];
      }
      return responseData;
    } catch (e) {
      AppLogger.error('Reset password failed: $e');
      rethrow;
    }
  }

  /// Confirm password reset with code and new password
  Future<Map<String, dynamic>> confirmResetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.pathAuthResetPassword,
        data: {'email': email, 'code': code, 'newPassword': newPassword},
      );

      // Handle API response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['data'] != null) {
        return responseData['data'];
      }
      return responseData;
    } catch (e) {
      AppLogger.error('Confirm reset password failed: $e');
      rethrow;
    }
  }

  /// Sign out user
  Future<Map<String, dynamic>> signOut({required String refreshToken}) async {
    try {
      AppLogger.info('Signing out user...');

      final response = await dio.post(
        ApiEndpoints.pathAuthLogout,
        data: {'refreshToken': refreshToken},
      );

      AppLogger.info('User signed out successfully');

      // Handle API response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] != null) {
          return responseData['data'];
        }
        return responseData;
      }

      return {'success': true};
    } catch (e) {
      AppLogger.error('Sign out failed: $e');
      rethrow;
    }
  }

  /// Change user password
  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      AppLogger.info('Changing user password...');

      final response = await dio.post(
        ApiEndpoints.pathAuthChangePassword,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );

      AppLogger.info('Password changed successfully');

      // Handle API response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] != null) {
          return responseData['data'];
        }
        return responseData;
      }

      return {'success': true};
    } catch (e) {
      AppLogger.error('Change password failed: $e');
      rethrow;
    }
  }

  /// Resend confirmation code
  Future<Map<String, dynamic>> resendConfirmationCode(String email) async {
    try {
      final response = await dio.post(
        ApiEndpoints.pathAuthResendCode,
        data: {'email': email},
      );

      // Handle API response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['data'] != null) {
        return responseData['data'];
      }
      return responseData;
    } catch (e) {
      AppLogger.error('Resend code failed: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await dio.get(ApiEndpoints.pathAuthProfile);

      AppLogger.info('User profile response: ${response.data}');

      // Handle API response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] != null) {
          return responseData['data'];
        }
        return responseData;
      }

      throw Exception('Invalid user profile response format from server');
    } catch (e) {
      AppLogger.error('Get user profile failed: $e');
      rethrow;
    }
  }

  /// Delete user account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      AppLogger.info('Deleting user account...');

      final response = await dio.delete(ApiEndpoints.pathAuthAccount);

      AppLogger.info('Account deleted successfully');

      // Handle API response structure
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] != null) {
          return responseData['data'];
        }
        return responseData;
      }

      return {'success': true};
    } catch (e) {
      AppLogger.error('Delete account failed: $e');
      rethrow;
    }
  }
}
