import '../../entities/device_entity.dart';
import '../../repositories/device_repository.dart';

class CreateDeviceUsecase {
  final DeviceRepository repository;

  CreateDeviceUsecase(this.repository);

  Future<DeviceEntity> call(String zoneId, String name, {String? deviceId}) {
    return repository.createDevice(zoneId, name, deviceId: deviceId);
  }
}
