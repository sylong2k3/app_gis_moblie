import 'package:app_core/data/datasources/local/auth_local_datasource.dart';
import 'package:app_core/shared/constants/api_endpoints.dart';
import 'package:app_core/shared/network/auth_interceptor.dart';
import 'package:dio/dio.dart';

Dio createDio(AuthLocalDatasource authLocalDatasource) {
  final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));

  dio.interceptors.add(AuthInterceptor(authLocalDatasource));

  return dio;
}
