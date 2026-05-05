import 'package:flutter/material.dart';

class MapFloatingActionButton extends StatelessWidget {
  const MapFloatingActionButton({
    super.key,
    required this.heroTag,
    required this.onPressed,
    this.onLongPress,
    required this.child,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.elevation = 4,
  });

  final String heroTag;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: FloatingActionButton(
        heroTag: heroTag,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        shape: const CircleBorder(),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
