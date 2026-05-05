import 'package:app_core/data/datasources/remote/location_datasource.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/user_location.dart';
import '../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource dataSource;
  
  LocationRepositoryImpl({required this.dataSource});
  
  @override
  Future<Either<Failure, UserLocation>> getCurrentLocation() async {
    try {
      // Check if service is enabled
      final serviceEnabled = await dataSource.isServiceEnabled();
      if (!serviceEnabled) {
        return Left(LocationFailure(message: 'Location service is disabled'));
      }
      
      // Check permission
      final hasPermission = await dataSource.checkPermission();
      if (!hasPermission) {
        return Left(PermissionFailure(message: 'Location permission denied'));
      }
      
      final location = await dataSource.getCurrentLocation();
      return Right(location);
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to get current location: $e'));
    }
  }
  
  @override
  Stream<UserLocation> watchLocation() {
    return dataSource.watchLocation();
  }
  
  @override
  Future<Either<Failure, bool>> checkLocationPermission() async {
    try {
      final hasPermission = await dataSource.checkPermission();
      return Right(hasPermission);
    } catch (e) {
      return Left(PermissionFailure(message: 'Failed to check permission: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> requestLocationPermission() async {
    try {
      final granted = await dataSource.requestPermission();
      return Right(granted);
    } catch (e) {
      return Left(PermissionFailure(message: 'Failed to request permission: $e'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> isLocationServiceEnabled() async {
    try {
      final enabled = await dataSource.isServiceEnabled();
      return Right(enabled);
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to check service status: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> openLocationSettings() async {
    try {
      await dataSource.openSettings();
      return const Right(unit);
    } catch (e) {
      return Left(LocationFailure(message: 'Failed to open settings: $e'));
    }
  }
}