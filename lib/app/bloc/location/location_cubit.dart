import 'dart:async';
import 'package:app_core/domain/entities/user_location.dart';
import 'package:app_core/domain/repositories/location_repository.dart';
import 'package:app_core/domain/usecases/map/get_current_location.dart';
import 'package:app_core/shared/utils/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final GetCurrentLocation getCurrentLocation;
  final LocationRepository repository;
  
  StreamSubscription<UserLocation>? _locationSubscription;
  
  LocationCubit({
    required this.getCurrentLocation,
    required this.repository,
  }) : super(LocationInitial());
  
  Future<void> checkPermission() async {
    final result = await repository.checkLocationPermission();
    
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (hasPermission) {
        if (hasPermission) {
          emit(LocationPermissionGranted());
        } else {
          emit(LocationPermissionDenied());
        }
      },
    );
  }
  
  Future<void> requestPermission() async {
    emit(LocationLoading());
    
    final result = await repository.requestLocationPermission();
    
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (granted) {
        if (granted) {
          emit(LocationPermissionGranted());
          getLocation();
        } else {
          emit(LocationPermissionDenied());
        }
      },
    );
  }
  
  Future<void> getLocation() async {
    emit(LocationLoading());
    
    final result = await getCurrentLocation(NoParams());
    
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (location) => emit(LocationLoaded(location)),
    );
  }
  
  void startTracking() {
    _locationSubscription?.cancel();
    
    _locationSubscription = repository.watchLocation().listen(
      (location) {
        emit(LocationLoaded(location));
      },
      onError: (error) {
        emit(LocationError(error.toString()));
      },
    );
  }
  
  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }
  
  @override
  Future<void> close() {
    stopTracking();
    return super.close();
  }
}