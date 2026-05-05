import 'dart:io';
import 'package:dio/dio.dart';
import 'package:app_core/data/datasources/base_datasource.dart';
import 'package:app_core/shared/constants/api_endpoints.dart';

abstract class CitizenFeedbackRemoteDatasource {
  Future<Map<String, dynamic>> submitFeedback({
    required String title,
    required String content,
    required String location,
    required String priority,
    required List<File> images,
    required String accessToken,
  });
}

class CitizenFeedbackRemoteDatasourceImpl extends BaseRemoteDatasource
    implements CitizenFeedbackRemoteDatasource {
  CitizenFeedbackRemoteDatasourceImpl(super.dio);

  @override
  Future<Map<String, dynamic>> submitFeedback({
    required String title,
    required String content,
    required String location,
    required String priority,
    required List<File> images,
    required String accessToken,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'content': content,
      'location': location,
      'priority': priority,
    });

    // Match backend field name (per curl): --form 'images=@"..."'
    // Also keep key repeated to support multiple images.
    for (final image in images) {
      final fileName = image.path.split('/').last;
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(image.path, filename: fileName),
        ),
      );
    }

    final response = await post(
      ApiEndpoints.pathCitizenFeedbacks,
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    return response.data as Map<String, dynamic>;
  }
}
