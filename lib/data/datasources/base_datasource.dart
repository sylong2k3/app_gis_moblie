import 'package:dio/dio.dart';
import 'package:app_core/shared/utils/logger.dart';

/// Base class cho tất cả remote datasources
/// Cung cấp các tính năng chung: token management, cancel token, error handling
abstract class BaseRemoteDatasource {
  final Dio dio;
  CancelToken? _cancelToken;

  BaseRemoteDatasource(this.dio);

  /// Lấy hoặc tạo mới CancelToken
  CancelToken get cancelToken {
    _cancelToken ??= CancelToken();
    return _cancelToken!;
  }

  /// Hủy tất cả requests đang pending
  void cancelRequests([String? reason]) {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel(reason ?? 'Request cancelled');
      AppLogger.info('Cancelled pending requests: $reason');
    }
    _cancelToken = null;
  }

  /// Wrapper cho GET request với error handling
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      AppLogger.info('GET request to: $path');
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? this.cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      AppLogger.info('GET success: $path - Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleDioError(e, 'GET', path);
      rethrow;
    }
  }

  /// Wrapper cho POST request với error handling
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      AppLogger.info('POST request to: $path');
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? this.cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      AppLogger.info('POST success: $path - Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleDioError(e, 'POST', path);
      rethrow;
    }
  }

  /// Wrapper cho PUT request với error handling
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      AppLogger.info('PUT request to: $path');
      final response = await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? this.cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      AppLogger.info('PUT success: $path - Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleDioError(e, 'PUT', path);
      rethrow;
    }
  }

  /// Wrapper cho DELETE request với error handling
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      AppLogger.info('DELETE request to: $path');
      final response = await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? this.cancelToken,
      );
      AppLogger.info('DELETE success: $path - Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleDioError(e, 'DELETE', path);
      rethrow;
    }
  }

  /// Wrapper cho PATCH request với error handling
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      AppLogger.info('PATCH request to: $path');
      final response = await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken ?? this.cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      AppLogger.info('PATCH success: $path - Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      _handleDioError(e, 'PATCH', path);
      rethrow;
    }
  }

  /// Xử lý lỗi Dio một cách thống nhất
  void _handleDioError(DioException error, String method, String path) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        AppLogger.error('$method $path - Connection timeout');
        break;
      case DioExceptionType.sendTimeout:
        AppLogger.error('$method $path - Send timeout');
        break;
      case DioExceptionType.receiveTimeout:
        AppLogger.error('$method $path - Receive timeout');
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        AppLogger.error('$method $path - Bad response: $statusCode');
        break;
      case DioExceptionType.cancel:
        AppLogger.warning('$method $path - Request cancelled');
        break;
      case DioExceptionType.unknown:
        AppLogger.error('$method $path - Unknown error');
        break;
      default:
        AppLogger.error('$method $path - Error');
    }
  }

  /// Cleanup khi dispose datasource
  void dispose() {
    cancelRequests('Datasource disposed');
  }
}
