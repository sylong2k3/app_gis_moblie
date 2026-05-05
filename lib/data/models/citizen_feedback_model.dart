import 'package:app_core/domain/entities/citizen_feedback.dart';

class CitizenFeedbackModel extends CitizenFeedback {
  const CitizenFeedbackModel({
    super.id,
    required super.title,
    required super.content,
    required super.location,
    super.imageUrls,
    super.createdAt,
  });

  factory CitizenFeedbackModel.fromJson(Map<String, dynamic> json) {
    return CitizenFeedbackModel(
      id: json['id']?.toString(),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      location: json['location'] as String? ?? '',
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'location': location,
      'imageUrls': imageUrls,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
