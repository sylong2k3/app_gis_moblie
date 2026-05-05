import 'package:app_core/domain/entities/weather.dart';
import 'package:app_core/domain/usecases/weather/get_weather.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final GetWeatherByCoordinates _getWeatherByCoordinates;
  final GetWeatherByCity _getWeatherByCity;

  WeatherCubit({
    required GetWeatherByCoordinates getWeatherByCoordinates,
    required GetWeatherByCity getWeatherByCity,
  }) : _getWeatherByCoordinates = getWeatherByCoordinates,
       _getWeatherByCity = getWeatherByCity,
       super(WeatherInitial());

  Future<void> getWeatherByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    emit(WeatherLoading());

    final result = await _getWeatherByCoordinates(
      GetWeatherParams(latitude: latitude, longitude: longitude),
    );

    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (weather) => emit(WeatherLoaded(weather)),
    );
  }

  Future<void> getWeatherByCity(String cityName) async {
    emit(WeatherLoading());

    final result = await _getWeatherByCity(cityName);

    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (weather) => emit(WeatherLoaded(weather)),
    );
  }

  void clearWeather() {
    emit(WeatherInitial());
  }
}
