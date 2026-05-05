part of 'citizen_feedback_cubit.dart';

abstract class CitizenFeedbackState extends Equatable {
  const CitizenFeedbackState();

  @override
  List<Object?> get props => [];
}

class CitizenFeedbackInitial extends CitizenFeedbackState {}

class CitizenFeedbackSubmitting extends CitizenFeedbackState {}

class CitizenFeedbackSubmitted extends CitizenFeedbackState {
  final CitizenFeedback feedback;

  const CitizenFeedbackSubmitted(this.feedback);

  @override
  List<Object?> get props => [feedback];
}

class CitizenFeedbackError extends CitizenFeedbackState {
  final String message;

  const CitizenFeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}
