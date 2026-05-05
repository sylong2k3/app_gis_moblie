import 'package:flutter/material.dart';
import 'package:app_core/domain/entities/map_layer_detail.dart';
import 'package:app_core/app/ui/map/sheet_header.dart';

/// Bottom sheet to display feature information when tapped
class FeatureInfoSheet extends StatelessWidget {
  final MapLayerDetail feature;

  const FeatureInfoSheet({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(onClose: () => Navigator.pop(context)),
          Padding(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 16),
                _buildInfoRow('ID', feature.id),
                _buildInfoRow('Category', feature.categoryId),
                _buildInfoRow('Loại', feature.geometryType),
                if (_getArea(feature) != null)
                  _buildInfoRow(
                    'Diện tích',
                    '${_getArea(feature)!.toStringAsFixed(2)} m²',
                  ),
                _buildInfoRow('Tạo bởi', 'User #${feature.createdBy}'),
                _buildInfoRow('Ngày tạo', _formatDate(feature.createdAt)),
                _buildInfoRow('Cập nhật', _formatDate(feature.updatedAt)),
                // Show additional properties if available
                if (feature.properties.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Thông tin bổ sung',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._buildPropertiesRows(feature.properties),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  double? _getArea(MapLayerDetail feature) {
    // Try to get area from properties first
    if (feature.properties.containsKey('area')) {
      final area = feature.properties['area'];
      if (area is num) return area.toDouble();
      if (area is String) return double.tryParse(area);
    }

    // Could calculate from geometry if needed
    // For now, return null if not in properties
    return null;
  }

  List<Widget> _buildPropertiesRows(Map<String, dynamic> properties) {
    final rows = <Widget>[];

    // Filter out common properties already shown
    final filteredProps = Map<String, dynamic>.from(properties);
    filteredProps.removeWhere(
      (key, value) =>
          key == 'id' ||
          key == 'name' ||
          key == 'category_id' ||
          key == 'is_active' ||
          key == 'created_by' ||
          key == 'created_at' ||
          key == 'updated_at' ||
          key == 'multi_part',
    );

    for (final entry in filteredProps.entries) {
      final value = entry.value?.toString() ?? 'N/A';
      rows.add(_buildInfoRow(entry.key, value));
    }

    return rows;
  }
}

/// Helper function to show feature info sheet
void showFeatureInfoSheet(BuildContext context, MapLayerDetail feature) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => FeatureInfoSheet(feature: feature),
  );
}
