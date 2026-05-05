import 'package:app_core/domain/entities/map_layer.dart';
import 'package:app_core/domain/repositories/map_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:app_core/shared/utils/usecase.dart';
import 'package:dartz/dartz.dart';

class GetLayers implements UseCase<List<MapLayer>, NoParams> {
  final MapRepository repository;

  GetLayers(this.repository);

  @override
  Future<Either<Failure, List<MapLayer>>> call(NoParams params) async {
    return await repository.getLayers();
  }
}
