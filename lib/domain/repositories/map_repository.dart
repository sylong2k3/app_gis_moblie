import 'package:app_core/shared/utils/either.dart';
import 'package:dartz/dartz.dart';
import '../entities/map_feature.dart';
import '../entities/map_layer.dart';
import '../entities/map_layer_search_result.dart';
import '../entities/map_layer_feature.dart';
import '../entities/map_layer_detail.dart';

abstract class MapRepository {
  Future<Either<Failure, List<MapLayer>>> getLayers();
  Future<Either<Failure, MapLayer>> getLayerById(String layerId);
  Future<Either<Failure, Unit>> toggleLayerVisibility(String layerId);
  Future<Either<Failure, Unit>> updateLayerOpacity(
    String layerId,
    double opacity,
  );

  Future<Either<Failure, List<MapFeature>>> getFeatures(String layerId);
  Future<Either<Failure, MapFeature>> getFeatureById(String featureId);
  Future<Either<Failure, MapFeature>> createFeature(MapFeature feature);
  Future<Either<Failure, MapFeature>> updateFeature(MapFeature feature);
  Future<Either<Failure, Unit>> deleteFeature(String featureId);

  Future<Either<Failure, List<MapFeature>>> searchFeatures(String query);
  Future<Either<Failure, Map<String, dynamic>>> getFeatureProperties(
    String featureId,
  );

  Future<Either<Failure, double>> measureDistance(
    List<Map<String, double>> coordinates,
  );
  Future<Either<Failure, double>> measureArea(
    List<Map<String, double>> coordinates,
  );

  // Search map layers
  Future<Either<Failure, MapLayerSearchResponse>> searchMapLayers(
    String keyword,
  );

  // Get map layers by category
  Future<Either<Failure, MapLayerFeaturesResponse>> getMapLayersByCategory(
    int categoryId,
  );

  // Get map layer API detail
  Future<Either<Failure, MapLayerDetailResponse>> getMapLayerDetail(
    String layerId,
  );
}
