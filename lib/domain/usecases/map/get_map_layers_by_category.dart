import 'package:app_core/domain/entities/map_layer_feature.dart';
import 'package:app_core/domain/repositories/map_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:dartz/dartz.dart';

class GetMapLayersByCategory {
  final MapRepository repository;

  GetMapLayersByCategory(this.repository);

  Future<Either<Failure, MapLayerFeaturesResponse>> call(int categoryId) async {
    return await repository.getMapLayersByCategory(categoryId);
  }
}
