import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/navigation.dart';
import '../../../controllers/task_controller.dart';
import '../../../helper/date_helper.dart';
import '../../../model/task_model.dart';
import '../../../untils/app_colors.dart';
import '../../widgets/skeleton_loader.dart';

import '../../../untils/app_textstyles.dart';

class HomeLatestTasksSection extends StatelessWidget {
  final bool isDark;

  const HomeLatestTasksSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CÔNG VIỆC MỚI NHẤT',
                style: AppTextStyle.cardTitle.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () => Get.find<NavigationController>().changeIndex(3),
                child: Text(
                  'Xem tất cả >',
                  style: AppTextStyle.chipText.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final allTasks = taskController.tasksList;
            final sentTasks = taskController.sentTasksList;
            final receivedTasks = taskController.receivedTasksList;
            // Ưu tiên tasksList, nếu rỗng thì gom từ sent + received
            final List<TaskModel> tasks = allTasks.isNotEmpty
                ? allTasks
                : [...sentTasks, ...receivedTasks];

            final isTasksLoading = taskController.isTypeLoading(null) && tasks.isEmpty;

            if (isTasksLoading) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) => const SkeletonLoader(
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 75,
                    radius: 16,
                  ),
                ),
              );
            }

            if (tasks.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.assignment_outlined, size: 36, color: AppColors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Không có công việc mới nhất',
                        style: AppTextStyle.cardSubtitle.copyWith(color: AppColors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length > 5 ? 5 : tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final task = tasks[index];

                String statusText = 'Đang thực hiện';
                if (task.processingStatus == 'todo') statusText = 'Chưa thực hiện';
                if (task.processingStatus == 'pending_approval' || task.processingStatus == 'pending') statusText = 'Chờ duyệt';
                if (task.processingStatus == 'done' || task.processingStatus == 'completed') statusText = 'Hoàn thành';
                if (task.processingStatus == 'paused') statusText = 'Tạm dừng';
                if (task.processingStatus == 'cancelled') statusText = 'Đã hủy';

                String timingText = 'ĐÚNG HẠN';
                if (task.isOverdue || task.timingStatus == 'overdue') {
                  timingText = 'QUÁ HẠN';
                } else if (task.timingStatus == 'late') {
                  timingText = 'TRỄ HẠN';
                } else if (task.timingStatus == 'early') {
                  timingText = 'SỚM HẠN';
                } else if (task.timingStatus == 'upcoming') {
                  timingText = 'CHƯA ĐẾN HẠN';
                }

                final deadlineStr = DateHelper.formatDayMonth(task.endAt);

                final assigneeName = (task.assigneeIds != null && task.assigneeIds!.isNotEmpty)
                    ? '${task.assigneeIds!.length} người thực hiện'
                    : 'Chưa phân công';

                return _buildTaskItem(
                  task.name,
                  assigneeName,
                  deadlineStr,
                  task.completionPercent,
                  statusText,
                  timingText,
                  isDark,
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTaskItem(
    String title,
    String assignee,
    String deadline,
    int percent,
    String statusText,
    String timingText,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardItemDark : AppColors.white,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orange dot status indicator
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
          // Task Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.cardTitle.copyWith(
                    fontSize: 12.5,
                    color: isDark ? AppColors.white : AppColors.black87,
                  ),
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
                        child: Text(
                          assignee,
                          style: AppTextStyle.chipText.copyWith(
                            fontSize: 9.5,
                            color: isDark ? AppColors.white70 : AppColors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.circle, size: 3, color: AppColors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Hạn: $deadline',
                        style: AppTextStyle.chipText.copyWith(
                          fontSize: 9.5,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.circle, size: 3, color: AppColors.grey),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.badgeBlueBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '• $percent%',
                          style: AppTextStyle.chipText.copyWith(
                            fontSize: 9.5,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Right Badges Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusText == 'Hoàn thành' ? AppColors.badgeGreenBg : AppColors.badgeBlueBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyle.badgeText.copyWith(
                    color: statusText == 'Hoàn thành' ? AppColors.done : AppColors.primary,
                  ),
                ),
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
                  style: AppTextStyle.badgeText.copyWith(
                    fontSize: 8.5,
                    color: timingText == 'QUÁ HẠN' ? AppColors.overdue : AppColors.done,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
