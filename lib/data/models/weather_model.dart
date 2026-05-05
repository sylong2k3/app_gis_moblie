class WeatherModel {
  final String name;
  final MainData main;
  final List<WeatherDescription> weather;
  final WindData wind;
  final double visibility;
  final CoordData coord;
  final int dt;
  final SysData sys;

  WeatherModel({
    required this.name,
    required this.main,
    required this.weather,
    required this.wind,
    required this.visibility,
    required this.coord,
    required this.dt,
    required this.sys,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      name: json['name'] ?? '',
      main: MainData.fromJson(json['main'] ?? {}),
      weather:
          (json['weather'] as List<dynamic>?)
              ?.map((item) => WeatherDescription.fromJson(item))
              .toList() ??
          [],
      wind: WindData.fromJson(json['wind'] ?? {}),
      visibility: (json['visibility'] ?? 0).toDouble(),
      coord: CoordData.fromJson(json['coord'] ?? {}),
      dt: json['dt'] ?? 0,
      sys: SysData.fromJson(json['sys'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'main': main.toJson(),
      'weather': weather.map((item) => item.toJson()).toList(),
      'wind': wind.toJson(),
      'visibility': visibility,
      'coord': coord.toJson(),
      'dt': dt,
      'sys': sys.toJson(),
    };
  }
}

class MainData {
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final double pressure;
  final int humidity;

  MainData({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
  });

  factory MainData.fromJson(Map<String, dynamic> json) {
    return MainData(
      temp: (json['temp'] ?? 0).toDouble(),
      feelsLike: (json['feels_like'] ?? 0).toDouble(),
      tempMin: (json['temp_min'] ?? 0).toDouble(),
      tempMax: (json['temp_max'] ?? 0).toDouble(),
      pressure: (json['pressure'] ?? 0).toDouble(),
      humidity: json['humidity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'feels_like': feelsLike,
      'temp_min': tempMin,
      'temp_max': tempMax,
      'pressure': pressure,
      'humidity': humidity,
    };
  }
}

class WeatherDescription {
  final int id;
  final String main;
  final String description;
  final String icon;

  WeatherDescription({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherDescription.fromJson(Map<String, dynamic> json) {
    return WeatherDescription(
      id: json['id'] ?? 0,
      main: json['main'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'main': main, 'description': description, 'icon': icon};
  }
}

class WindData {
  final double speed;
  final int deg;

  WindData({required this.speed, required this.deg});

  factory WindData.fromJson(Map<String, dynamic> json) {
    return WindData(
      speed: (json['speed'] ?? 0).toDouble(),
      deg: json['deg'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'speed': speed, 'deg': deg};
  }
}

class CoordData {
  final double lon;
  final double lat;

  CoordData({required this.lon, required this.lat});

  factory CoordData.fromJson(Map<String, dynamic> json) {
    return CoordData(
      lon: (json['lon'] ?? 0).toDouble(),
      lat: (json['lat'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'lon': lon, 'lat': lat};
  }
}

class SysData {
  final String country;
  final int sunrise;
  final int sunset;

  SysData({required this.country, required this.sunrise, required this.sunset});

  factory SysData.fromJson(Map<String, dynamic> json) {
    return SysData(
      country: json['country'] ?? '',
      sunrise: json['sunrise'] ?? 0,
      sunset: json['sunset'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'country': country, 'sunrise': sunrise, 'sunset': sunset};
  }
}
