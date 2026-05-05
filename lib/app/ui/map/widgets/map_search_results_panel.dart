import 'package:app_core/app/bloc/map/map_cubit.dart';
import 'package:app_core/domain/entities/map_layer_search_result.dart';
import 'package:app_core/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MapSearchResultsPanel extends StatelessWidget {
  const MapSearchResultsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        if (state is MapSearching) {
          return _buildSearchingIndicator();
        }

        if (state is MapLayerSearchResults) {
          return _buildSearchResults(context, state.response);
        }

        if (state is MapError) {
          return _buildError(state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchingIndicator() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text('Đang tìm kiếm...', style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    MapLayerSearchResponse response,
  ) {
    if (response.results.isEmpty) {
      return _buildEmptyResults(response.keyword);
    }

    return Container(
      margin: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxHeight: 350),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - More compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.successDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        response.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${response.total} kết quả cho "${response.keyword}"',
                        style: TextStyle(
                          color: Colors.white.withAlpha(230),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    context.read<MapCubit>().clearSelection();
                  },
                ),
              ],
            ),
          ),
          // Results list - More compact
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: response.results.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 52),
              itemBuilder: (context, index) {
                final result = response.results[index];
                return _buildResultItem(context, result);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(BuildContext context, MapLayerSearchResult result) {
    IconData icon;
    Color iconColor;

    switch (result.geometryType.toLowerCase()) {
      case 'point':
        icon = Icons.place;
        iconColor = Colors.red;
        break;
      case 'line':
      case 'linestring':
        icon = Icons.timeline;
        iconColor = Colors.blue;
        break;
      case 'polygon':
        icon = Icons.crop_square;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.layers;
        iconColor = Colors.grey;
    }

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(50),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        result.name,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        result.geometryType.toUpperCase(),
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
      onTap: () {
        // Load layer detail and zoom to it
        context.read<MapCubit>().loadLayerDetail(result.id);
      },
    );
  }

  Widget _buildEmptyResults(String keyword) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Không tìm thấy kết quả',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Không có lớp bản đồ nào phù hợp với "$keyword"',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
