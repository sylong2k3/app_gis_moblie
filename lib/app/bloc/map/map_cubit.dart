import 'package:app_core/domain/entities/map_feature.dart';
import 'package:app_core/domain/entities/map_layer.dart';
import 'package:app_core/domain/entities/map_layer_detail.dart';
import 'package:app_core/domain/entities/map_layer_search_result.dart';
import 'package:app_core/domain/entities/map_layer_feature.dart';
import 'package:app_core/domain/usecases/map/get_layers.dart';
import 'package:app_core/domain/usecases/map/search_features.dart';
import 'package:app_core/domain/usecases/map/search_map_layers.dart';
import 'package:app_core/domain/usecases/map/get_map_layers_by_category.dart';
import 'package:app_core/domain/usecases/map/get_map_layer_detail.dart';
import 'package:app_core/domain/usecases/map/toggle_layer_visibility.dart';
import 'package:app_core/data/datasources/local/layer_visibility_local_datasource.dart';
import 'package:app_core/shared/utils/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final GetLayers getLayers;
  final ToggleLayerVisibility toggleLayerVisibility;
  final SearchFeatures searchFeatures;
  final SearchMapLayers searchMapLayers;
  final GetMapLayersByCategory getMapLayersByCategory;
  final GetMapLayerDetail getMapLayerDetail;
  final LayerVisibilityLocalDataSource layerVisibilityDataSource;
  List<MapLayer> _layersCache = [];

  List<MapLayer> get layersCache => List.unmodifiable(_layersCache);

  MapCubit({
    required this.getLayers,
    required this.toggleLayerVisibility,
    required this.searchFeatures,
    required this.searchMapLayers,
    required this.getMapLayersByCategory,
    required this.getMapLayerDetail,
    required this.layerVisibilityDataSource,
  }) : super(MapInitial());

  Future<void> loadLayers() async {
    emit(MapLoading());

    final result = await getLayers(NoParams());

    result.fold((failure) => emit(MapError(failure.message)), (layers) async {
      // Get visible layer IDs from local storage
      final visibleLayerIds = await layerVisibilityDataSource
          .getVisibleLayerIds();

      // Merge with local visibility state
      final updatedLayers = layers.map((layer) {
        return layer.copyWith(isVisible: visibleLayerIds.contains(layer.id));
      }).toList();

      _layersCache = updatedLayers;

      emit(MapLayersLoaded(updatedLayers));
    });
  }

  Future<void> toggleLayer(String layerId) async {
    final layerIdInt = int.tryParse(layerId);
    if (layerIdInt == null) return;
    if (_layersCache.isEmpty) return;

    // Toggle in local storage and get new state
    final newVisibility = await layerVisibilityDataSource.toggleLayerVisibility(
      layerIdInt,
    );

    // Update UI immediately with new state
    final updatedLayers = _layersCache.map((layer) {
      if (layer.id == layerIdInt) {
        return layer.copyWith(isVisible: newVisibility);
      }
      return layer;
    }).toList();

    _layersCache = updatedLayers;

    emit(MapLayersLoaded(updatedLayers));

    // Persist to cache in background (optional, for backward compatibility)
    await toggleLayerVisibility(ToggleLayerParams(layerId: layerId));
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      loadLayers();
      return;
    }

    emit(MapSearching());

    final result = await searchFeatures(SearchParams(query: query));

    result.fold(
      (failure) => emit(MapError(failure.message)),
      (features) => emit(MapSearchResults(features)),
    );
  }

  void selectFeature(MapFeature feature) {
    emit(MapFeatureSelected(feature));
  }

  void clearSelection() {
    loadLayers();
  }

  Future<void> searchLayers(String keyword) async {
    if (keyword.trim().isEmpty) {
      loadLayers();
      return;
    }

    emit(MapSearching());

    final result = await searchMapLayers(keyword);

    result.fold(
      (failure) => emit(MapError(failure.message)),
      (response) => emit(MapLayerSearchResults(response)),
    );
  }

  Future<void> loadLayerFeatures(int categoryId) async {
    emit(MapLayerFeaturesLoading(categoryId));

    final result = await getMapLayersByCategory(categoryId);

    result.fold(
      (failure) {
        emit(MapError(failure.message));
      },
      (response) {
        emit(MapLayerFeaturesLoaded(response, categoryId));
      },
    );
  }

  void clearLayerFeatures(int categoryId) {
    emit(MapLayerFeaturesCleared(categoryId));
  }

  Future<void> loadLayerDetail(String layerId) async {
    emit(MapLayerDetailLoading(layerId));

    final result = await getMapLayerDetail(layerId);

    result.fold(
      (failure) => emit(MapError(failure.message)),
      (response) => emit(MapLayerDetailLoaded(response)),
    );
  }
}
