import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_controller.dart';
import '../../../untils/app_colors.dart';

class StatisticTimingGridWidget extends StatelessWidget {
  final TaskController taskController;
  final bool isDark;

  const StatisticTimingGridWidget({
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
      final timing = stats.timingStats;
      final upcoming = timing.upcoming;
      final early = timing.early;
      final onTime = timing.onTime;
      final late = timing.late;
      final overdue = timing.overdue;
      final timingCancelled = timing.cancelled;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TIẾN ĐỘ CÔNG VIỆC',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.grey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCardItem('Chưa đến hạn', upcoming.toString(), AppColors.textTeal, AppColors.bgTealLight),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCardItem('Sớm hạn', early.toString(), AppColors.textGreenDark, AppColors.badgeGreenBg),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCardItem('Đúng hạn', onTime.toString(), AppColors.textBlueDark, AppColors.badgeBlueBg),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCardItem('Trễ hạn', late.toString(), AppColors.textRedDark, AppColors.bgRedVeryLight),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCardItem('Quá hạn', overdue.toString(), AppColors.textRedVeryDark, AppColors.bgRedLight),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCardItem('Đã hủy', timingCancelled.toString(), AppColors.cancelled, AppColors.bgGrayLight),
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
