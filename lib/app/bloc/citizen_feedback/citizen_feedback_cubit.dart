import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_core/domain/entities/citizen_feedback.dart';
import 'package:app_core/domain/usecases/citizen_feedback/submit_citizen_feedback.dart';

part 'citizen_feedback_state.dart';

class CitizenFeedbackCubit extends Cubit<CitizenFeedbackState> {
  final SubmitCitizenFeedback submitCitizenFeedback;

  CitizenFeedbackCubit({required this.submitCitizenFeedback})
    : super(CitizenFeedbackInitial());

  Future<void> submitFeedback({
    required String title,
    required String content,
    required String location,
    required String priority,
    required List<File> images,
  }) async {
    debugPrint('📤 Submitting feedback...');
    emit(CitizenFeedbackSubmitting());

    final result = await submitCitizenFeedback(
      SubmitCitizenFeedbackParams(
        title: title,
        content: content,
        location: location,
        priority: priority,
        images: images,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Feedback submission failed: ${failure.message}');
        emit(CitizenFeedbackError(failure.message));
      },
      (feedback) {
        debugPrint('✅ Feedback submitted successfully: ${feedback.id}');
        emit(CitizenFeedbackSubmitted(feedback));
      },
    );
  }

  void reset() {
    emit(CitizenFeedbackInitial());
  }
}
