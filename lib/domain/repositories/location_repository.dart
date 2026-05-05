import 'package:app_core/shared/utils/either.dart';
import 'package:dartz/dartz.dart';
import '../entities/user_location.dart';

abstract class LocationRepository {
  Future<Either<Failure, UserLocation>> getCurrentLocation();
  Stream<UserLocation> watchLocation();
  Future<Either<Failure, bool>> checkLocationPermission();
  Future<Either<Failure, bool>> requestLocationPermission();
  Future<Either<Failure, bool>> isLocationServiceEnabled();
  Future<Either<Failure, Unit>> openLocationSettings();
}