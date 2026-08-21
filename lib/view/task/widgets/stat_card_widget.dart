import 'package:flutter/material.dart';
import '../../../untils/app_colors.dart';

class StatCardWidget extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const StatCardWidget({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = isDark ? AppColors.cardDark : AppColors.white;
    if (isSelected) {
      bgColor = isDark ? AppColors.primary.withValues(alpha: 0.18) : AppColors.badgeBlueBg;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.015),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: isSelected ? AppColors.primary : color),
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.white : AppColors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.grey[400] : AppColors.grey[600]),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
