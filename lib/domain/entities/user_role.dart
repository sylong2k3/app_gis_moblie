// lib/domain/entities/user_role.dart

class UserRole {
  final int id;
  final String code;
  final String nameVi;
  final String? nameEn;
  final String? description;

  const UserRole({
    required this.id,
    required this.code,
    required this.nameVi,
    this.nameEn,
    this.description,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: (json['code'] as String?) ?? '',
      nameVi: (json['name_vi'] as String?) ?? (json['name'] as String?) ?? '',
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name_vi': nameVi,
    'name_en': nameEn,
    'description': description,
  };
}
