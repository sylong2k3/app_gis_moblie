import 'package:dio/dio.dart';
import 'package:app_core/data/datasources/local/auth_local_datasource.dart';
import 'package:app_core/shared/utils/logger.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDatasource authLocalDatasource;

  AuthInterceptor(this.authLocalDatasource);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip token injection for auth endpoints that don't need authentication
      if (_isAuthEndpoint(options.path)) {
        AppLogger.debug(
          'Skipping token injection for auth endpoint: ${options.path}',
        );
        handler.next(options);
        return;
      }

      AppLogger.debug('Intercepting request to: ${options.path}');

      // Get access token from local storage
      final accessToken = await authLocalDatasource.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        AppLogger.debug('Adding access token to request headers');
        AppLogger.debug(
          'Token preview: ${accessToken.length > 20 ? "${accessToken.substring(0, 20)}..." : accessToken}',
        );

        options.headers['Authorization'] = 'Bearer $accessToken';
        AppLogger.debug('Authorization header set successfully');
        handler.next(options);
      } else {
        AppLogger.warn('No access token found in storage for ${options.path}');
        handler.next(options);
      }
    } catch (e) {
      AppLogger.error('Auth interceptor error: $e');
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    AppLogger.error(
      'Request error: ${err.response?.statusCode} - ${err.message}',
    );
    AppLogger.error('Error response data: ${err.response?.data}');
    AppLogger.error('Request URL: ${err.requestOptions.uri}');

    // Handle 401 Unauthorized - token expired/invalid
    if (err.response?.statusCode == 401) {
      AppLogger.info('Received 401, token may be expired or invalid');

      try {
        final refreshToken = await authLocalDatasource.getRefreshToken();

        if (refreshToken != null && refreshToken.isNotEmpty) {
          AppLogger.info(
            'Refresh token exists, but auto-refresh not implemented',
          );
          AppLogger.warn('Manual login may be required');
        } else {
          AppLogger.warn('No refresh token available, clearing session');
          // Clear invalid tokens
          await authLocalDatasource.clearSession();
        }
      } catch (e) {
        AppLogger.error('Error handling 401: $e');
        await authLocalDatasource.clearSession();
      }
    }

    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    const authPaths = [
      '/auth/register',
      '/auth/login',
      '/auth/signin',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/auth/confirm-email',
      '/auth/resend-code',
    ];

    return authPaths.any((authPath) => path.contains(authPath));
  }
}
