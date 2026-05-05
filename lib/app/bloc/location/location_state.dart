part of 'location_cubit.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationPermissionGranted extends LocationState {}

class LocationPermissionDenied extends LocationState {}

class LocationLoaded extends LocationState {
  final UserLocation location;
  
  const LocationLoaded(this.location);
  
  @override
  List<Object> get props => [location];
}

class LocationError extends LocationState {
  final String message;
  
  const LocationError(this.message);
  
  @override
  List<Object> get props => [message];
}