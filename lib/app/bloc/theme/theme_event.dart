part of 'theme_bloc.dart';

sealed class ThemeEvent {
  const ThemeEvent();
}

final class LoadTheme extends ThemeEvent {
  const LoadTheme();
}

final class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
}

final class SetTheme extends ThemeEvent {
  final ThemeMode themeMode;
  
  const SetTheme(this.themeMode);
}