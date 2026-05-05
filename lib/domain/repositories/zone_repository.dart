import 'package:app_core/domain/entities/zone_entity.dart';

abstract class ZoneRepository {
  Future<List<ZoneEntity>> getZones();

  Future<ZoneEntity> getZoneDetail(String zoneId);

  Future<ZoneEntity> createZone(String name);

  Future<ZoneEntity> updateZone(String zoneId, String name);

  Future<ZoneEntity> updateZoneConfig(
    String zoneId,
    Map<String, dynamic> config,
  );

  Future<void> deleteZone(String zoneId);

  Future<void> inviteZoneMember({
    required String zoneId,
    required String email,
    required String role,
  });
}
