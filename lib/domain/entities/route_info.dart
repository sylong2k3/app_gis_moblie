import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class RouteInfo extends Equatable {
  final List<LatLng> coordinates;
  final double distance; // in meters
  final double duration; // in seconds
  final String? instructions;
  final List<RouteStep>? steps;
  
  const RouteInfo({
    required this.coordinates,
    required this.distance,
    required this.duration,
    this.instructions,
    this.steps,
  });
  
  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km';
    }
  }
  
  String get formattedDuration {
    final minutes = (duration / 60).floor();
    if (minutes < 60) {
      return '$minutes phút';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = minutes % 60;
      return '$hours giờ $remainingMinutes phút';
    }
  }
  
  @override
  List<Object?> get props => [coordinates, distance, duration, instructions, steps];
}

class RouteStep extends Equatable {
  final String instruction;
  final double distance;
  final double duration;
  final LatLng location;
  
  const RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.location,
  });
  
  @override
  List<Object> get props => [instruction, distance, duration, location];
}