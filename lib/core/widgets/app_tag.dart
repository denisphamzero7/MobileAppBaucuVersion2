import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';
import '../../untils/app_textstyles.dart';

/// Tag / Chip dùng chung toàn ứng dụng để chuẩn hóa giao diện và tái sử dụng
class AppTag extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isDark;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  const AppTag({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.iconColor,
    this.iconSize = 12,
    this.fontSize = 10.5,
    this.fontWeight = FontWeight.w600,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    this.borderRadius = 6,
    this.isDark = false,
    this.onTap,
    this.leading,
    this.trailing,
  });

  /// Factory cho Tag thông tin chung (Loại việc, Phòng ban, Người thực hiện...)
  factory AppTag.info({
    Key? key,
    required String label,
    bool isDark = false,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return AppTag(
      key: key,
      label: label,
      backgroundColor: isDark ? AppColors.white10 : AppColors.lightBg,
      textColor: isDark ? AppColors.white70 : AppColors.grey[800],
      icon: icon,
      iconColor: isDark ? AppColors.white70 : AppColors.grey[700],
      isDark: isDark,
      onTap: onTap,
    );
  }

  /// Factory cho Tag % Tiến độ (ví dụ: '40%', '100%')
  factory AppTag.percent({
    Key? key,
    required int percent,
    bool isDark = false,
    bool showBullet = true,
  }) {
    return AppTag(
      key: key,
      label: showBullet ? '• $percent%' : '$percent%',
      backgroundColor: AppColors.badgeBlueBg,
      textColor: AppColors.primary,
      fontWeight: FontWeight.bold,
      isDark: isDark,
    );
  }

  /// Factory cho Tag Hạn chót / Ngày tháng
  factory AppTag.date({
    Key? key,
    required String dateText,
    bool isOverdue = false,
    bool isDark = false,
    String prefix = 'Hạn: ',
  }) {
    if (isOverdue) {
      return AppTag(
        key: key,
        label: '$prefix$dateText',
        backgroundColor: AppColors.bgRedLight,
        textColor: AppColors.overdue,
        borderColor: const Color(0xFFFCA5A5),
        fontWeight: FontWeight.bold,
        isDark: isDark,
      );
    }
    return AppTag(
      key: key,
      label: '$prefix$dateText',
      backgroundColor: isDark ? AppColors.white10 : AppColors.lightBg,
      textColor: isDark ? AppColors.white70 : AppColors.grey[700],
      fontWeight: FontWeight.w500,
      isDark: isDark,
    );
  }

  /// Factory cho Badge Trạng thái xử lý / Tiến độ hình viên thuốc (Pill Badge)
  factory AppTag.status({
    Key? key,
    required String label,
    required Color color,
    required Color backgroundColor,
    double borderRadius = 20,
    bool isDark = false,
  }) {
    return AppTag(
      key: key,
      label: label,
      backgroundColor: backgroundColor,
      textColor: color,
      fontSize: 9.5,
      fontWeight: FontWeight.bold,
      borderRadius: borderRadius,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      isDark: isDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? (isDark ? AppColors.white10 : AppColors.lightBg);
    final txtColor = textColor ?? (isDark ? AppColors.white : AppColors.black87);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null ? Border.all(color: borderColor!, width: 0.8) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 4),
          ] else if (icon != null) ...[
            Icon(icon, size: iconSize, color: iconColor ?? txtColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTextStyle.chipText.copyWith(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: txtColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 4),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }
}
