import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/task_controller.dart';
import '../../../model/task_model.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_strings.dart';
import 'task_details_dialog.dart';

class TaskCardWidget extends GetView<TaskController> {
  final TaskModel task;
  final bool isDark;
  final Color primaryColor;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.isDark,
    required this.primaryColor,
  });

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final trimmed = raw.trim();
    try {
      if (trimmed.contains(' ')) {
        final parts = trimmed.split(' ');
        if (parts.length >= 2) {
          if (parts[0].contains('-')) {
            final dateParts = parts[0].split('-');
            if (dateParts.length == 3) {
              return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
            }
          }
          return parts[0];
        }
      } else if (trimmed.contains('-')) {
        final dateParts = trimmed.split('-');
        if (dateParts.length == 3) {
          return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
        }
      }
    } catch (_) {}
    return trimmed;
  }

  Color _getDotColor(TaskModel task) {
    if (task.isOverdue || task.timingStatus == 'overdue' || task.priority.toLowerCase() == 'urgent' || task.priority.toLowerCase() == 'high') {
      return const Color(0xFFEF4444); // Red dot
    } else if (task.priority.toLowerCase() == 'medium') {
      return const Color(0xFFF59E0B); // Orange dot
    } else {
      return const Color(0xFF10B981); // Green dot
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final bool canDelete = authCtrl.can('destroy', 'TaskAssignmentItems');

    final titleText = (task.documentName != null && task.documentName!.isNotEmpty)
        ? task.documentName!
        : task.name;

    final userName = (task.assigneeName != null && task.assigneeName!.isNotEmpty)
        ? task.assigneeName!
        : (task.assignerName != null && task.assignerName!.isNotEmpty ? task.assignerName! : 'nhanviec1');

    final bool isOverdue = task.isOverdue || task.timingStatus == 'overdue';
    final String deadlineFormatted = _formatDate(task.endAt);
    final dotColor = _getDotColor(task);

    final Widget cardContent = Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
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
        onTap: () => showTaskDetailsDialog(context, task, isDark, primaryColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HÀNG TRÊN: Chấm tròn màu + Tên văn bản / Công việc
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titleText,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 2. HÀNG DƯỚI: Tag người nhận, Tag ngày quá hạn, Tag % tiến độ, Icon biểu đồ sóng bên phải
            Row(
              children: [
                // Tag người nhận việc
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.white10 : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    userName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white70 : AppColors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Tag ngày quá hạn (nếu có)
                if (isOverdue && deadlineFormatted.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.bgRedLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFCA5A5), width: 0.8),
                    ),
                    child: Text(
                      deadlineFormatted,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.overdue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // Tag % tiến độ
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.badgeBlueBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${task.completionPercent}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const Spacer(),

                // Icon bên phải: Sóng nhịp (khi có tiến độ > 0%) hoặc Đồng hồ (khi 0%)
                if (task.completionPercent > 0 || task.processingStatus == 'in_progress')
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

    return Obx(() {
      final isSelected = controller.selectedTaskIds.contains(task.id);

      if (controller.isMultiSelectMode.value && canDelete) {
        return Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => controller.toggleTaskSelection(task.id),
              activeColor: Colors.red,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleTaskSelection(task.id),
                child: cardContent,
              ),
            ),
          ],
        );
      } else if (canDelete) {
        return Dismissible(
          key: Key(task.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await Get.defaultDialog<bool>(
              title: AppStrings.deleteTask,
              middleText: AppStrings.confirmDeleteTask,
              textConfirm: AppStrings.delete,
              textCancel: AppStrings.cancel,
              confirmTextColor: Colors.white,
              buttonColor: Colors.red,
              onConfirm: () => Get.back(result: true),
              onCancel: () => Get.back(result: false),
            );
          },
          onDismissed: (direction) {
            controller.deleteTask(task.id);
          },
          child: cardContent,
        );
      } else {
        return cardContent;
      }
    });
  }
}
