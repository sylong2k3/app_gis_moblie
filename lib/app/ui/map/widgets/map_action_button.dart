import 'package:app_core/shared/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

class MapActionButton extends StatelessWidget {
  const MapActionButton({
    super.key,
    required this.heroTag,
    required this.iconPath,
    required this.onPressed,
    this.onLongPress,
    this.size,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black87,
    this.isActive = false,
  });

  final String heroTag;
  final String iconPath;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final Size? size;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? AppDimensions.imageSizeExtraSmall;

    return GestureDetector(
      onLongPress: onLongPress,
      child: FloatingActionButton(
        heroTag: heroTag,
        backgroundColor: isActive ? const Color(0xFF2196F3) : backgroundColor,
        foregroundColor: foregroundColor,
        onPressed: onPressed,
        child: Image.asset(
          iconPath,
          width: iconSize.width,
          height: iconSize.height,
          color: isActive ? Colors.white : null,
        ),
      ),
    );
  }
}
