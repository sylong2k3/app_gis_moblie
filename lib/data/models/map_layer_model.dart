import '../../domain/entities/map_layer.dart';

class MapLayerModel extends MapLayer {
  const MapLayerModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    required super.isActive,
    super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.type,
    super.isVisible,
    super.opacity,
    super.properties,
    super.sourceUrl,
  });

  factory MapLayerModel.fromJson(Map<String, dynamic> json) {
    return MapLayerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool,
      createdBy: json['created_by'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isVisible: false, // Default to hidden
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MapLayerModel.fromEntity(MapLayer layer) {
    return MapLayerModel(
      id: layer.id,
      name: layer.name,
      description: layer.description,
      imageUrl: layer.imageUrl,
      isActive: layer.isActive,
      createdBy: layer.createdBy,
      createdAt: layer.createdAt,
      updatedAt: layer.updatedAt,
      type: layer.type,
      isVisible: layer.isVisible,
      opacity: layer.opacity,
      properties: layer.properties,
      sourceUrl: layer.sourceUrl,
    );
  }

  MapLayer toEntity() {
    return MapLayer(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      isActive: isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      type: type,
      isVisible: isVisible,
      opacity: opacity,
      properties: properties,
      sourceUrl: sourceUrl,
    );
  }
}
