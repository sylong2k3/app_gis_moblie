import 'package:app_core/app/bloc/map/map_cubit.dart';
import 'package:app_core/domain/entities/map_layer.dart';
import 'package:app_core/shared/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LayerControlPanel extends StatelessWidget {
  final VoidCallback onClose;

  const LayerControlPanel({super.key, required this.onClose});

  // IconData _getLayerIcon(LayerType type) {
  //   switch (type) {
  //     case LayerType.point:
  //       return Icons.place;
  //     case LayerType.line:
  //       return Icons.timeline;
  //     case LayerType.polygon:
  //       return Icons.pentagon_outlined;
  //     case LayerType.raster:
  //       return Icons.image;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Quản lý lớp bản đồ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Layer List
          Expanded(
            child: BlocBuilder<MapCubit, MapState>(
              builder: (context, state) {
                if (state is MapLoading) {
                  return const Center(child: LoadingIndicator());
                }

                if (state is MapError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (state is MapLayersLoaded) {
                  if (state.layers.isEmpty) {
                    return const Center(child: Text('Không có lớp nào'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.layers.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final layer = state.layers[index];
                      return LayerTile(
                        layer: layer,
                        onToggle: () {
                          final mapCubit = context.read<MapCubit>();

                          // Toggle visibility first (updates UI immediately)
                          mapCubit.toggleLayer(layer.id.toString());

                          // Then load or clear features based on new state
                          if (!layer.isVisible) {
                            // Was OFF, now turning ON
                            mapCubit.loadLayerFeatures(layer.id);
                          } else {
                            // Was ON, now turning OFF
                            mapCubit.clearLayerFeatures(layer.id);
                          }
                        },
                      );
                    },
                  );
                }

                return const Center(child: Text('Chưa có dữ liệu lớp'));
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<MapCubit>().loadLayers();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LayerTile extends StatelessWidget {
  final MapLayer layer;
  final VoidCallback onToggle;

  const LayerTile({super.key, required this.layer, required this.onToggle});

  IconData _getLayerIcon(LayerType type) {
    switch (type) {
      case LayerType.point:
        return Icons.place;
      case LayerType.line:
        return Icons.timeline;
      case LayerType.polygon:
        return Icons.pentagon_outlined;
      case LayerType.raster:
        return Icons.image;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: layer.type != null
          ? Icon(
              _getLayerIcon(layer.type!),
              color: layer.isVisible ? Colors.blue : Colors.grey,
            )
          : Icon(
              Icons.layers,
              color: layer.isVisible ? Colors.blue : Colors.grey,
            ),
      title: Text(
        layer.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: layer.isVisible ? Colors.black87 : Colors.grey,
        ),
      ),
      subtitle: layer.description != null
          ? Text(
              layer.description!,
              style: TextStyle(
                fontSize: 12,
                color: layer.isVisible ? Colors.black54 : Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active status indicator
          if (layer.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Hoạt động',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
          // Visibility toggle
          Switch(
            value: layer.isVisible,
            onChanged: (_) => onToggle(),
            activeThumbColor: Colors.blue[700],
          ),
        ],
      ),
      onTap: onToggle,
    );
  }
}
