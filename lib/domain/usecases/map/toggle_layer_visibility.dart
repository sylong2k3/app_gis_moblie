import 'package:app_core/domain/repositories/map_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:app_core/shared/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';


class ToggleLayerVisibility implements UseCase<Unit, ToggleLayerParams> {
  final MapRepository repository;
  
  ToggleLayerVisibility(this.repository);
  
  @override
  Future<Either<Failure, Unit>> call(ToggleLayerParams params) async {
    return await repository.toggleLayerVisibility(params.layerId);
  }
}

class ToggleLayerParams extends Equatable {
  final String layerId;
  
  const ToggleLayerParams({required this.layerId});
  
  @override
  List<Object> get props => [layerId];
}