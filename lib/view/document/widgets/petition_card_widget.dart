import 'package:flutter/material.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../service/petition_service.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_textstyles.dart';

class PetitionCardWidget extends StatelessWidget {
  final PetitionItemModel petition;
  final bool isDark;
  final bool isSelected;
  final bool isMultiSelectMode;
  final bool canUpdate;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleSelect;

  const PetitionCardWidget({
    super.key,
    required this.petition,
    required this.isDark,
    this.isSelected = false,
    this.isMultiSelectMode = false,
    this.canUpdate = false,
    required this.onTap,
    this.onEdit,
    this.onToggleSelect,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'processing':
      case 'in_progress':
        return AppColors.inProgress;
      case 'completed':
      case 'done':
        return AppColors.done;
      case 'paused':
        return AppColors.paused;
      case 'cancelled':
        return AppColors.cancelled;
      default:
        return AppColors.todo;
    }
  }

  String _formatDeadline(String deadline) {
    if (deadline.isEmpty) return '';
    try {
      final spaceParts = deadline.trim().split(' ');
      String datePart = spaceParts.length >= 2 ? spaceParts[1] : spaceParts[0];
      if (datePart.contains('/')) {
        final dateParts = datePart.split('/');
        if (dateParts.length >= 2) {
          return '${dateParts[0]}/${dateParts[1]}';
        }
      } else if (datePart.contains('-')) {
        final dateParts = datePart.split('-');
        if (dateParts.length >= 3) {
          if (dateParts[0].length == 4) {
            return '${dateParts[2]}/${dateParts[1]}';
          } else {
            return '${dateParts[0]}/${dateParts[1]}';
          }
        }
      }
    } catch (_) {}
    return deadline;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(petition.processingStatus);
    final deadlineFormatted = _formatDeadline(petition.deadlineDate);
    final isOverdue = petition.isOverdue || petition.timingStatus == 'overdue';
    final senderOrDept = petition.senderName.isNotEmpty
        ? petition.senderName
        : (petition.departmentName.isNotEmpty ? petition.departmentName : 'Đơn thư');

    final card = Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HÀNG TRÊN: Chấm tròn trạng thái + Tiêu đề đơn thư + Nút sửa nhanh (nếu có quyền)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5, right: 8),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    petition.title,
                    style: AppTextStyle.cardTitle.copyWith(
                      color: isDark ? AppColors.white : AppColors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // if (canUpdate && onEdit != null) ...[
                //   const SizedBox(width: 6),
                //   InkWell(
                //     onTap: onEdit,
                //     borderRadius: BorderRadius.circular(6),
                //     child: Container(
                //       padding: const EdgeInsets.all(4),
                //       decoration: BoxDecoration(
                //         color: isDark ? AppColors.white10 : AppColors.badgeBlueBg,
                //         borderRadius: BorderRadius.circular(6),
                //       ),
                //       child: const Icon(Icons.edit_outlined, size: 14, color: AppColors.primary),
                //     ),
                //   ),
                // ],
              ],
            ),
            const SizedBox(height: 10),

            // 2. HÀNG DƯỚI: Tag người gửi/phòng ban, Tag ngày hạn, Tag % tiến độ, Icon trạng thái/nhịp sóng bên phải
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tag người gửi / phòng ban
                      Flexible(
                        child: AppTag.info(
                          label: senderOrDept,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Tag ngày quá hạn / hạn chót (nếu có)
                      if (deadlineFormatted.isNotEmpty) ...[
                        AppTag.date(
                          dateText: deadlineFormatted,
                          isOverdue: isOverdue,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                      ],

                      // Tag % tiến độ
                      AppTag.percent(
                        percent: petition.completionPercent,
                        isDark: isDark,
                        showBullet: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Icon bên phải: Sóng nhịp (khi có tiến độ > 0%) hoặc Đồng hồ (khi 0%)
                if (petition.completionPercent > 0 || petition.processingStatus == 'processing' || petition.processingStatus == 'in_progress')
                  const Icon(
                    Icons.ssid_chart,
                    size: 20,
                    color: AppColors.primary,
                  )
                else
                  Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: isDark ? AppColors.white70 : AppColors.grey[400],
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isMultiSelectMode) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: isSelected,
              onChanged: (_) => onToggleSelect?.call(),
              activeColor: Colors.red,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: card),
        ],
      );
    }

    return card;
  }
}
