import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app_core/data/datasources/local/auth_local_datasource.dart';
import 'package:app_core/data/datasources/remote/citizen_feedback_remote_datasource.dart';
import 'package:app_core/data/models/citizen_feedback_model.dart';
import 'package:app_core/domain/entities/citizen_feedback.dart';
import 'package:app_core/domain/repositories/citizen_feedback_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:app_core/shared/utils/logger.dart';

class CitizenFeedbackRepositoryImpl implements CitizenFeedbackRepository {
  final CitizenFeedbackRemoteDatasource remoteDatasource;
  final AuthLocalDatasource authLocalDatasource;

  CitizenFeedbackRepositoryImpl({
    required this.remoteDatasource,
    required this.authLocalDatasource,
  });

  @override
  Future<Either<Failure, CitizenFeedback>> submitFeedback({
    required String title,
    required String content,
    required String location,
    required String priority,
    required List<File> images,
  }) async {
    try {
      // Lấy access token
      final accessToken = await authLocalDatasource.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        return Left(
          AuthenticationFailure(message: 'Vui lòng đăng nhập để gửi phản ánh'),
        );
      }

      // Gọi API
      final response = await remoteDatasource.submitFeedback(
        title: title,
        content: content,
        location: location,
        priority: priority,
        images: images,
        accessToken: accessToken,
      );

      // Parse response
      final feedback = CitizenFeedbackModel.fromJson(response);

      AppLogger.info('Citizen feedback submitted successfully: ${feedback.id}');
      return Right(feedback);
    } on DioException catch (e) {
      AppLogger.error('DioException submitting feedback: ${e.message}');

      if (e.response?.statusCode == 401) {
        return Left(AuthenticationFailure(message: 'Phiên đăng nhập hết hạn'));
      }

      // Parse validation errors from response
      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data;

        if (responseData is Map<String, dynamic>) {
          final errors = responseData['errors'] as List<dynamic>?;

          if (errors != null && errors.isNotEmpty) {
            // Build detailed error message from validation errors
            final errorMessages = <String>[];

            for (final error in errors) {
              if (error is Map<String, dynamic>) {
                final field = error['field'] as String?;
                final message = error['message'] as String?;

                if (field != null && message != null) {
                  errorMessages.add('• $message');
                }
              }
            }

            if (errorMessages.isNotEmpty) {
              final detailedMessage =
                  'Dữ liệu không hợp lệ:\n${errorMessages.join('\n')}';
              return Left(ValidationFailure(message: detailedMessage));
            }
          }

          // Fallback to general message if no detailed errors
          final generalMessage = responseData['message'] as String?;
          if (generalMessage != null) {
            return Left(ValidationFailure(message: generalMessage));
          }
        }
      }

      final errorMessage =
          e.response?.data?['message'] as String? ??
          'Không thể gửi phản ánh. Vui lòng thử lại';

      return Left(ServerFailure(message: errorMessage));
    } catch (e) {
      AppLogger.error('Error submitting feedback: $e');
      return Left(ServerFailure(message: 'Đã xảy ra lỗi. Vui lòng thử lại'));
    }
  }
}
