// lib/core/errors/failures.dart
import 'package:dartz/dartz.dart';

typedef Result<T> = Either<Failure, T>;
typedef ResultFuture<T> = Future<Result<T>>;
typedef ResultVoid = Result<void>;
typedef ResultFutureVoid = ResultFuture<void>;

abstract class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  String toString() =>
      'Failure: $message ${code != null ? '(Code: $code)' : ''}';
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class NotFoundFailure extends ServerFailure {
  const NotFoundFailure({required super.message}) : super(code: 404);
}

class AuthenticationFailure extends ServerFailure {
  const AuthenticationFailure({required super.message}) : super(code: 401);
}

class AuthorizationFailure extends ServerFailure {
  const AuthorizationFailure({required super.message}) : super(code: 403);
}

class BadRequestFailure extends ServerFailure {
  const BadRequestFailure({required super.message, super.code});
}

class ValidationFailure extends BadRequestFailure {
  const ValidationFailure({required super.message}) : super(code: 400);
}

class TimeoutFailure extends ServerFailure {
  const TimeoutFailure({required super.message}) : super(code: 408);
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ApplicationFailure extends Failure {
  const ApplicationFailure({required super.message});
}

class OperationCancelledFailure extends ApplicationFailure {
  const OperationCancelledFailure() : super(message: 'Operation cancelled');
}

class GpsServiceDisabledFailure extends Failure {
  const GpsServiceDisabledFailure() : super(message: "GPS service is disabled");
}

class LocationPermissionDeniedFailure extends Failure {
  final bool isPermanentlyDenied;
  const LocationPermissionDeniedFailure({required this.isPermanentlyDenied})
    : super(
        message: isPermanentlyDenied
            ? "Location permission permanently denied"
            : "Location permission denied",
      );
}

class NotificationFailure extends Failure {
  const NotificationFailure({required super.message, super.code});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

class MapFailure extends Failure {
  const MapFailure({required super.message});
}
