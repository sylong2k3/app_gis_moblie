// lib/data/repositories/auth_repository_impl.dart
import 'package:app_core/data/datasources/remote/auth_remote_datasource.dart';
import 'package:app_core/data/datasources/local/auth_local_datasource.dart';
import 'package:app_core/domain/entities/auth_user.dart';
import 'package:app_core/domain/entities/user_profile_entity.dart';
import 'package:app_core/domain/repositories/auth_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:app_core/shared/utils/logger.dart';
import 'package:app_core/data/models/user_profile_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource dataSource;
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl(this.dataSource, this.localDatasource);

  @override
  ResultFutureVoid register({
    required String email,
    required String password,
  }) async {
    try {
      await dataSource.register(email, password);
      return const Right(null);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      return Left(AuthenticationFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFutureVoid confirmEmail({
    required String email,
    required String code,
  }) async {
    try {
      await dataSource.confirmEmail(email, code);
      return const Right(null);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      return Left(BadRequestFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dataSource.signIn(email, password);

      AppLogger.info('Repository received token data: $response');

      final accessToken = response['accessToken'] as String?;
      final refreshToken = response['refreshToken'] as String?;
      final expiresIn = response['expiresIn'] as String?;

      if (accessToken == null || refreshToken == null) {
        return const Left(
          AuthenticationFailure(message: 'Invalid response from server'),
        );
      }

      // Calculate expiration time based on expiresIn
      int? expiresAt;
      if (expiresIn != null) {
        try {
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          // Parse duration string like "7d" to seconds
          final durationSeconds = _parseDurationToSeconds(expiresIn);
          expiresAt = now + durationSeconds;
        } catch (e) {
          AppLogger.error('Failed to parse expiresIn: $e');
        }
      }

      await localDatasource.saveSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        idToken: null, // API doesn't provide idToken
        email: email,
        expiresAt: expiresAt,
      );

      // Since API doesn't return user info in login response,
      // we'll use a placeholder user ID or fetch user profile separately
      return Right(
        AuthUser(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
        ),
      );
    } on DioException catch (e) {
      await _cleanup();
      final message = _getErrorMessage(e);
      return Left(AuthenticationFailure(message: message));
    } catch (e) {
      await _cleanup();
      AppLogger.error('Sign in error: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<AuthUser?> getCurrentUser() async {
    try {
      final accessToken = await localDatasource.getAccessToken();
      final email = await localDatasource.getUserEmail();

      if (accessToken == null || email == null) {
        return const Right(null);
      }

      // Check if token is expired
      if (!await _isTokenValid()) {
        // Try to refresh
        final refreshResult = await refreshSession();
        if (refreshResult.isLeft()) {
          await _cleanup();
          return const Right(null);
        }
      }

      // Get user profile from server
      try {
        AppLogger.info('Getting user profile from server...');
        final profile = await dataSource.getUserProfile();
        AppLogger.info('Profile response: $profile');

        final user = profile['user'] as Map<String, dynamic>?;

        if (user != null) {
          final dynamic userIdRaw = user['id'];
          final String? userId = userIdRaw == null
              ? null
              : (userIdRaw is int
                    ? userIdRaw.toString()
                    : userIdRaw as String?);

          final String userEmail = (user['email'] as String?) ?? email;

          if (userId != null && userId.isNotEmpty) {
            return Right(AuthUser(id: userId, email: userEmail));
          }
        }

        AppLogger.warn('User data not found in profile response');
      } catch (e) {
        AppLogger.error('Failed to get user profile: $e');

        // If 401 error, token might be invalid, try refresh
        if (e.toString().contains('401')) {
          AppLogger.info('Got 401, trying to refresh session...');
          final refreshResult = await refreshSession();
          if (refreshResult.isRight()) {
            // Retry getting profile after refresh
            try {
              final profile = await dataSource.getUserProfile();
              final user = profile['user'] as Map<String, dynamic>?;
              if (user != null) {
                final dynamic userIdRaw = user['id'];
                final String? userId = userIdRaw == null
                    ? null
                    : (userIdRaw is int
                          ? userIdRaw.toString()
                          : userIdRaw as String?);

                final String userEmail = (user['email'] as String?) ?? email;

                if (userId != null && userId.isNotEmpty) {
                  return Right(AuthUser(id: userId, email: userEmail));
                }
              }
            } catch (retryError) {
              AppLogger.error('Retry get profile failed: $retryError');
            }
          }
        }
      }

      return const Right(null);
    } catch (e) {
      AppLogger.error('Error getting current user: $e');
      await _cleanup();
      return const Right(null);
    }
  }

  @override
  ResultFuture<UserProfileEntity> getUserProfile() async {
    try {
      final profile = await dataSource.getUserProfile();
      final dynamic userJson = profile['user'] ?? profile;
      if (userJson is Map<String, dynamic>) {
        return Right(UserProfileModel.fromJson(userJson));
      }
      return const Left(
        ServerFailure(message: 'Invalid user profile response format'),
      );
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      return Left(ServerFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFutureVoid refreshSession() async {
    try {
      final refreshToken = await localDatasource.getRefreshToken();
      if (refreshToken == null) {
        return const Left(
          AuthenticationFailure(message: 'No refresh token found'),
        );
      }

      final response = await dataSource.refreshSession(refreshToken);

      final newAccessToken = response['accessToken'] as String?;
      final newRefreshToken = response['refreshToken'] as String?;
      final newIdToken = response['idToken'] as String?;
      final expiresAt = response['expiresAt'] as int?;

      if (newAccessToken == null) {
        return const Left(
          AuthenticationFailure(message: 'Failed to refresh session'),
        );
      }

      await localDatasource.updateTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        idToken: newIdToken,
        expiresAt: expiresAt,
      );

      return const Right(null);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      return Left(AuthenticationFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final result = await getCurrentUser();
      return result.fold((failure) => false, (user) => user != null);
    } catch (e) {
      return false;
    }
  }

  @override
  ResultFutureVoid resetPassword({required String email}) async {
    try {
      await dataSource.resetPassword(email);
      return const Right(null);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      return Left(AuthenticationFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFutureVoid confirmResetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await dataSource.confirmResetPassword(email, code, newPassword);
      return const Right(null);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      return Left(AuthenticationFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFutureVoid changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Check if user is authenticated (token will be auto-injected by interceptor)
      final accessToken = await localDatasource.getAccessToken();
      if (accessToken == null) {
        return const Left(
          AuthenticationFailure(message: 'No authenticated user'),
        );
      }

      AppLogger.info('Changing password for authenticated user...');
      await dataSource.changePassword(oldPassword, newPassword);
      AppLogger.info('Password changed successfully');
      return const Right(null);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      return Left(AuthenticationFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFutureVoid resendConfirmationCode({required String email}) async {
    try {
      await dataSource.resendConfirmationCode(email);
      return const Right(null);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      return Left(AuthenticationFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFutureVoid signOut() async {
    try {
      final accessToken = await localDatasource.getAccessToken();
      final refreshToken = await localDatasource.getRefreshToken();
      if (accessToken != null) {
        try {
          AppLogger.info('Signing out user from server...');
          if (refreshToken == null || refreshToken.isEmpty) {
            AppLogger.warn(
              'No refreshToken found; skipping server signout and cleaning up locally',
            );
          } else {
            await dataSource.signOut(refreshToken: refreshToken);
          }
          AppLogger.info('Server signout successful');
        } catch (e) {
          // Continue with local cleanup even if server signout fails
          AppLogger.warn('Server signout failed: $e');
        }
      } else {
        AppLogger.info(
          'No access token found, proceeding with local cleanup only',
        );
      }
      await _cleanup();
      AppLogger.info('Local cleanup completed');
      return const Right(null);
    } catch (e) {
      await _cleanup();
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFutureVoid deleteAccount() async {
    try {
      // Check if user is authenticated (token will be auto-injected by interceptor)
      final accessToken = await localDatasource.getAccessToken();
      if (accessToken == null) {
        return const Left(
          AuthenticationFailure(message: 'No authenticated user'),
        );
      }

      AppLogger.info('Deleting user account...');
      await dataSource.deleteAccount();
      AppLogger.info('Account deleted successfully');
      await _cleanup();
      return const Right(null);
    } on DioException catch (e) {
      final message = _getErrorMessage(e);
      return Left(AuthenticationFailure(message: message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<String?> getValidIdToken() async {
    if (!await _isTokenValid()) {
      final refreshResult = await refreshSession();
      if (refreshResult.isLeft()) {
        return null;
      }
    }

    return await localDatasource.getIdToken();
  }

  // Helper methods
  Future<bool> _isTokenValid() async {
    final expiresAt = await localDatasource.getTokenExpiration();
    if (expiresAt == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return expiresAt > now + 300; // 5 minutes buffer
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'] as String;
      }
    }

    switch (e.response?.statusCode) {
      case 400:
        return 'Invalid request';
      case 401:
        return 'Email hoặc mật khẩu không đúng';
      case 403:
        return 'Email chưa được xác nhận';
      case 404:
        return 'Tài khoản không tồn tại';
      case 409:
        return 'Email đã được sử dụng';
      case 500:
        return 'Lỗi server, vui lòng thử lại';
      default:
        return e.message ?? 'Có lỗi xảy ra';
    }
  }

  int _parseDurationToSeconds(String duration) {
    final cleanDuration = duration.trim().toLowerCase();
    if (cleanDuration.endsWith('d')) {
      final days = int.parse(
        cleanDuration.substring(0, cleanDuration.length - 1),
      );
      return days * 24 * 60 * 60; // Convert days to seconds
    } else if (cleanDuration.endsWith('h')) {
      final hours = int.parse(
        cleanDuration.substring(0, cleanDuration.length - 1),
      );
      return hours * 60 * 60; // Convert hours to seconds
    } else if (cleanDuration.endsWith('m')) {
      final minutes = int.parse(
        cleanDuration.substring(0, cleanDuration.length - 1),
      );
      return minutes * 60; // Convert minutes to seconds
    } else if (cleanDuration.endsWith('s')) {
      return int.parse(cleanDuration.substring(0, cleanDuration.length - 1));
    } else {
      // Assume seconds if no unit specified
      return int.parse(cleanDuration);
    }
  }

  Future<void> _cleanup() async {
    await localDatasource.clearSession();
  }
}
