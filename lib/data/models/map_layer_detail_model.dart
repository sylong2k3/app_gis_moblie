import 'package:app_core/domain/entities/map_layer_detail.dart';

class MapLayerDetailModel extends MapLayerDetail {
  const MapLayerDetailModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.geometryType,
    required super.geometryData,
    required super.properties,
    required super.isActive,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MapLayerDetailModel.fromJson(Map<String, dynamic> json) {
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

    final rawCreatedBy = json['created_by'];
    final createdBy = rawCreatedBy is num
        ? rawCreatedBy.toInt()
        : int.tryParse(rawCreatedBy?.toString() ?? '') ?? 0;

    return MapLayerDetailModel(
      id: json['id'].toString(),
      categoryId: json['category_id'].toString(),
      name: (json['name'] ?? '').toString(),
      geometryType: (json['geometry_type'] ?? '').toString(),
      geometryData: geometryData,
      properties: properties,
      isActive: isActive,
      createdBy: createdBy,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  MapLayerDetail toEntity() => MapLayerDetail(
    id: id,
    categoryId: categoryId,
    name: name,
    geometryType: geometryType,
    geometryData: geometryData,
    properties: properties,
    isActive: isActive,
    createdBy: createdBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class MapLayerDetailResponseModel extends MapLayerDetailResponse {
  const MapLayerDetailResponseModel({required super.mapLayer});

  factory MapLayerDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map
        ? rawData.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    final rawMapLayerJson = data['mapLayer'];
    final mapLayerJson = rawMapLayerJson is Map
        ? rawMapLayerJson.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    return MapLayerDetailResponseModel(
      mapLayer: MapLayerDetailModel.fromJson(mapLayerJson),
    );
  }
}
