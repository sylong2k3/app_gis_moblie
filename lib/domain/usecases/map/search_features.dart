import 'package:app_core/domain/entities/map_feature.dart';
import 'package:app_core/domain/repositories/map_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:app_core/shared/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SearchFeatures implements UseCase<List<MapFeature>, SearchParams> {
  final MapRepository repository;
  
  SearchFeatures(this.repository);
  
  @override
  Future<Either<Failure, List<MapFeature>>> call(SearchParams params) async {
    return await repository.searchFeatures(params.query);
  }
}

class SearchParams extends Equatable {
  final String query;
  
  const SearchParams({required this.query});
  
  @override
  List<Object> get props => [query];
}