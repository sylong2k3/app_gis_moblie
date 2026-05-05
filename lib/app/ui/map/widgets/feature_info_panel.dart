import 'package:app_core/domain/entities/map_feature.dart';
import 'package:flutter/material.dart';

class FeatureInfoPanel extends StatelessWidget {
  final MapFeature feature;
  final VoidCallback onClose;

  const FeatureInfoPanel({
    super.key,
    required this.feature,
    required this.onClose,
  });

  IconData _getFeatureIcon(FeatureType type) {
    switch (type) {
      case FeatureType.point:
        return Icons.place;
      case FeatureType.lineString:
        return Icons.timeline;
      case FeatureType.polygon:
        return Icons.pentagon_outlined;
    }
  }

  String _getFeatureTypeLabel(FeatureType type) {
    switch (type) {
      case FeatureType.point:
        return 'Điểm';
      case FeatureType.lineString:
        return 'Đường';
      case FeatureType.polygon:
        return 'Vùng';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getFeatureIcon(feature.type),
                    color: Colors.blue[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getFeatureTypeLabel(feature.type),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (feature.description != null) ...[
                  const Text(
                    'Mô tả',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Coordinates Info
                const Text(
                  'Thông tin tọa độ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Số điểm',
                  '${feature.coordinates.length}',
                  Icons.pin_drop,
                ),
                if (feature.coordinates.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Vĩ độ',
                    feature.coordinates.first.latitude.toStringAsFixed(6),
                    Icons.explore,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Kinh độ',
                    feature.coordinates.first.longitude.toStringAsFixed(6),
                    Icons.explore,
                  ),
                ],

                // Properties
                if (feature.properties.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Thuộc tính',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...feature.properties.entries
                      .where((e) => e.key != 'layerId')
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildInfoRow(
                            entry.key,
                            entry.value.toString(),
                            Icons.info_outline,
                          ),
                        ),
                      ),
                ],

                // Timestamps
                if (feature.createdAt != null || feature.updatedAt != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Thời gian',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (feature.createdAt != null)
                    _buildInfoRow(
                      'Tạo lúc',
                      _formatDate(feature.createdAt!),
                      Icons.access_time,
                    ),
                  if (feature.updatedAt != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Cập nhật',
                      _formatDate(feature.updatedAt!),
                      Icons.update,
                    ),
                  ],
                ],
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement edit
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chức năng sửa đang phát triển'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Sửa'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement delete
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: Text(
                            'Bạn có chắc muốn xóa "${feature.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onClose();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã xóa')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Xóa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
