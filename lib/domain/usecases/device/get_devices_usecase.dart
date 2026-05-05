import '../../entities/device_entity.dart';
import '../../repositories/device_repository.dart';

class GetDevicesUsecase {
  final DeviceRepository repository;

  GetDevicesUsecase(this.repository);

  Future<List<DeviceEntity>> call(String zoneId) {
    return repository.getDevices(zoneId);
  }
}
