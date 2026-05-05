import 'package:equatable/equatable.dart';

abstract class NavbarEvent extends Equatable {
  const NavbarEvent();

  @override
  List<Object> get props => [];
}

class NavbarTabSelected extends NavbarEvent {
  final int index;

  const NavbarTabSelected({required this.index});

  @override
  List<Object> get props => [index];
}

class NavbarReset extends NavbarEvent {}
