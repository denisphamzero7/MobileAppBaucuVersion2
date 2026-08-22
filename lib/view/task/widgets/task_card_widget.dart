import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/task_controller.dart';
import '../../../model/task_model.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_strings.dart';
import '../../../untils/app_textstyles.dart';
import '../../../helper/date_helper.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../core/widgets/app_priority_indicator.dart';
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

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final bool canDelete = authCtrl.can('destroy', 'TaskAssignmentItems');

    final titleText = task.name.trim().isNotEmpty
        ? task.name.trim()
        : (task.documentName != null && task.documentName!.isNotEmpty ? task.documentName! : 'Công việc');

    final String typeName = (task.itemTypeName != null && task.itemTypeName!.trim().isNotEmpty)
        ? task.itemTypeName!.trim()
        : 'Chưa phân loại';

    final bool isOverdue = task.isOverdue || task.timingStatus == 'overdue';
    final String deadlineFormatted = DateHelper.formatDayMonth(task.endAt);

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
            // 1. HÀNG TRÊN: Chấm tròn mức độ ưu tiên (Chạm vào hiện Tooltip popup) + Tên công việc
            Row(
              children: [
                AppPriorityIndicator(
                  priority: task.priority,
                  size: 8,
                  isDark: isDark,
                  padding: const EdgeInsets.only(right: 8),
                ),
                Expanded(
                  child: Text(
                    titleText,
                    style: AppTextStyle.cardTitle.copyWith(
                      color: isDark ? AppColors.white : AppColors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 2. HÀNG DƯỚI: Tag loại công việc, Tag ngày quá hạn, Tag % tiến độ, Icon biểu đồ sóng bên phải
            Row(
              children: [
                // Tag loại công việc
                AppTag.info(
                  label: typeName,
                  isDark: isDark,
                ),
                const SizedBox(width: 6),

                // Tag ngày quá hạn (nếu có)
                if (isOverdue && deadlineFormatted.isNotEmpty) ...[
                  AppTag.date(
                    dateText: deadlineFormatted,
                    isOverdue: true,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),
                ],

                // Tag % tiến độ
                AppTag.percent(
                  percent: task.completionPercent,
                  isDark: isDark,
                  showBullet: false,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => controller.toggleTaskSelection(task.id),
                activeColor: Colors.red,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
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
