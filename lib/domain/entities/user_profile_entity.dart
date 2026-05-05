// lib/domain/entities/user_profile_entity.dart

import 'user_role.dart';

class UserProfileEntity {
  final String id;
  final String email;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;
  final UserRole? role;

  // SSO
  final String? ssoProvider;
  final String? ssoUid;

  // Personal info
  final String? dateOfBirth;
  final String? gender;
  final String? nationality;

  // Preferences
  final String preferredLanguage;
  final String preferredCurrency;
  final String preferredDistance;

  // Status
  final bool isActive;
  final bool isVerified;
  final bool twoFactorEnabled;

  // Device / session
  final String? lastLoginAt;
  final String? fcmToken;
  final String? apnsToken;
  final String? deviceOs;
  final String? appVersion;

  // Timestamps
  final String? createdAt;
  final String? updatedAt;

  const UserProfileEntity({
    required this.id,
    required this.email,
    this.phone,
    this.fullName,
    this.avatarUrl,
    this.role,
    this.ssoProvider,
    this.ssoUid,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.preferredLanguage = 'vi',
    this.preferredCurrency = 'VND',
    this.preferredDistance = 'km',
    this.isActive = true,
    this.isVerified = false,
    this.twoFactorEnabled = false,
    this.lastLoginAt,
    this.fcmToken,
    this.apnsToken,
    this.deviceOs,
    this.appVersion,
    this.createdAt,
    this.updatedAt,
  });
}
