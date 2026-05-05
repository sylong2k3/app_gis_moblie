import 'package:app_core/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BaseMapItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const BaseMapItem({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.successDark : Colors.transparent,
              width: 1.5,
            ),
            color: selected
                ? AppColors.successLight.withValues(alpha: 0.2)
                : const Color(0xFFF5F7FA),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.successDark : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
