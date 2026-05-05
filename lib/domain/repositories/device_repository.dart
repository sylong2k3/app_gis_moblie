import 'package:app_core/domain/entities/device_entity.dart';

abstract class DeviceRepository {
  Future<List<DeviceEntity>> getDevices(String zoneId);

  Future<DeviceEntity> getDeviceDetail(String zoneId, String deviceId);

  Future<DeviceEntity> createDevice(
    String zoneId,
    String name, {
    String? deviceId,
  });

  Future<DeviceEntity> updateDevice(
    String zoneId,
    String deviceId,
    String name,
  );

  Future<DeviceEntity> updateDeviceConfig(
    String zoneId,
    String deviceId,
    Map<String, dynamic> config,
  );

  Future<void> deleteDevice(String zoneId, String deviceId);
}
