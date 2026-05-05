import '../../entities/device_entity.dart';
import '../../repositories/device_repository.dart';

class UpdateDeviceConfigUsecase {
  final DeviceRepository repository;

  UpdateDeviceConfigUsecase(this.repository);

  Future<DeviceEntity> call(
    String zoneId,
    String deviceId,
    Map<String, dynamic> config,
  ) {
    return repository.updateDeviceConfig(zoneId, deviceId, config);
  }
}
