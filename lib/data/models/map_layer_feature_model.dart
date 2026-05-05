import 'package:app_core/domain/entities/map_layer_feature.dart';

class MapLayerFeatureModel extends MapLayerFeature {
  const MapLayerFeatureModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.geometryType,
    required super.geometryData,
    required super.properties,
    required super.isActive,
  });

  factory MapLayerFeatureModel.fromJson(Map<String, dynamic> json) {
    final rawGeometryData = json['geometry_data'];
    final geometryData = rawGeometryData is Map
        ? rawGeometryData.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    final rawProperties = json['properties'];
    final properties = rawProperties is Map
        ? rawProperties.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    final rawIsActive = json['is_active'];
    final isActive = rawIsActive is bool
        ? rawIsActive
        : rawIsActive is num
        ? rawIsActive != 0
        : rawIsActive is String
        ? rawIsActive.toLowerCase() == 'true' || rawIsActive == '1'
        : false;

    return MapLayerFeatureModel(
      id: json['id'].toString(),
      categoryId: json['category_id'].toString(),
      name: (json['name'] ?? '').toString(),
      geometryType: (json['geometry_type'] ?? '').toString(),
      geometryData: geometryData,
      properties: properties,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'geometry_type': geometryType,
      'geometry_data': geometryData,
      'properties': properties,
      'is_active': isActive,
    };
  }
}

class MapLayerFeaturesResponseModel extends MapLayerFeaturesResponse {
  const MapLayerFeaturesResponseModel({
    required super.mapLayers,
    required super.total,
    required super.categoryId,
  });

  factory MapLayerFeaturesResponseModel.fromJson(Map<String, dynamic> json) {
    final rootData = json['data'];
    final data = rootData is Map
        ? rootData.map((key, value) => MapEntry(key.toString(), value))
        : json;

    final rawList = data['mapLayers'] ?? data['map_layers'] ?? data['data'];
    final mapLayersList = rawList is List ? rawList : const <dynamic>[];

    final mapLayers = mapLayersList
        .whereType<Map>()
        .map(
          (item) => MapLayerFeatureModel.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();

    final rawTotal = data['total'];
    final total = rawTotal is num
        ? rawTotal.toInt()
        : int.tryParse(rawTotal?.toString() ?? '') ?? mapLayers.length;

    final rawCategoryId = data['category_id'] ?? data['categoryId'];
    final categoryId = rawCategoryId is num
        ? rawCategoryId.toInt()
        : int.tryParse(rawCategoryId?.toString() ?? '') ?? 0;

    return MapLayerFeaturesResponseModel(
      mapLayers: mapLayers,
      total: total,
      categoryId: categoryId,
    );
  }
}
