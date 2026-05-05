import 'package:equatable/equatable.dart';

abstract class NavbarState extends Equatable {
  const NavbarState();

  @override
  List<Object> get props => [];
}

class NavbarInitial extends NavbarState {}

class NavbarTabChanged extends NavbarState {
  final int selectedIndex;

  const NavbarTabChanged({required this.selectedIndex});

  @override
  List<Object> get props => [selectedIndex];
}
