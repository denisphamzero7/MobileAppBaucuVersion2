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
      final stats = taskController.stats;
      final orgs = authController.getAvailableOrganizations();
      final currentOrgId = authController.currentOrganizationId.value;
      final currentOrg = orgs.firstWhereOrNull((x) => x.id == currentOrgId);

      final total = stats['total'] ?? 0;
      final todo = stats['todo'] ?? 0;
      final inProgress = stats['in_progress'] ?? 0;
      final pendingApproval = stats['pending_approval'] ?? 0;
      final done = stats['done'] ?? 0;
      final paused = stats['paused'] ?? 0;
      final cancelled = stats['cancelled'] ?? 0;

      final timing = stats['timing_stats'] ?? {};
      final upcoming = timing['upcoming'] ?? 0;
      final early = timing['early'] ?? 0;
      final onTime = timing['on_time'] ?? 0;
      final late = timing['late'] ?? 0;
      final overdue = timing['overdue'] ?? 0;
      final timingCancelled = timing['cancelled'] ?? 0;

      // Tính tỷ lệ phần trăm hoàn thành: done / total
      final double donePercent = total > 0 ? (done / total) * 100 : 0.0;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.3),
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
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          'BÁO CÁO CÔNG VIỆC',
                          style: AppTextStyle.bodySmall.copyWith(
                            color: Colors.white,
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
                          color: Colors.white,
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
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Hoàn thành',
                      style: AppTextStyle.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
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
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                            child: _buildGridItem('Tổng số', total.toString(), const Color(0xFF8B5CF6), const Color(0xFFF5F3FF), isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: _buildGridItem('Chưa làm', todo.toString(), const Color(0xFF4B5563), const Color(0xFFF3F4F6), isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: _buildGridItem('Đang làm', inProgress.toString(), const Color(0xFF0EA5E9), const Color(0xFFF0F9FF), isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGridItem('Chờ duyệt', pendingApproval.toString(), const Color(0xFFD946EF), const Color(0xFFFDF4FF), isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Hoàn thành', done.toString(), const Color(0xFF10B981), const Color(0xFFECFDF5), isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Tạm dừng', paused.toString(), const Color(0xFFF59E0B), const Color(0xFFFFFBEB), isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Đã hủy', cancelled.toString(), const Color(0xFF6B7280), const Color(0xFFF9FAFB), isDark),
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
                            child: _buildGridItem('Chưa đến hạn', upcoming.toString(), const Color(0xFF0D9488), const Color(0xFFF0FDFA), isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Sớm hạn', early.toString(), const Color(0xFF047857), const Color(0xFFECFDF5), isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Đúng hạn', onTime.toString(), const Color(0xFF1D4ED8), const Color(0xFFEFF6FF), isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGridItem('Trễ hạn', late.toString(), const Color(0xFFBE123C), const Color(0xFFFFF1F2), isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Quá hạn', overdue.toString(), const Color(0xFF991B1B), const Color(0xFFFEF2F2), isDark),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildGridItem('Đã hủy', timingCancelled.toString(), const Color(0xFF6B7280), const Color(0xFFF9FAFB), isDark),
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
        color: isDark ? Colors.grey[400] : Colors.grey[500],
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
        color: isDark ? const Color(0xFF2D2D2D) : bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.02),
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
                  color: isDark ? Colors.grey[400] : textColor.withOpacity(0.8),
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
                  color: isDark ? Colors.white : textColor,
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