import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_core/data/datasources/local/theme_local_datasource.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeLocalDatasource _localDatasource;

  ThemeBloc(this._localDatasource)
    : super(const ThemeState(themeMode: ThemeMode.light)) {
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
    on<LoadTheme>(_onLoadTheme);
    add(LoadTheme());
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    await _safeExecute(emit, () async {
      final themeMode = await _localDatasource.getThemeMode();
      _emitTheme(emit, themeMode);
    }, errorMessage: 'Error loading theme');
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) async {
    await _safeExecute(emit, () async {
      final newThemeMode = _getToggledThemeMode();
      await _updateTheme(newThemeMode, emit);
    }, errorMessage: 'Error toggling theme');
  }

  Future<void> _onSetTheme(SetTheme event, Emitter<ThemeState> emit) async {
    await _safeExecute(
      emit,
      () => _updateTheme(event.themeMode, emit),
      errorMessage: 'Error setting theme',
    );
  }

  // Emit chung cho theme
  void _emitTheme(Emitter<ThemeState> emit, ThemeMode themeMode) {
    emit(state.copyWith(themeMode: themeMode));
  }

  // Helper method để toggle theme mode
  ThemeMode _getToggledThemeMode() {
    return state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  // Update theme với save và emit
  Future<void> _updateTheme(
    ThemeMode themeMode,
    Emitter<ThemeState> emit,
  ) async {
    await _localDatasource.saveThemeMode(themeMode);
    _emitTheme(emit, themeMode);
  }

  // Wrapper chung cho error handling
  Future<void> _safeExecute(
    Emitter<ThemeState> emit,
    Future<void> Function() action, {
    required String errorMessage,
  }) async {
    try {
      await action();
    } catch (e) {
      debugPrint('$errorMessage: $e');
      // Có thể emit error state ở đây nếu cần
      // _emitError(emit, e.toString());
    }
  }
}
