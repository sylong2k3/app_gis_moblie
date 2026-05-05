import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService _apiService;

  WeatherRepositoryImpl(this._apiService);

  @override
  Future<Weather> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final weatherModel = await _apiService.getWeatherByCoordinates(
        latitude: latitude,
        longitude: longitude,
      );
      return _mapModelToEntity(weatherModel);
    } catch (e) {
      throw Exception('Failed to get weather data: $e');
    }
  }

  @override
  Future<Weather> getWeatherByCity(String cityName) async {
    try {
      final weatherModel = await _apiService.getWeatherByCity(
        cityName: cityName,
      );
      return _mapModelToEntity(weatherModel);
    } catch (e) {
      throw Exception('Failed to get weather data: $e');
    }
  }

  Weather _mapModelToEntity(WeatherModel model) {
    return Weather(
      location: model.name,
      temperature: model.main.temp,
      feelsLike: model.main.feelsLike,
      humidity: model.main.humidity,
      windSpeed: model.wind.speed,
      description: model.weather.isNotEmpty
          ? model.weather.first.description
          : '',
      icon: model.weather.isNotEmpty ? model.weather.first.icon : '',
      latitude: model.coord.lat,
      longitude: model.coord.lon,
      timestamp: DateTime.fromMillisecondsSinceEpoch(model.dt * 1000),
      pressure: model.main.pressure,
      visibility: model.visibility / 1000, // Convert to km
      uvIndex:
          0.0, // OpenWeather free tier doesn't include UV index in current weather
    );
  }
}
