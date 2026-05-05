import 'package:app_core/data/datasources/local/map_local_datasource.dart';
import 'package:app_core/data/datasources/remote/map_remote_datasource.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:dartz/dartz.dart';
import 'package:turf/turf.dart' as turf;
import '../../domain/entities/map_feature.dart';
import '../../domain/entities/map_layer.dart';
import '../../domain/entities/map_layer_search_result.dart';
import '../../domain/entities/map_layer_feature.dart';
import '../../domain/entities/map_layer_detail.dart';
import '../../domain/repositories/map_repository.dart';
import '../models/map_feature_model.dart';
import '../models/map_layer_model.dart';

class MapRepositoryImpl implements MapRepository {
  final MapLocalDataSource localDataSource;
  final MapRemoteDataSource remoteDataSource;

  MapRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<MapLayer>>> getLayers() async {
    try {
      // Call API to get categories
      final categories = await remoteDataSource.getCategories();

      // Cache the result
      await localDataSource.cacheLayers(categories);

      return Right(categories.map((model) => model.toEntity()).toList());
    } catch (e) {
      // If API fails, try to get from cache
      try {
        final layers = await localDataSource.getCachedLayers();
        return Right(layers.map((model) => model.toEntity()).toList());
      } catch (cacheError) {
        return Left(ServerFailure(message: 'Failed to get layers: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, MapLayer>> getLayerById(String layerId) async {
    try {
      final layer = await localDataSource.getCachedLayerById(layerId);
      if (layer == null) {
        return Left(CacheFailure(message: 'Layer not found'));
      }
      return Right(layer.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get layer: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleLayerVisibility(String layerId) async {
    try {
      final layer = await localDataSource.getCachedLayerById(layerId);
      if (layer == null) {
        return Left(CacheFailure(message: 'Layer not found'));
      }

      final updatedLayer = MapLayerModel.fromEntity(
        layer.toEntity().copyWith(isVisible: !layer.isVisible),
      );

      await localDataSource.cacheLayer(updatedLayer);
      return const Right(unit);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to toggle layer visibility: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateLayerOpacity(
    String layerId,
    double opacity,
  ) async {
    try {
      final layer = await localDataSource.getCachedLayerById(layerId);
      if (layer == null) {
        return Left(CacheFailure(message: 'Layer not found'));
      }

      final updatedLayer = MapLayerModel.fromEntity(
        layer.toEntity().copyWith(opacity: opacity),
      );

      await localDataSource.cacheLayer(updatedLayer);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update layer opacity: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MapFeature>>> getFeatures(String layerId) async {
    try {
      final features = await localDataSource.getCachedFeatures(layerId);
      return Right(features.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get features: $e'));
    }
  }

  @override
  Future<Either<Failure, MapFeature>> getFeatureById(String featureId) async {
    try {
      final feature = await localDataSource.getCachedFeatureById(featureId);
      if (feature == null) {
        return Left(CacheFailure(message: 'Feature not found'));
      }
      return Right(feature.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get feature: $e'));
    }
  }

  @override
  Future<Either<Failure, MapFeature>> createFeature(MapFeature feature) async {
    try {
      final model = MapFeatureModel.fromEntity(feature);
      await localDataSource.cacheFeature(model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to create feature: $e'));
    }
  }

  @override
  Future<Either<Failure, MapFeature>> updateFeature(MapFeature feature) async {
    try {
      final model = MapFeatureModel.fromEntity(
        feature.copyWith(updatedAt: DateTime.now()),
      );
      await localDataSource.cacheFeature(model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update feature: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteFeature(String featureId) async {
    try {
      await localDataSource.deleteFeatureFromCache(featureId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete feature: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MapFeature>>> searchFeatures(String query) async {
    try {
      final allLayers = await localDataSource.getCachedLayers();
      List<MapFeatureModel> allFeatures = [];

      for (var layer in allLayers) {
        final features = await localDataSource.getCachedFeatures(
          layer.id.toString(),
        );
        allFeatures.addAll(features);
      }

      final searchResults = allFeatures
          .where(
            (feature) =>
                feature.name.toLowerCase().contains(query.toLowerCase()) ||
                feature.description?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ==
                    true,
          )
          .toList();

      return Right(searchResults.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to search features: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFeatureProperties(
    String featureId,
  ) async {
    try {
      final feature = await localDataSource.getCachedFeatureById(featureId);
      if (feature == null) {
        return Left(CacheFailure(message: 'Feature not found'));
      }
      return Right(feature.properties);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to get feature properties: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, double>> measureDistance(
    List<Map<String, double>> coordinates,
  ) async {
    try {
      if (coordinates.length < 2) {
        return Left(
          MapFailure(message: 'Need at least 2 points to measure distance'),
        );
      }

      final points = coordinates.map((coord) {
        return turf.Point(
          coordinates: turf.Position(coord['lng']!, coord['lat']!),
        );
      }).toList();

      double totalDistance = 0;
      for (int i = 0; i < points.length - 1; i++) {
        final distance = turf.distance(
          points[i],
          points[i + 1],
          turf.Unit.meters,
        );
        totalDistance += distance;
      }

      return Right(totalDistance);
    } catch (e) {
      return Left(MapFailure(message: 'Failed to measure distance: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> measureArea(
    List<Map<String, double>> coordinates,
  ) async {
    try {
      if (coordinates.length < 3) {
        return Left(
          MapFailure(message: 'Need at least 3 points to measure area'),
        );
      }

      final positions = coordinates.map((coord) {
        return turf.Position(coord['lng']!, coord['lat']!);
      }).toList();

      // Close the polygon if not already closed
      if (positions.first != positions.last) {
        positions.add(positions.first);
      }

      final polygon = turf.Polygon(coordinates: [positions]);
      final area = turf.area(polygon);

      return Right(area!.toDouble());
    } catch (e) {
      return Left(MapFailure(message: 'Failed to measure area: $e'));
    }
  }

  @override
  Future<Either<Failure, MapLayerSearchResponse>> searchMapLayers(
    String keyword,
  ) async {
    try {
      final response = await remoteDataSource.searchMapLayers(keyword);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search map layers: $e'));
    }
  }

  @override
  Future<Either<Failure, MapLayerFeaturesResponse>> getMapLayersByCategory(
    int categoryId,
  ) async {
    try {
      final response = await remoteDataSource.getMapLayersByCategory(
        categoryId,
      );
      return Right(response);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to get map layers by category: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, MapLayerDetailResponse>> getMapLayerDetail(
    String layerId,
  ) async {
    try {
      final response = await remoteDataSource.getMapLayerDetail(layerId);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get map layer detail: $e'));
    }
  }
}
