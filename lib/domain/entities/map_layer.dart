import 'package:equatable/equatable.dart';

enum LayerType { point, line, polygon, raster }

class MapLayer extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LayerType? type;
  final bool isVisible;
  final double opacity;
  final Map<String, dynamic>? properties;
  final String? sourceUrl;

  const MapLayer({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.isActive,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.type,
    this.isVisible = true,
    this.opacity = 1.0,
    this.properties,
    this.sourceUrl,
  });

  MapLayer copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isActive,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    LayerType? type,
    bool? isVisible,
    double? opacity,
    Map<String, dynamic>? properties,
    String? sourceUrl,
  }) {
    return MapLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      isVisible: isVisible ?? this.isVisible,
      opacity: opacity ?? this.opacity,
      properties: properties ?? this.properties,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    isActive,
    createdBy,
    createdAt,
    updatedAt,
    type,
    isVisible,
    opacity,
    properties,
    sourceUrl,
  ];
}
