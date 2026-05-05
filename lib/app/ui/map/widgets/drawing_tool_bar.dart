import 'package:app_core/app/ui/map/widgets/tool_item.dart';
import 'package:app_core/domain/enums/drawing_mode.dart';
import 'package:app_core/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';

class DrawingToolsBar extends StatelessWidget {
  final double? height;
  final Color? activeColor;
  final DrawingMode? selectedMode;
  final ValueChanged<DrawingMode>? onSelectMode;
  final VoidCallback? onExplore;

  const DrawingToolsBar({
    super.key,
    this.height,
    this.activeColor,
    this.selectedMode,
    this.onSelectMode,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Material(
        color: Colors.white,
        elevation: 6,
        shadowColor: Colors.black.withAlpha(31),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToolItem(
                  icon: Icons.explore,
                  label: 'Khám phá',
                  activeColor: AppColors.successDark,
                  selected: selectedMode == DrawingMode.none,
                  onTap: onExplore!,
                ),
                ToolItem(
                  icon: Icons.location_on,
                  label: 'Ghim',
                  activeColor: activeColor!,
                  selected: selectedMode == DrawingMode.point,
                  onTap: () => onSelectMode!(DrawingMode.point),
                ),
                ToolItem(
                  icon: Icons.route,
                  label: 'Đo tuyến',
                  activeColor: activeColor!,
                  selected: selectedMode == DrawingMode.measure,
                  onTap: () => onSelectMode!(DrawingMode.measure),
                ),
                ToolItem(
                  icon: Icons.square_foot,
                  label: 'Diện tích',
                  activeColor: activeColor!,
                  selected: selectedMode == DrawingMode.polygon,
                  onTap: () => onSelectMode!(DrawingMode.polygon),
                ),
                ToolItem(
                  icon: Icons.gps_fixed,
                  label: 'GPS',
                  activeColor: const Color(0xFF3B82F6),
                  selected: selectedMode == DrawingMode.gpsPolygon,
                  onTap: () => onSelectMode!(DrawingMode.gpsPolygon),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
