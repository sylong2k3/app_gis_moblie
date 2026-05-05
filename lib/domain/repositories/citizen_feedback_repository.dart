import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:app_core/domain/entities/citizen_feedback.dart';
import 'package:app_core/shared/utils/either.dart';

abstract class CitizenFeedbackRepository {
  Future<Either<Failure, CitizenFeedback>> submitFeedback({
    required String title,
    required String content,
    required String location,
    required String priority,
    required List<File> images,
  });
}
