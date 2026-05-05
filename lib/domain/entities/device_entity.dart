import 'package:equatable/equatable.dart';
import 'package:app_core/domain/mixins/role_helpers.dart';

class DeviceEntity extends Equatable with RoleHelpers {
  final String deviceId;
  final String name;
  final String status;
  final bool isDefault;
  final Map<String, dynamic> config;
  @override
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeviceEntity({
    required this.deviceId,
    required this.name,
    required this.status,
    required this.isDefault,
    required this.config,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  /// ===== Business Helpers =====
  bool get isActive => status == 'ACTIVE';
  bool get isInactive => status == 'INACTIVE';

  @override
  List<Object?> get props => [
    deviceId,
    name,
    status,
    isDefault,
    config,
    role,
    createdAt,
    updatedAt,
  ];
}
