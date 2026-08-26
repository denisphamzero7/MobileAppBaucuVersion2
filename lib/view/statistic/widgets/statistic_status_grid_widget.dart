import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_controller.dart';
import '../../../untils/app_colors.dart';

class StatisticStatusGridWidget extends StatelessWidget {
  final TaskController taskController;
  final bool isDark;

  const StatisticStatusGridWidget({
    super.key,
    required this.taskController,
    required this.isDark,
  });

  Widget _buildStatCardItem(String label, String value, Color textColor, Color bgColor) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardItemDark : bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
          width: 0.5,
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.grey[400] : textColor.withValues(alpha: 0.85),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? AppColors.white : textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = taskController.stats.value;
      final total = stats.total;
      final todo = stats.todo;
      final inProgress = stats.inProgress;
      final pendingApproval = stats.pendingApproval;
      final done = stats.done;
      final paused = stats.paused;
      final cancelled = stats.cancelled;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRẠNG THÁI XỬ LÝ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.grey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildStatCardItem('Tổng công việc', total.toString(), AppColors.todo, AppColors.bgPurpleLight),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildStatCardItem('Chưa thực hiện', todo.toString(), AppColors.textGrayDark, AppColors.lightBg),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildStatCardItem('Đang thực hiện', inProgress.toString(), AppColors.inProgress, AppColors.bgBlueLight),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCardItem('Chờ duyệt', pendingApproval.toString(), AppColors.pendingApproval, AppColors.bgPurpleVeryLight),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCardItem('Hoàn thành', done.toString(), AppColors.done, AppColors.badgeGreenBg),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCardItem('Tạm dừng', paused.toString(), AppColors.paused, AppColors.bgYellowLight),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCardItem('Đã hủy', cancelled.toString(), AppColors.cancelled, AppColors.bgGrayLight),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });
  }
}
