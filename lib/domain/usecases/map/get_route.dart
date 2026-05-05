import 'package:app_core/domain/entities/route_info.dart';
import 'package:app_core/domain/repositories/routing_repository.dart';
import 'package:app_core/shared/utils/either.dart';
import 'package:app_core/shared/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';


class GetRoute implements UseCase<RouteInfo, GetRouteParams> {
  final RoutingRepository repository;
  
  GetRoute(this.repository);
  
  @override
  Future<Either<Failure, RouteInfo>> call(GetRouteParams params) async {
    return await repository.getRoute(
      origin: params.origin,
      destination: params.destination,
      profile: params.profile,
      alternatives: params.alternatives,
      steps: params.steps,
    );
  }
}

class GetRouteParams extends Equatable {
  final LatLng origin;
  final LatLng destination;
  final RouteProfile profile;
  final bool alternatives;
  final bool steps;
  
  const GetRouteParams({
    required this.origin,
    required this.destination,
    this.profile = RouteProfile.driving,
    this.alternatives = false,
    this.steps = true,
  });
  
  @override
  List<Object> get props => [origin, destination, profile, alternatives, steps];
}