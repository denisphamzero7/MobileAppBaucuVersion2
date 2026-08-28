import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

class AppEmptyWidget extends StatelessWidget {
  final String? message;
  final String? subtitle;
  final IconData? icon;
  final double topPadding;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyWidget({
    super.key,
    this.message,
    this.subtitle,
    this.icon,
    this.topPadding = 40.0,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: topPadding, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 52,
              color: isDark ? AppColors.white30 : AppColors.grey[400],
            ),
            const SizedBox(height: 10),
            Text(
              message ?? 'Không tìm thấy dữ liệu nào',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white70 : AppColors.grey[700],
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.white30 : AppColors.grey[500],
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(actionLabel!, style: const TextStyle(fontSize: 12.5)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
