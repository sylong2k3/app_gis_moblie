import 'package:equatable/equatable.dart';

class CitizenFeedback extends Equatable {
  final String? id;
  final String title;
  final String content;
  final String location;
  final List<String> imageUrls;
  final DateTime? createdAt;

  const CitizenFeedback({
    this.id,
    required this.title,
    required this.content,
    required this.location,
    this.imageUrls = const [],
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    location,
    imageUrls,
    createdAt,
  ];
}
