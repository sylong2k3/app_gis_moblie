import 'package:app_core/domain/entities/map_layer_api.dart';

class MapLayerApiModel extends MapLayerApi {
  const MapLayerApiModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.slug,
    super.description,
    required super.endpointUrl,
    required super.httpMethod,
    required super.status,
    super.publishedAt,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MapLayerApiModel.fromJson(Map<String, dynamic> json) {
    return MapLayerApiModel(
      id: json['id'].toString(),
      categoryId: json['category_id'].toString(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      endpointUrl: json['endpoint_url'] as String,
      httpMethod: json['http_method'] as String,
      status: json['status'] as String,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdBy: json['created_by'].toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  MapLayerApi toEntity() => MapLayerApi(
    id: id,
    categoryId: categoryId,
    name: name,
    slug: slug,
    description: description,
    endpointUrl: endpointUrl,
    httpMethod: httpMethod,
    status: status,
    publishedAt: publishedAt,
    createdBy: createdBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class MapLayerApiResponseModel extends MapLayerApiResponse {
  const MapLayerApiResponseModel({required super.api});

  factory MapLayerApiResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final apiJson = data['api'] as Map<String, dynamic>;

    return MapLayerApiResponseModel(api: MapLayerApiModel.fromJson(apiJson));
  }
}
