import 'package:app_core/domain/entities/map_layer_search_result.dart';

class MapLayerSearchResultModel extends MapLayerSearchResult {
  const MapLayerSearchResultModel({
    required super.id,
    required super.name,
    required super.geometryType,
    required super.isActive,
    required super.createdAt,
  });

  factory MapLayerSearchResultModel.fromJson(Map<String, dynamic> json) {
    return MapLayerSearchResultModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      geometryType: json['geometry_type'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'geometry_type': geometryType,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class MapLayerSearchResponseModel extends MapLayerSearchResponse {
  const MapLayerSearchResponseModel({
    required super.keyword,
    required super.label,
    required super.total,
    required super.results,
  });

  factory MapLayerSearchResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final resultsList = data['results'] as List<dynamic>;

    return MapLayerSearchResponseModel(
      keyword: data['keyword'] as String,
      label: data['label'] as String,
      total: data['total'] as int,
      results: resultsList
          .map((item) => MapLayerSearchResultModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
