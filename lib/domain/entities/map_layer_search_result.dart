import 'package:equatable/equatable.dart';

class MapLayerSearchResult extends Equatable {
  final String id;
  final String name;
  final String geometryType;
  final bool isActive;
  final DateTime createdAt;

  const MapLayerSearchResult({
    required this.id,
    required this.name,
    required this.geometryType,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, geometryType, isActive, createdAt];
}

class MapLayerSearchResponse extends Equatable {
  final String keyword;
  final String label;
  final int total;
  final List<MapLayerSearchResult> results;

  const MapLayerSearchResponse({
    required this.keyword,
    required this.label,
    required this.total,
    required this.results,
  });

  @override
  List<Object?> get props => [keyword, label, total, results];
}
