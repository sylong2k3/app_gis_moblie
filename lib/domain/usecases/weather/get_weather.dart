import 'package:dartz/dartz.dart';
import '../../entities/weather.dart';
import '../../repositories/weather_repository.dart';
import '../../../shared/error/failures.dart';

class GetWeatherByCoordinates {
  final WeatherRepository repository;

  GetWeatherByCoordinates(this.repository);

  Future<Either<Failure, Weather>> call(GetWeatherParams params) async {
    try {
      final weather = await repository.getWeatherByCoordinates(
        params.latitude,
        params.longitude,
      );
      return Right(weather);
    } catch (e) {
      return Left(ServerFailure('Failed to get weather data: $e'));
    }
  }
}

class GetWeatherByCity {
  final WeatherRepository repository;

  GetWeatherByCity(this.repository);

  Future<Either<Failure, Weather>> call(String cityName) async {
    try {
      final weather = await repository.getWeatherByCity(cityName);
      return Right(weather);
    } catch (e) {
      return Left(ServerFailure('Failed to get weather data: $e'));
    }
  }
}

class GetWeatherParams {
  final double latitude;
  final double longitude;

  GetWeatherParams({required this.latitude, required this.longitude});
}
