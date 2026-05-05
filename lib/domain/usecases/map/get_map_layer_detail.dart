import 'package:app_core/domain/entities/map_layer_detail.dart';
import 'package:app_core/domain/repositories/map_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:dartz/dartz.dart';

class GetMapLayerDetail {
  final MapRepository repository;

  GetMapLayerDetail(this.repository);

  Future<Either<Failure, MapLayerDetailResponse>> call(String layerId) async {
    return await repository.getMapLayerDetail(layerId);
  }
}
