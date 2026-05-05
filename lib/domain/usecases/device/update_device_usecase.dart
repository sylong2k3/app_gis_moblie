import '../../entities/device_entity.dart';
import '../../repositories/device_repository.dart';

class UpdateDeviceUsecase {
  final DeviceRepository repository;

  UpdateDeviceUsecase(this.repository);

  Future<DeviceEntity> call(String zoneId, String deviceId, String name) {
    return repository.updateDevice(zoneId, deviceId, name);
  }
}
