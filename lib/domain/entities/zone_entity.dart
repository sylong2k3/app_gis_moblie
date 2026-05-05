import 'package:app_core/domain/enums/zone_status.dart';
import 'package:equatable/equatable.dart';
import 'package:app_core/domain/mixins/role_helpers.dart';

class ZoneEntity extends Equatable with RoleHelpers {
  final String zoneId;
  final String name;
  final bool isDefault;
  final Map<String, dynamic> config;
  @override
  final String role;
  final ZoneStatus status;
  final int deviceCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ZoneEntity({
    required this.zoneId,
    required this.name,
    required this.isDefault,
    required this.config,
    required this.role,
    required this.status,
    this.deviceCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    zoneId,
    name,
    isDefault,
    config,
    role,
    status,
    deviceCount,
    createdAt,
    updatedAt,
  ];
}
