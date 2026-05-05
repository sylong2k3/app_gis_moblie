import 'package:equatable/equatable.dart';

class MapLayerApi extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String slug;
  final String? description;
  final String endpointUrl;
  final String httpMethod;
  final String status;
  final DateTime? publishedAt;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MapLayerApi({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    required this.endpointUrl,
    required this.httpMethod,
    required this.status,
    this.publishedAt,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    categoryId,
    name,
    slug,
    description,
    endpointUrl,
    httpMethod,
    status,
    publishedAt,
    createdBy,
    createdAt,
    updatedAt,
  ];
}

class MapLayerApiResponse extends Equatable {
  final MapLayerApi api;

  const MapLayerApiResponse({required this.api});

  @override
  List<Object?> get props => [api];
}
