import '../entities/weather.dart';

abstract class WeatherRepository {
  Future<Weather> getWeatherByCoordinates(double latitude, double longitude);
  Future<Weather> getWeatherByCity(String cityName);
}
