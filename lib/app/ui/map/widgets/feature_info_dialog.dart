import 'dart:io';

import 'package:app_core/domain/entities/map_layer_detail.dart';
import 'package:app_core/domain/entities/user_profile_entity.dart';
import 'package:app_core/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_core/app/bloc/map/map_cubit.dart';
import 'package:app_core/app/bloc/auth/auth_bloc.dart';
import 'package:dio/dio.dart';
import 'package:app_core/data/datasources/local/auth_local_datasource.dart';
import 'package:app_core/data/datasources/local/map_layer_update_queue_local_datasource.dart';
import 'package:app_core/di/injection_container.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:uuid/uuid.dart';

enum _CoordinateInputMode { manual, gps }

class FeatureInfoDialog extends StatefulWidget {
  final MapLayerDetail feature;

  const FeatureInfoDialog({super.key, required this.feature});

  @override
  State<FeatureInfoDialog> createState() => _FeatureInfoDialogState();
}

class _FeatureInfoDialogState extends State<FeatureInfoDialog> {
  UserProfileEntity? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final authRepository = context.read<AuthBloc>().authRepository;
      final result = await authRepository.getUserProfile();
      result.fold((_) => null, (profile) {
        if (mounted) {
          setState(() {
            _userProfile = profile;
          });
        }
      });
    }
  }

  bool get _canEdit {
    // Only admin can edit
    final role = _userProfile?.role.toLowerCase() ?? '';
    return role == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.feature.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPropertyItem('ID', widget.feature.id),
                    _buildPropertyItem('Category', widget.feature.categoryId),
                    _buildPropertyItem('Loại', widget.feature.geometryType),
                    if (_getArea(widget.feature) != null)
                      _buildPropertyItem(
                        'Diện tích',
                        '${_getArea(widget.feature)!.toStringAsFixed(2)} m²',
                      ),
                    _buildPropertyItem(
                      'Tạo bởi',
                      'User #${widget.feature.createdBy}',
                    ),
                    _buildPropertyItem(
                      'Ngày tạo',
                      _formatDate(widget.feature.createdAt),
                    ),
                    _buildPropertyItem(
                      'Cập nhật',
                      _formatDate(widget.feature.updatedAt),
                    ),

                    if (widget.feature.properties.isNotEmpty) ...[
                      const Divider(height: 24),
                      const Text(
                        'Thông tin bổ sung',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildAdditionalProperties(),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Only show edit button for admin users
                  if (_canEdit) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditDialog(context);
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Chỉnh sửa'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: AppColors.primaryDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Đóng',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _getArea(MapLayerDetail feature) {
    if (feature.properties.containsKey('area')) {
      final area = feature.properties['area'];
      if (area is num) return area.toDouble();
      if (area is String) return double.tryParse(area);
    }
    return null;
  }

  List<Widget> _buildAdditionalProperties() {
    final widgets = <Widget>[];
    final filteredProps = Map<String, dynamic>.from(widget.feature.properties);
    filteredProps.removeWhere(
      (key, value) =>
          key == 'id' ||
          key == 'name' ||
          key == 'category_id' ||
          key == 'is_active' ||
          key == 'created_by' ||
          key == 'created_at' ||
          key == 'updated_at' ||
          key == 'multi_part' ||
          key == 'image',
    );

    for (final entry in filteredProps.entries) {
      final value = entry.value?.toString();
      if (value != null && value.isNotEmpty) {
        widgets.add(_buildPropertyItem(_formatKey(entry.key), value));
      }
    }
    return widgets;
  }

  Widget _buildPropertyItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditFeatureDialog(feature: widget.feature),
    );
  }
}

/// Dialog for editing feature
class EditFeatureDialog extends StatefulWidget {
  final MapLayerDetail feature;

  const EditFeatureDialog({super.key, required this.feature});

  @override
  State<EditFeatureDialog> createState() => _EditFeatureDialogState();
}

