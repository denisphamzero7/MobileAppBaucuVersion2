import '../../untils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../untils/app_textstyles.dart';

class StatusInfoCard extends StatelessWidget {
  final TaskController taskController = Get.find<TaskController>();
  final AuthController authController = Get.find<AuthController>();
  final Color whiteColor;

  StatusInfoCard({super.key, required this.whiteColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final stats = taskController.stats.value;
      final orgs = authController.getAvailableOrganizations();
      final currentOrgId = authController.currentOrganizationId.value;
      final currentOrg = orgs.firstWhereOrNull((x) => x.id == currentOrgId);

      final total = stats.total;
      final todo = stats.todo;
      final inProgress = stats.inProgress;
      final pendingApproval = stats.pendingApproval;
      final done = stats.done;
      final paused = stats.paused;
      final cancelled = stats.cancelled;

      final timing = stats.timingStats;
      final upcoming = timing.upcoming;
      final early = timing.early;
      final onTime = timing.onTime;
      final late = timing.late;
      final overdue = timing.overdue;
      final timingCancelled = timing.cancelled;

      // Tính tỷ lệ phần trăm hoàn thành: done / total
      final double donePercent = total > 0 ? (done / total) * 100 : 0.0;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER PHẦN TRÊN ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge tổ chức
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.white24),
                        ),
                        child: Text(
                          'BÁO CÁO CÔNG VIỆC',
                          style: AppTextStyle.bodySmall.copyWith(
                            color: AppColors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tên địa bàn
                      Text(
                        'Tiến độ tổng quan',
                        style: AppTextStyle.h2.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${donePercent.round()}%',
                      style: AppTextStyle.h1.copyWith(
                        color: AppColors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Hoàn thành',
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- THẺ TRẮNG CHỨA GRID BÊN TRONG ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TIÊU ĐỀ 1
                  _buildSectionHeader('TRẠNG THÁI XỬ LÝ', isDark),
                  const SizedBox(height: 12),
                  
                  // GRID TRẠNG THÁI (Row 1 has 3 items, Row 2 has 4 items)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildGridItem('Tổng số', total.toString(), AppColors.todo, AppColors.bgPurpleLight, isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: _buildGridItem('Chưa làm', todo.toString(), AppColors.textGrayDark, AppColors.lightBg, isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: _buildGridItem('Đang làm', inProgress.toString(), AppColors.inProgress, AppColors.bgBlueLight, isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGridItem('Chờ duyệt', pendingApproval.toString(), AppColors.pendingApproval, AppColors.bgPurpleVeryLight, isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Hoàn thành', done.toString(), AppColors.done, AppColors.badgeGreenBg, isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Tạm dừng', paused.toString(), AppColors.paused, AppColors.bgYellowLight, isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Đã hủy', cancelled.toString(), AppColors.cancelled, AppColors.bgGrayLight, isDark),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // TIÊU ĐỀ 2
                  _buildSectionHeader('TIẾN ĐỘ CÔNG VIỆC', isDark),
                  const SizedBox(height: 12),
                  
                  // GRID TIẾN ĐỘ (Row 1 has 3 items, Row 2 has 3 items)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildGridItem('Chưa đến hạn', upcoming.toString(), AppColors.textTeal, AppColors.bgTealLight, isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Sớm hạn', early.toString(), AppColors.textGreenDark, AppColors.badgeGreenBg, isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Đúng hạn', onTime.toString(), AppColors.textBlueDark, AppColors.badgeBlueBg, isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGridItem('Trễ hạn', late.toString(), AppColors.textRedDark, AppColors.bgRedVeryLight, isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Quá hạn', overdue.toString(), AppColors.textRedVeryDark, AppColors.bgRedLight, isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Đã hủy', timingCancelled.toString(), AppColors.cancelled, AppColors.bgGrayLight, isDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: AppTextStyle.labelMedium.copyWith(
        color: isDark ? AppColors.grey[400] : AppColors.grey[500],
        fontWeight: FontWeight.bold,
        fontSize: 10,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildGridItem(String label, String value, Color textColor, Color bgColor, bool isDark) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardItemDark : bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withOpacity(0.02),
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
                  color: isDark ? AppColors.grey[400] : textColor.withOpacity(0.8),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? AppColors.white : textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




