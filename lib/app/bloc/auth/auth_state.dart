// States

part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthUser user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthRegistrationPending extends AuthState {
  final String email;

  AuthRegistrationPending(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordSent extends AuthState {
  final String email;

  AuthResetPasswordSent(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthPasswordResetSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
