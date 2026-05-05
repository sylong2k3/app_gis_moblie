import 'package:flutter_bloc/flutter_bloc.dart';
import 'navbar_event.dart';
import 'navbar_state.dart';

class NavbarCubit extends Bloc<NavbarEvent, NavbarState> {
  NavbarCubit() : super(const NavbarTabChanged(selectedIndex: 0)) {
    on<NavbarTabSelected>(_onTabSelected);
    on<NavbarReset>(_onReset);
  }

  void _onTabSelected(NavbarTabSelected event, Emitter<NavbarState> emit) {
    emit(NavbarTabChanged(selectedIndex: event.index));
  }

  void _onReset(NavbarReset event, Emitter<NavbarState> emit) {
    emit(const NavbarTabChanged(selectedIndex: 0));
  }

  void selectTab(int index) {
    add(NavbarTabSelected(index: index));
  }

  void resetToHome() {
    add(NavbarReset());
  }

  int get currentIndex {
    final currentState = state;
    if (currentState is NavbarTabChanged) {
      return currentState.selectedIndex;
    }
    return 0;
  }
}
