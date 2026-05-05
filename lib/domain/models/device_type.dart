import 'package:equatable/equatable.dart';

class DeviceType extends Equatable {
  final String id;
  final String name;
  final String? imagePath;

  const DeviceType({required this.id, required this.name, this.imagePath});

  @override
  List<Object?> get props => [id, name, imagePath];
}
