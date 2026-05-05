import 'package:app_core/domain/entities/user_location.dart';
import 'package:app_core/domain/repositories/location_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:app_core/shared/utils/usecase.dart';
import 'package:dartz/dartz.dart';


class GetCurrentLocation implements UseCase<UserLocation, NoParams> {
  final LocationRepository repository;
  
  GetCurrentLocation(this.repository);
  
  @override
  Future<Either<Failure, UserLocation>> call(NoParams params) async {
    return await repository.getCurrentLocation();
  }
}