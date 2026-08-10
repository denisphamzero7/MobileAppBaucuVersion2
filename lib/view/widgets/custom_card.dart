import '../../untils/app_colors.dart';
import 'package:flutter/material.dart';
import '../../untils/app_textstyles.dart'; // Import file style của bạn

class CustomCard extends StatelessWidget {
  final String text;
  final IconData? icon; // Thêm icon cho đẹp (tùy chọn)
  final Color? color;   // Màu nền (tùy chọn)
  final VoidCallback? onTap; // Sự kiện bấm

  const CustomCard({
    super.key,
    required this.text,
    this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check dark mode để đổi màu
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Nếu không truyền màu thì dùng màu trắng hoặc xám đậm
          color: color ?? (isDark ? AppColors.grey[800] : AppColors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyle.labelMedium.copyWith(
                color: isDark ? AppColors.white70 : AppColors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