class _EditFeatureDialogState extends State<EditFeatureDialog> {
  static const _uuid = Uuid();
  late TextEditingController _nameController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late Map<String, TextEditingController> _propertyControllers;
  bool _isActive = true;
  bool _isLoading = false;
  bool _canEditCoordinates = false;
  bool _isGettingGps = false;
  _CoordinateInputMode _coordinateInputMode = _CoordinateInputMode.manual;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.feature.name);
    _isActive = widget.feature.isActive;

    final initialCoordinate = _extractPrimaryCoordinate(
      widget.feature.geometryData,
    );
    _latitudeController = TextEditingController(
      text: initialCoordinate?['lat']?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: initialCoordinate?['lng']?.toString() ?? '',
    );
    _canEditCoordinates = initialCoordinate != null;

    // Initialize controllers for ALL properties from API response
    _propertyControllers = {};

    // Filter out system fields that shouldn't be edited
    final systemFields = {
      'id',
      'category_id',
      'created_by',
      'created_at',
      'updated_at',
      'multi_part',
      'image',
    };

    for (final entry in widget.feature.properties.entries) {
      if (!systemFields.contains(entry.key)) {
        _propertyControllers[entry.key] = TextEditingController(
          text: entry.value?.toString() ?? '',
        );
      }
    }
  }

  Future<void> _fillCoordinatesFromGps() async {
    if (_isGettingGps) return;

    setState(() => _isGettingGps = true);

    try {
      final isServiceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng bật dịch vụ định vị (GPS)'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }

      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có quyền truy cập vị trí'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(7);
        _longitudeController.text = position.longitude.toStringAsFixed(7);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lấy tọa độ GPS, vui lòng thử lại'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGettingGps = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    for (final controller in _propertyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên lớp'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final latitudeText = _latitudeController.text.trim();
    final longitudeText = _longitudeController.text.trim();

    double? latitude;
    double? longitude;

    if (_canEditCoordinates) {
      latitude = double.tryParse(latitudeText);
      longitude = double.tryParse(longitudeText);

      if (latitude == null || longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập đúng định dạng Latitude/Longitude'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (latitude < -90 || latitude > 90) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Latitude phải trong khoảng từ -90 đến 90'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (longitude < -180 || longitude > 180) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Longitude phải trong khoảng từ -180 đến 180'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Build properties object from ALL property controllers
      final properties = <String, dynamic>{};
      for (final entry in _propertyControllers.entries) {
        final value = entry.value.text.trim();
        if (value.isNotEmpty) {
          // Try to parse as number if possible
          final numValue = num.tryParse(value);
          properties[entry.key] = numValue ?? value;
        } else {
          // Keep empty values as empty strings
          properties[entry.key] = '';
        }
      }

      // Prepare update data
      final updateData = {
        'name': _nameController.text.trim(),
        'geometry_type': widget.feature.geometryType,
        'geometry_data': _formatGeometryForAPI(
          widget.feature.geometryData,
          latitude: latitude,
          longitude: longitude,
        ),
        'properties': properties,
        'is_active': _isActive,
      };

      await _syncPendingUpdates();

      // Call API
      final dio = sl<Dio>();
      final authDataSource = sl<AuthLocalDatasource>();
      final token = await authDataSource.getAccessToken();

      if (token == null) {
        throw Exception('Vui lòng đăng nhập');
      }

      final response = await dio.put(
        'http://103.163.119.247:8881/api/v1/map-layers/${widget.feature.id}',
        data: updateData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload layer features
        final categoryId = int.tryParse(widget.feature.categoryId);
        if (categoryId != null) {
          context.read<MapCubit>().loadLayerFeatures(categoryId);
        }
      }
    } on DioException catch (e) {
      if (!mounted) return;

      if (_isOfflineError(e)) {
        await _saveUpdateOffline(
          updateData: {
            'name': _nameController.text.trim(),
            'geometry_type': widget.feature.geometryType,
            'geometry_data': _formatGeometryForAPI(
              widget.feature.geometryData,
              latitude: latitude,
              longitude: longitude,
            ),
            'properties': {
              for (final entry in _propertyControllers.entries)
                entry.key:
                    (num.tryParse(entry.value.text.trim()) ??
                    entry.value.text.trim()),
            },
            'is_active': _isActive,
          },
        );

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không có mạng. Dữ liệu đã lưu offline và sẽ tự đồng bộ khi có mạng.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      String errorMessage = 'Không thể cập nhật';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isOfflineError(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    if (error.error is SocketException) {
      return true;
    }

    return false;
  }

  Future<void> _saveUpdateOffline({
    required Map<String, dynamic> updateData,
  }) async {
    final queueDataSource = sl<MapLayerUpdateQueueLocalDataSource>();
    await queueDataSource.enqueue(
      queueId: _uuid.v4(),
      layerId: widget.feature.id,
      payload: updateData,
    );
  }

  Future<void> _syncPendingUpdates() async {
    final queueDataSource = sl<MapLayerUpdateQueueLocalDataSource>();
    final pendingItems = await queueDataSource.getAll();
    if (pendingItems.isEmpty) {
      return;
    }

    final authDataSource = sl<AuthLocalDatasource>();
    final token = await authDataSource.getAccessToken();
    if (token == null) {
      return;
    }

    final dio = sl<Dio>();

    for (final item in pendingItems) {
      try {
        final response = await dio.put(
          'http://103.163.119.247:8881/api/v1/map-layers/${item.layerId}',
          data: item.payload,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          await queueDataSource.remove(item.queueId);
        }
      } on DioException catch (e) {
        final errorMessage = e.message ?? 'sync_failed';
        await queueDataSource.markAttemptFailed(
          queueId: item.queueId,
          error: errorMessage,
        );

        if (_isOfflineError(e)) {
          break;
        }
      } catch (e) {
        await queueDataSource.markAttemptFailed(
          queueId: item.queueId,
          error: e.toString(),
        );
      }
    }
  }

  String _formatGeometryForAPI(
    Map<String, dynamic> geometryData, {
    double? latitude,
    double? longitude,
  }) {
    // Convert GeoJSON geometry to WKT format for API
    try {
      final type = geometryData['type']?.toString().toUpperCase() ?? 'POLYGON';
      final coords = _geometryWithUpdatedCoordinates(
        geometryData,
        latitude: latitude,
        longitude: longitude,
      )['coordinates'];

      if (coords is List && coords.isNotEmpty) {
        if (type == 'POLYGON') {
          final ring = coords[0] as List;
          final points = ring
              .map((coord) {
                final c = coord as List;
                return '${c[0]} ${c[1]}';
              })
              .join(',');
          return 'POLYGON(($points))';
        } else if (type == 'MULTIPOLYGON') {
          final polygons = coords;
          final polygonStrings = polygons
              .map((polygon) {
                final ring = polygon[0] as List;
                final points = ring
                    .map((coord) {
                      final c = coord as List;
                      return '${c[0]} ${c[1]}';
                    })
                    .join(',');
                return '(($points))';
              })
              .join(',');
          return 'MULTIPOLYGON($polygonStrings)';
        } else if (type == 'LINESTRING') {
          final points = coords
              .map((coord) {
                final c = coord as List;
                return '${c[0]} ${c[1]}';
              })
              .join(',');
          return 'LINESTRING($points)';
        } else if (type == 'POINT') {
          final c = coords;
          return 'POINT(${c[0]} ${c[1]})';
        }
      }

      return 'POINT(0 0)';
    } catch (e) {
      return 'POINT(0 0)';
    }
  }

  Map<String, dynamic> _geometryWithUpdatedCoordinates(
    Map<String, dynamic> geometryData, {
    double? latitude,
    double? longitude,
  }) {
    if (latitude == null || longitude == null) {
      return geometryData;
    }

    final type = (geometryData['type']?.toString().toUpperCase() ?? '');
    final coordinates = geometryData['coordinates'];

    if (type == 'POINT') {
      return {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      };
    }

    if (type == 'MULTIPOINT' &&
        coordinates is List &&
        coordinates.isNotEmpty &&
        coordinates.first is List) {
      final updatedCoordinates = List<dynamic>.from(coordinates);
      updatedCoordinates[0] = [longitude, latitude];
      return {'type': 'MultiPoint', 'coordinates': updatedCoordinates};
    }

    return geometryData;
  }

  Map<String, double>? _extractPrimaryCoordinate(
    Map<String, dynamic> geometryData,
  ) {
    final type = (geometryData['type']?.toString().toUpperCase() ?? '');
    final coordinates = geometryData['coordinates'];

    if (type == 'POINT' && coordinates is List && coordinates.length >= 2) {
      final lng = _toDouble(coordinates[0]);
      final lat = _toDouble(coordinates[1]);
      if (lat != null && lng != null) {
        return {'lat': lat, 'lng': lng};
      }
    }

    if (type == 'MULTIPOINT' &&
        coordinates is List &&
        coordinates.isNotEmpty &&
        coordinates.first is List) {
      final first = coordinates.first as List;
      if (first.length >= 2) {
        final lng = _toDouble(first[0]);
        final lat = _toDouble(first[1]);
        if (lat != null && lng != null) {
          return {'lat': lat, 'lng': lng};
        }
      }
    }

    return null;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chỉnh sửa lớp bản đồ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.fingerprint,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ID: ${widget.feature.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên lớp *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Latitude/Longitude (editable for Point/MultiPoint)
                    if (_canEditCoordinates) ...[
                      const Text(
                        'Nguồn tọa độ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<_CoordinateInputMode>(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: const Text('Nhập tọa độ'),
                              value: _CoordinateInputMode.manual,
                              groupValue: _coordinateInputMode,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _coordinateInputMode = value);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<_CoordinateInputMode>(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: const Text('Lấy từ GPS'),
                              value: _CoordinateInputMode.gps,
                              groupValue: _coordinateInputMode,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _coordinateInputMode = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_coordinateInputMode == _CoordinateInputMode.gps) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isGettingGps
                                ? null
                                : _fillCoordinatesFromGps,
                            icon: _isGettingGps
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.gps_fixed),
                            label: Text(
                              _isGettingGps
                                  ? 'Đang lấy tọa độ...'
                                  : 'Lấy tọa độ GPS hiện tại',
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _latitudeController,
                              readOnly:
                                  _coordinateInputMode ==
                                  _CoordinateInputMode.gps,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Vĩ độ *',
                                border: OutlineInputBorder(),
                                isDense: true,
                                prefixIcon: Icon(Icons.my_location),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _longitudeController,
                              readOnly:
                                  _coordinateInputMode ==
                                  _CoordinateInputMode.gps,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Kinh độ *',
                                border: OutlineInputBorder(),
                                isDense: true,
                                prefixIcon: Icon(Icons.explore),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Active status
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SwitchListTile(
                        title: const Text('Trạng thái hoạt động'),
                        subtitle: Text(
                          _isActive ? 'Đang hoạt động' : 'Không hoạt động',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isActive ? Colors.green : Colors.grey,
                          ),
                        ),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Properties - dynamically render all properties from API
                    const Text(
                      'Thuộc tính',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dynamically build text fields for all properties
                    ..._propertyControllers.entries.map((entry) {
                      return _buildPropertyField(
                        _formatPropertyLabel(entry.key),
                        entry.key,
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Lưu',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyField(String label, String key, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _propertyControllers[key],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        maxLines: maxLines,
      ),
    );
  }

  String _formatPropertyLabel(String key) {
    // Format property key to readable label
    final labelMap = {
      'xa': 'Xã',
      'maxa': 'Mã xã',
      'tinh': 'Tỉnh',
      'matinh': 'Mã tỉnh',
      'huyen': 'Huyện',
      'mahuyen': 'Mã huyện',
      'updated_by': 'Cập nhật bởi',
      'note': 'Ghi chú',
    };

    // Return mapped label or format the key
    return labelMap[key] ?? _formatKey(key);
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }
}
