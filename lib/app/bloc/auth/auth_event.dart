part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;

  AuthRegisterRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthConfirmEmailRequested extends AuthEvent {
  final String email;
  final String code;

  AuthConfirmEmailRequested(this.email, this.code);

  @override
  List<Object?> get props => [email, code];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthRefreshRequested extends AuthEvent {}

class AuthResendCodeRequested extends AuthEvent {
  final String email;

  AuthResendCodeRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  AuthResetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthConfirmResetPasswordRequested extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;

  AuthConfirmResetPasswordRequested({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}
