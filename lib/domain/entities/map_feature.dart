import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum FeatureType {
  point,
  lineString,
  polygon,
}

class MapFeature extends Equatable {
  final String id;
  final String name;
  final FeatureType type;
  final List<LatLng> coordinates;
  final Map<String, dynamic> properties;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const MapFeature({
    required this.id,
    required this.name,
    required this.type,
    required this.coordinates,
    this.properties = const {},
    this.description,
    this.createdAt,
    this.updatedAt,
  });
  
  MapFeature copyWith({
    String? id,
    String? name,
    FeatureType? type,
    List<LatLng>? coordinates,
    Map<String, dynamic>? properties,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MapFeature(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
      properties: properties ?? this.properties,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
        id,
        name,
        type,
        coordinates,
        properties,
        description,
        createdAt,
        updatedAt,
      ];
}