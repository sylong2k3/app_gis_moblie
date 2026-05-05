import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_core/app/bloc/locale/locale_event.dart';
import 'package:app_core/app/bloc/locale/locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(const LocaleState(Locale('vi'))) {
    on<ChangeLocale>(_onChangeLocale);
  }

  void _onChangeLocale(ChangeLocale event, Emitter<LocaleState> emit) {
    emit(LocaleState(event.locale));
  }
}
