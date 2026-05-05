import 'package:equatable/equatable.dart';

class MapLayerDetail extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String geometryType;
  final Map<String, dynamic> geometryData;
  final Map<String, dynamic> properties;
  final bool isActive;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MapLayerDetail({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.geometryType,
    required this.geometryData,
    required this.properties,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    categoryId,
    name,
    geometryType,
    geometryData,
    properties,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
  ];
}

class MapLayerDetailResponse extends Equatable {
  final MapLayerDetail mapLayer;

  const MapLayerDetailResponse({required this.mapLayer});

  @override
  List<Object?> get props => [mapLayer];
}
