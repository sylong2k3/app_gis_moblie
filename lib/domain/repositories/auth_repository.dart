// lib/domain/repositories/auth_repository.dart
import 'package:app_core/domain/entities/auth_user.dart';
import 'package:app_core/domain/entities/user_profile_entity.dart';
import 'package:app_core/shared/utils/either.dart';

abstract class AuthRepository {
  ResultFutureVoid register({required String email, required String password});

  ResultFutureVoid confirmEmail({required String email, required String code});

  ResultFuture<AuthUser> signIn({
    required String email,
    required String password,
  });

  ResultFuture<AuthUser?> getCurrentUser();

  ResultFutureVoid refreshSession();

  Future<bool> isAuthenticated();

  ResultFutureVoid resetPassword({required String email});

  ResultFutureVoid confirmResetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  ResultFutureVoid changePassword({
    required String oldPassword,
    required String newPassword,
  });

  ResultFutureVoid resendConfirmationCode({required String email});

  ResultFutureVoid signOut();

  ResultFutureVoid deleteAccount();

  ResultFuture<UserProfileEntity> getUserProfile();

  Future<String?> getValidIdToken();
}
