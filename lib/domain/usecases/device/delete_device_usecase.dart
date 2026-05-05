import '../../repositories/device_repository.dart';

class DeleteDeviceUsecase {
  final DeviceRepository repository;

  DeleteDeviceUsecase(this.repository);

  Future<void> call(String zoneId, String deviceId) {
    return repository.deleteDevice(zoneId, deviceId);
  }
}
