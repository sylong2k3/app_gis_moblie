import 'package:flutter/material.dart';

class ToastHelper {
  static void showSuccess(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFF10B981),
      iconColor: Colors.white,
    );
  }

  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: const Color(0xFFEF4444),
      iconColor: Colors.white,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: const Color(0xFFF59E0B),
      iconColor: Colors.white,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: const Color(0xFF3B82F6),
      iconColor: Colors.white,
    );
  }

  static void _showToast(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    if (!context.mounted) {
      return;
    }

    try {
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay == null) {
        return;
      }

      final mediaQuery = MediaQuery.of(context);
      final maxWidth = mediaQuery.size.width * 0.88;

      late final OverlayEntry entry;
      var isRemoved = false;

      void removeEntry() {
        if (isRemoved) return;
        isRemoved = true;
        if (entry.mounted) {
          entry.remove();
        }
      }

      entry = OverlayEntry(
        builder: (context) => Positioned.fill(
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 16, right: 16, left: 16),
            child: Align(
              alignment: Alignment.topRight,
              child: _AnimatedToast(
                message: message,
                icon: icon,
                backgroundColor: backgroundColor,
                iconColor: iconColor,
                maxWidth: maxWidth,
                onDismissed: removeEntry,
              ),
            ),
          ),
        ),
      );

      overlay.insert(entry);
    } catch (e) {
      debugPrint('❌ Error showing toast: $e');
    }
  }
}

class _AnimatedToast extends StatefulWidget {
  const _AnimatedToast({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.maxWidth,
    required this.onDismissed,
  });

  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double maxWidth;
  final VoidCallback onDismissed;

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _playLifecycle();
  }

  Future<void> _playLifecycle() async {
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: widget.iconColor, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
