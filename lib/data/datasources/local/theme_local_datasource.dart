import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_core/shared/constants/shared_preferences_key.dart';

class ThemeLocalDatasource {
  final SharedPreferences sharedPreferences;

  ThemeLocalDatasource(this.sharedPreferences);

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await sharedPreferences.setString(
      SharedPreferencesKey.keyThemeMode,
      themeMode.name,
    );
  }

  Future<ThemeMode> getThemeMode() async {
    final themeModeStr = sharedPreferences.getString(
      SharedPreferencesKey.keyThemeMode,
    );
    if (themeModeStr == null) return ThemeMode.light;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == themeModeStr,
      orElse: () => ThemeMode.light,
    );
  }
}
