import 'package:app_core/shared/utils/either.dart';
import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import '../entities/route_info.dart';

enum RouteProfile {
  driving,
  walking,
  cycling,
  drivingTraffic,
}

abstract class RoutingRepository {
  Future<Either<Failure, RouteInfo>> getRoute({
    required LatLng origin,
    required LatLng destination,
    RouteProfile profile = RouteProfile.driving,
    bool alternatives = false,
    bool steps = true,
  });
  
  Future<Either<Failure, List<RouteInfo>>> getMultipleRoutes({
    required LatLng origin,
    required LatLng destination,
    RouteProfile profile = RouteProfile.driving,
  });
}