// lib/data/models/user_profile_model.dart

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_role.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.email,
    super.phone,
    super.fullName,
    super.avatarUrl,
    super.role,
    super.ssoProvider,
    super.ssoUid,
    super.dateOfBirth,
    super.gender,
    super.nationality,
    super.preferredLanguage,
    super.preferredCurrency,
    super.preferredDistance,
    super.isActive,
    super.isVerified,
    super.twoFactorEnabled,
    super.lastLoginAt,
    super.fcmToken,
    super.apnsToken,
    super.deviceOs,
    super.appVersion,
    super.createdAt,
    super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    UserRole? role;
    final dynamic roleValue = json['role'];
    if (roleValue is Map<String, dynamic>) {
      role = UserRole.fromJson(roleValue);
    }

    return UserProfileModel(
      id: (json['id'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: role,
      ssoProvider: json['sso_provider'] as String?,
      ssoUid: json['sso_uid'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      nationality: json['nationality'] as String?,
      preferredLanguage: (json['preferred_language'] as String?) ?? 'vi',
      preferredCurrency: (json['preferred_currency'] as String?) ?? 'VND',
      preferredDistance: (json['preferred_distance'] as String?) ?? 'km',
      isActive: (json['is_active'] as bool?) ?? true,
      isVerified: (json['is_verified'] as bool?) ?? false,
      twoFactorEnabled: (json['two_factor_enabled'] as bool?) ?? false,
      lastLoginAt: json['last_login_at'] as String?,
      fcmToken: json['fcm_token'] as String?,
      apnsToken: json['apns_token'] as String?,
      deviceOs: json['device_os'] as String?,
      appVersion: json['app_version'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'phone': phone,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'role': role?.toJson(),
    'sso_provider': ssoProvider,
    'sso_uid': ssoUid,
    'date_of_birth': dateOfBirth,
    'gender': gender,
    'nationality': nationality,
    'preferred_language': preferredLanguage,
    'preferred_currency': preferredCurrency,
    'preferred_distance': preferredDistance,
    'is_active': isActive,
    'is_verified': isVerified,
    'two_factor_enabled': twoFactorEnabled,
    'last_login_at': lastLoginAt,
    'fcm_token': fcmToken,
    'apns_token': apnsToken,
    'device_os': deviceOs,
    'app_version': appVersion,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
