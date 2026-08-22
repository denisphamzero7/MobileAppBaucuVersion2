import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';
import '../../untils/app_textstyles.dart';

/// ============================================================================
/// 📌 [AppPriorityIndicator] - CHỈ BÁO ĐỘ ƯU TIÊN VỚI TOOLTIP CHẠM (POPUP)
/// ============================================================================
/// 
/// Dùng để hiển thị chấm màu hoặc icon lá cờ đại diện cho mức độ ưu tiên.
/// Khi người dùng chạm vào (Tap) trên Mobile, một popup Tooltip nhỏ màu tối
/// sẽ nổi lên phía trên hiển thị tên mức độ ưu tiên (VD: "Ưu tiên: Cao").
class AppPriorityIndicator extends StatelessWidget {
  final String? priority;
  final double size;
  final bool isDark;
  final bool useFlagIcon;
  final EdgeInsetsGeometry padding;

  const AppPriorityIndicator({
    super.key,
    required this.priority,
    this.size = 8.0,
    this.isDark = false,
    this.useFlagIcon = false,
    this.padding = const EdgeInsets.all(4.0),
  });

  /// Lấy màu sắc theo mức độ ưu tiên
  static Color getColor(String? priority) {
    final p = priority?.toLowerCase().trim() ?? '';
    if (p == 'urgent' || p == 'khan_cap' || p == 'khẩn cấp' || p == 'critical' || p == 'very_high') {
      return AppColors.priorityUrgent; // 🔴 Đỏ: Khẩn cấp
    }
    if (p == 'high' || p == 'cao') {
      return AppColors.priorityHigh; // 🟠 Cam: Cao
    }
    if (p == 'medium' || p == 'trung_binh' || p == 'trung bình' || p == 'normal') {
      return AppColors.priorityMedium; // 🔵 Xanh dương: Trung bình
    }
    return AppColors.priorityLow; // ⚫ Xám Slate: Thấp
  }

  /// Lấy nhãn hiển thị mức độ ưu tiên
  static String getLabel(String? priority) {
    final p = priority?.toLowerCase().trim() ?? '';
    if (p == 'urgent' || p == 'khan_cap' || p == 'khẩn cấp' || p == 'critical' || p == 'very_high') {
      return 'Ưu tiên: Khẩn cấp';
    }
    if (p == 'high' || p == 'cao') {
      return 'Ưu tiên: Cao';
    }
    if (p == 'medium' || p == 'trung_binh' || p == 'trung bình' || p == 'normal') {
      return 'Ưu tiên: Trung bình';
    }
    return 'Ưu tiên: Thấp';
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor(priority);
    final label = getLabel(priority);

    return Tooltip(
      message: label,
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: false,
      verticalOffset: 14,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      showDuration: const Duration(seconds: 2),
      waitDuration: Duration.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textStyle: AppTextStyle.chipText.copyWith(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
      child: Padding(
        padding: padding,
        child: useFlagIcon
            ? Icon(
                Icons.flag_rounded,
                size: size + 6,
                color: color,
              )
            : Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}
