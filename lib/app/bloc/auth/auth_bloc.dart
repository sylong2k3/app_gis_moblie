// lib/presentation/blocs/auth/auth_bloc.dart
import 'package:app_core/domain/entities/auth_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_core/domain/repositories/auth_repository.dart';
import 'package:app_core/shared/utils/logger.dart';
import 'package:equatable/equatable.dart';
part 'auth_event.dart';
part 'auth_state.dart';

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthConfirmEmailRequested>(_onConfirmEmailRequested);
    on<AuthResendCodeRequested>(_onResendCodeRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthConfirmResetPasswordRequested>(_onConfirmResetPasswordRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Checking current user authentication');
    emit(AuthLoading());
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) {
        AppLogger.info('No authenticated user found');
        emit(AuthUnauthenticated());
      },
      (user) {
        if (user != null) {
          AppLogger.info('User authenticated: ${user.email}');
          emit(AuthAuthenticated(user));
        } else {
          AppLogger.info('No authenticated user found');
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Attempting to sign in user: ${event.email}');
    emit(AuthLoading());
    final result = await authRepository.signIn(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) {
        AppLogger.error(
          'Sign in failed for ${event.email}: ${failure.message}',
        );
        emit(AuthError(failure.message));
      },
      (user) {
        AppLogger.info('Sign in successful for ${event.email}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.register(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthRegistrationPending(event.email)),
    );
  }

  Future<void> _onConfirmEmailRequested(
    AuthConfirmEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.confirmEmail(
      email: event.email,
      code: event.code,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onResendCodeRequested(
    AuthResendCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.resendConfirmationCode(
      email: event.email,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {}, // Keep current state
    );
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.resetPassword(email: event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthResetPasswordSent(event.email)),
    );
  }

  Future<void> _onConfirmResetPasswordRequested(
    AuthConfirmResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.confirmResetPassword(
      email: event.email,
      code: event.code,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthPasswordResetSuccess()),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.signOut();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onRefreshRequested(
    AuthRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.refreshSession();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {}, // Keep current state
    );
  }
}
