import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/map_feature.dart';

part 'map_feature_model.g.dart';

@JsonSerializable()
class MapFeatureModel extends MapFeature {
  const MapFeatureModel({
    required super.id,
    required super.name,
    required super.type,
    required super.coordinates,
    super.properties,
    super.description,
    super.createdAt,
    super.updatedAt,
  });
  
  factory MapFeatureModel.fromJson(Map<String, dynamic> json) =>
      _$MapFeatureModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$MapFeatureModelToJson(this);
  
  factory MapFeatureModel.fromEntity(MapFeature feature) {
    return MapFeatureModel(
      id: feature.id,
      name: feature.name,
      type: feature.type,
      coordinates: feature.coordinates,
      properties: feature.properties,
      description: feature.description,
      createdAt: feature.createdAt,
      updatedAt: feature.updatedAt,
    );
  }
  
  MapFeature toEntity() {
    return MapFeature(
      id: id,
      name: name,
      type: type,
      coordinates: coordinates,
      properties: properties,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  // Parse GeoJSON
  factory MapFeatureModel.fromGeoJson(Map<String, dynamic> geoJson) {
    final geometry = geoJson['geometry'];
    final properties = geoJson['properties'] as Map<String, dynamic>? ?? {};
    
    List<LatLng> coords = [];
    FeatureType featureType;
    
    switch (geometry['type']) {
      case 'Point':
        final coord = geometry['coordinates'] as List;
        coords = [LatLng(coord[1], coord[0])];
        featureType = FeatureType.point;
        break;
      case 'LineString':
        coords = (geometry['coordinates'] as List)
            .map((c) => LatLng(c[1], c[0]))
            .toList();
        featureType = FeatureType.lineString;
        break;
      case 'Polygon':
        coords = (geometry['coordinates'][0] as List)
            .map((c) => LatLng(c[1], c[0]))
            .toList();
        featureType = FeatureType.polygon;
        break;
      default:
        throw Exception('Unsupported geometry type');
    }
    
    return MapFeatureModel(
      id: geoJson['id']?.toString() ?? '',
      name: properties['name'] ?? 'Unnamed',
      type: featureType,
      coordinates: coords,
      properties: properties,
      description: properties['description'],
    );
  }
  
  Map<String, dynamic> toGeoJson() {
    String geometryType;
    dynamic coordinates;
    
    switch (type) {
      case FeatureType.point:
        geometryType = 'Point';
        coordinates = [this.coordinates.first.longitude, this.coordinates.first.latitude];
        break;
      case FeatureType.lineString:
        geometryType = 'LineString';
        coordinates = this.coordinates.map((c) => [c.longitude, c.latitude]).toList();
        break;
      case FeatureType.polygon:
        geometryType = 'Polygon';
        coordinates = [this.coordinates.map((c) => [c.longitude, c.latitude]).toList()];
        break;
    }
    
    return {
      'type': 'Feature',
      'id': id,
      'geometry': {
        'type': geometryType,
        'coordinates': coordinates,
      },
      'properties': {
        ...properties,
        'name': name,
        'description': description,
      },
    };
  }
}