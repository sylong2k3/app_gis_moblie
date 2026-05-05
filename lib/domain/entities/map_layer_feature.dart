import 'package:equatable/equatable.dart';

class MapLayerFeature extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String geometryType;
  final Map<String, dynamic> geometryData;
  final Map<String, dynamic> properties;
  final bool isActive;

  const MapLayerFeature({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.geometryType,
    required this.geometryData,
    required this.properties,
    required this.isActive,
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
  ];
}

class MapLayerFeaturesResponse extends Equatable {
  final List<MapLayerFeature> mapLayers;
  final int total;
  final int categoryId;

  const MapLayerFeaturesResponse({
    required this.mapLayers,
    required this.total,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [mapLayers, total, categoryId];
}
