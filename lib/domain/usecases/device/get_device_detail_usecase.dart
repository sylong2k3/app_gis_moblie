import '../../entities/device_entity.dart';
import '../../repositories/device_repository.dart';

class GetDeviceDetailUsecase {
  final DeviceRepository repository;

  GetDeviceDetailUsecase(this.repository);

  Future<DeviceEntity> call(String zoneId, String deviceId) {
    return repository.getDeviceDetail(zoneId, deviceId);
  }
}
