import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String location;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double pressure;
  final double visibility;
  final double uvIndex;

  const Weather({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
  });

  @override
  List<Object?> get props => [
    location,
    temperature,
    feelsLike,
    humidity,
    windSpeed,
    description,
    icon,
    latitude,
    longitude,
    timestamp,
    pressure,
    visibility,
    uvIndex,
  ];
}
