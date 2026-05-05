import 'package:app_core/domain/entities/map_layer_search_result.dart';
import 'package:app_core/domain/repositories/map_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:dartz/dartz.dart';

class SearchMapLayers {
  final MapRepository repository;

  SearchMapLayers(this.repository);

  Future<Either<Failure, MapLayerSearchResponse>> call(String keyword) async {
    if (keyword.trim().isEmpty) {
      return Left(BadRequestFailure(message: 'Keyword cannot be empty'));
    }
    return await repository.searchMapLayers(keyword);
  }
}
