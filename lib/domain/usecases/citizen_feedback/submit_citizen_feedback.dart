import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:app_core/domain/entities/citizen_feedback.dart';
import 'package:app_core/domain/repositories/citizen_feedback_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:app_core/shared/utils/usecase.dart';

class SubmitCitizenFeedback
    implements UseCase<CitizenFeedback, SubmitCitizenFeedbackParams> {
  final CitizenFeedbackRepository repository;

  SubmitCitizenFeedback(this.repository);

  @override
  Future<Either<Failure, CitizenFeedback>> call(
    SubmitCitizenFeedbackParams params,
  ) async {
    return await repository.submitFeedback(
      title: params.title,
      content: params.content,
      location: params.location,
      priority: params.priority,
      images: params.images,
    );
  }
}

class SubmitCitizenFeedbackParams {
  final String title;
  final String content;
  final String location;
  final String priority;
  final List<File> images;

  SubmitCitizenFeedbackParams({
    required this.title,
    required this.content,
    required this.location,
    required this.priority,
    required this.images,
  });
}
