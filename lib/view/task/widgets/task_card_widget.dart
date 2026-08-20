import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../model/task_model.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_strings.dart';
import '../create_task_screen.dart';
import 'task_details_dialog.dart';

class TaskCardWidget extends GetView<TaskController> {
  final TaskModel task;
  final bool isDark;
  final Color primaryColor;

  const TaskCardWidget({
    Key? key,
    required this.task,
    required this.isDark,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final bool canUpdate = authCtrl.can('update', 'TaskAssignmentItems');
    final bool canDelete = authCtrl.can('destroy', 'TaskAssignmentItems');

    // Determine status text and colors
    String statusText = AppStrings.statusInProgress;
    Color statusColor = AppColors.primary;
    Color statusBgColor = AppColors.badgeBlueBg;

    if (task.processingStatus == 'todo') {
      statusText = AppStrings.statusTodo;
      statusColor = AppColors.textGrayDark;
      statusBgColor = isDark ? AppColors.white10 : AppColors.lightBg;
    } else if (task.processingStatus == 'pending_approval' || task.processingStatus == 'pending') {
      statusText = AppStrings.statusPendingApproval;
      statusColor = AppColors.pendingApproval;
      statusBgColor = isDark ? AppColors.cardItemDark : AppColors.bgPurpleLight;
    } else if (task.processingStatus == 'done' || task.processingStatus == 'completed') {
      statusText = AppStrings.statusDone;
      statusColor = AppColors.done;
      statusBgColor = AppColors.badgeGreenBg;
    } else if (task.processingStatus == 'paused') {
      statusText = AppStrings.statusPaused;
      statusColor = AppColors.paused;
      statusBgColor = AppColors.bgYellowLight;
    } else if (task.processingStatus == 'cancelled') {
      statusText = AppStrings.statusCancelled;
      statusColor = AppColors.overdue;
      statusBgColor = AppColors.badgeRedBg;
    }

    // Determine timing text
    String timingText = AppStrings.timingOnTimeUpper;
    if (task.isOverdue || task.timingStatus == 'overdue') {
      timingText = AppStrings.timingOverdueUpper;
    } else if (task.timingStatus == 'late') {
      timingText = AppStrings.timingLateUpper;
    } else if (task.timingStatus == 'early') {
      timingText = AppStrings.timingEarlyUpper;
    } else if (task.timingStatus == 'upcoming') {
      timingText = AppStrings.timingUpcomingUpper;
    }

    // Format deadline
    String deadlineStr = 'N/A';
    if (task.endAt != null && task.endAt!.isNotEmpty) {
      try {
        final spaceParts = task.endAt!.trim().split(' ');
        String datePart = spaceParts.length >= 2 ? spaceParts[1] : spaceParts[0];
        if (datePart.contains('/')) {
          final dateParts = datePart.split('/');
          if (dateParts.length >= 2) {
            deadlineStr = '${dateParts[0]}/${dateParts[1]}';
          }
        } else if (datePart.contains('-')) {
          final dateParts = datePart.split('-');
          if (dateParts.length >= 3) {
            if (dateParts[0].length == 4) {
              deadlineStr = '${dateParts[2]}/${dateParts[1]}';
            } else {
              deadlineStr = '${dateParts[0]}/${dateParts[1]}';
            }
          }
        }
      } catch (_) {}
    }

    Widget card = Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.white10 : AppColors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => showTaskDetailsDialog(context, task, isDark, primaryColor),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.paused,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.white10 : AppColors.lightBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Nguyễn Văn Hùng', style: TextStyle(fontSize: 9, color: AppColors.grey[700])),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.circle, size: 3, color: AppColors.grey),
                        const SizedBox(width: 6),
                        Text('Hạn: $deadlineStr', style: const TextStyle(fontSize: 9, color: AppColors.grey)),
                        const SizedBox(width: 6),
                        const Icon(Icons.circle, size: 3, color: AppColors.grey),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.badgeBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('• ${task.completionPercent}%', style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (canUpdate) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => Get.to(() => CreateTaskScreen(taskToUpdate: task)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.white10 : AppColors.badgeBlueBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.edit_outlined, size: 14, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: timingText == 'QUÁ HẠN' ? AppColors.badgeRedBg : AppColors.badgeGreenBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    timingText,
                    style: TextStyle(
                      color: timingText == 'QUÁ HẠN' ? AppColors.overdue : AppColors.done,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
             Expanded(child: GestureDetector(
               onTap: () => controller.toggleTaskSelection(task.id),
               child: card
             )),
           ]
        );
      } else if (canDelete) {
        return Dismissible(
          key: Key(task.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
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
               onConfirm: () => Get.back(result: true),
               onCancel: () => Get.back(result: false),
             );
          },
          onDismissed: (direction) {
            controller.deleteTask(task.id);
          },
          child: card,
        );
      } else {
        return card;
      }
    });
  }
}

