import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/navigation.dart';
import '../../../controllers/task_controller.dart';
import '../../../model/task_model.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_textstyles.dart';
import '../../widgets/skeleton_loader.dart';
import '../../task/widgets/task_card_widget.dart';

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
            color: AppColors.black.withValues(alpha: 0.02),
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
          const SizedBox(height: 12),
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
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) => const SkeletonLoader(
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 70,
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
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCardWidget(
                  task: task,
                  isDark: isDark,
                  primaryColor: AppColors.primary,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
