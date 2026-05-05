import 'package:app_core/domain/enums/app_language.dart';

class ImagePath {
  static const String _baseFlagPath = 'assets/flags/';
  static const String _basePath = 'assets/images/';
  // static const String _baseAnimationsPath = 'assets/animations/';

  static const String logo = '${_basePath}logo.png';

  // static const String _baseAnimationPath = 'assets/animations/';
  static String flagByLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.vi:
        return '${_baseFlagPath}vn.png';
      case AppLanguage.en:
        return '${_baseFlagPath}gb.png';
    }
  }

  // Add more image paths as needed
  static const String iconWeather = '${_basePath}icon_weather.png';
  static const String iconBell = '${_basePath}icon_bell.png';
  static const String iconCompass = '${_basePath}icon_compass.png';
  static const String iconRoute = '${_basePath}icon_route.png';
  static const String iconSquare = '${_basePath}icon_square.png';
  static const String iconLayer = '${_basePath}icon_layers.png';
  static const String iconGps = '${_basePath}icon_location.png';
  static const String iconLocation = '${_basePath}location.png';
  static const String iconPause = '${_basePath}icon_pause.png';
}
