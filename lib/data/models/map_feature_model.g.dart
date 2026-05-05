// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_feature_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapFeatureModel _$MapFeatureModelFromJson(Map<String, dynamic> json) =>
    MapFeatureModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$FeatureTypeEnumMap, json['type']),
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => LatLng.fromJson(e as Map<String, dynamic>))
          .toList(),
      properties: json['properties'] as Map<String, dynamic>? ?? const {},
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MapFeatureModelToJson(MapFeatureModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$FeatureTypeEnumMap[instance.type]!,
      'coordinates': instance.coordinates,
      'properties': instance.properties,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$FeatureTypeEnumMap = {
  FeatureType.point: 'point',
  FeatureType.lineString: 'lineString',
  FeatureType.polygon: 'polygon',
};
