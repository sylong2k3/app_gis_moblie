part of 'map_cubit.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLayersLoaded extends MapState {
  final List<MapLayer> layers;

  const MapLayersLoaded(this.layers);

  @override
  List<Object> get props => [layers];
}

class MapSearching extends MapState {}

class MapSearchResults extends MapState {
  final List<MapFeature> features;

  const MapSearchResults(this.features);

  @override
  List<Object> get props => [features];
}

class MapFeatureSelected extends MapState {
  final MapFeature feature;

  const MapFeatureSelected(this.feature);

  @override
  List<Object> get props => [feature];
}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object> get props => [message];
}

class MapLayerSearchResults extends MapState {
  final MapLayerSearchResponse response;

  const MapLayerSearchResults(this.response);

  @override
  List<Object> get props => [response];
}

class MapLayerFeaturesLoaded extends MapState {
  final MapLayerFeaturesResponse response;
  final int categoryId;

  const MapLayerFeaturesLoaded(this.response, this.categoryId);

  @override
  List<Object> get props => [response, categoryId];
}

class MapLayerFeaturesLoading extends MapState {
  final int categoryId;

  const MapLayerFeaturesLoading(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class MapLayerFeaturesCleared extends MapState {
  final int categoryId;

  const MapLayerFeaturesCleared(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class MapLayerDetailLoading extends MapState {
  final String layerId;

  const MapLayerDetailLoading(this.layerId);

  @override
  List<Object> get props => [layerId];
}

class MapLayerDetailLoaded extends MapState {
  final MapLayerDetailResponse response;

  const MapLayerDetailLoaded(this.response);

  @override
  List<Object> get props => [response];
}
