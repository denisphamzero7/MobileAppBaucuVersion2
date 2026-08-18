import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../controllers/log_activity_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_strings.dart';
import '../../widgets/skeleton_loader.dart';

class UserOverviewTab extends StatelessWidget {
  final bool isDark;

  const UserOverviewTab({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Biểu đồ xu hướng hoạt động
        _buildTrendChart(isDark),
        const SizedBox(height: 14),

        // 2. Thông báo gần đây
        _buildRecentNotificationsCard(isDark),
        const SizedBox(height: 14),

        // 3. Hoạt động gần đây
        _buildRecentActivities(isDark),
      ],
    );
  }

  // Card 1: XU HƯỚNG HOẠT ĐỘNG
  Widget _buildTrendChart(bool isDark) {
    final LogActivityController logController = Get.find<LogActivityController>();

    return Obx(() {
      if (logController.isLoading.value && logController.logs.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoader(
                child: SkeletonBox(width: 160, height: 16, radius: 6),
              ),
              SizedBox(height: 18),
              SkeletonLoader(
                child: SkeletonBox(width: double.infinity, height: 170, radius: 12),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart_rounded, color: Color(0xFF7C4DFF), size: 18),
                const SizedBox(width: 8),
                Text(
                  AppStrings.activityTrend,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    color: isDark ? Colors.white : AppColors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AspectRatio(
              aspectRatio: 1.55,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 500,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              'T${value.toInt()}/26',
                              style: TextStyle(
                                color: isDark ? AppColors.white30 : AppColors.grey[500],
                                fontSize: 8.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 500,
                        reservedSize: 34,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return Text('0', style: TextStyle(color: isDark ? AppColors.white30 : AppColors.grey[500], fontSize: 9));
                          }
                          return Text(
                            (value / 1000).toStringAsFixed(3).replaceAll('.', ','),
                            style: TextStyle(color: isDark ? AppColors.white30 : AppColors.grey[500], fontSize: 8.5),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.06)),
                      left: BorderSide(color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.06)),
                      right: const BorderSide(color: Colors.transparent),
                      top: const BorderSide(color: Colors.transparent),
                    ),
                  ),
                  minX: 1,
                  maxX: 12,
                  minY: 0,
                  maxY: 3000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 0), FlSpot(2, 0), FlSpot(3, 0), FlSpot(4, 0),
                        FlSpot(5, 0), FlSpot(6, 0), FlSpot(7, 380), FlSpot(8, 2680),
                        FlSpot(9, 0), FlSpot(10, 0), FlSpot(11, 0), FlSpot(12, 0),
                      ],
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: const Color(0xFF7C4DFF),
                      barWidth: 2.2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 2.5,
                            color: const Color(0xFF7C4DFF),
                            strokeWidth: 1.2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7C4DFF).withValues(alpha: 0.35),
                            const Color(0xFF7C4DFF).withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Card 2: THÔNG BÁO GẦN ĐÂY
  Widget _buildRecentNotificationsCard(bool isDark) {
    final NotificationController notificationController = Get.find<NotificationController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(Icons.notifications_none_rounded, color: Color(0xFF2155FA), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppStrings.recentNotifications,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                    color: isDark ? Colors.white : AppColors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              // Nút Đã đọc tất cả
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.snackbar(AppStrings.notificationTitle, AppStrings.markAllReadSuccess, snackPosition: SnackPosition.TOP);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardItemDark : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, size: 12, color: Color(0xFF2155FA)),
                        SizedBox(width: 2),
                        Text(
                          AppStrings.markAllAsRead,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2155FA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              // Badge Số lượng mới
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2155FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() {
                  final unreadCount = notificationController.notifications.where((n) => !n.isRead).length;
                  return Text(
                    '${unreadCount > 0 ? unreadCount : 1} mới',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Notification Item
          Obx(() {
            if (notificationController.isLoading.value && notificationController.notifications.isEmpty) {
              return const SkeletonLoader(
                child: SkeletonBox(
                  width: double.infinity,
                  height: 70,
                  radius: 14,
                ),
              );
            }

            final hasNotifs = notificationController.notifications.isNotEmpty;
            final title = hasNotifs
                ? notificationController.notifications.first.title
                : 'Bạn được giao công việc mới';
            final content = hasNotifs
                ? notificationController.notifications.first.content
                : 'Công việc: Văn bản 2.B';
            final createdAt = hasNotifs
                ? notificationController.notifications.first.createdAt.toIso8601String()
                : '2026-08-14T06:04:02.000000Z';

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardItemDark : const Color(0xFFF4F7FE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.white10 : const Color(0xFF2155FA).withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2155FA).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: Color(0xFF2155FA),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              createdAt,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: isDark ? AppColors.white30 : AppColors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          content,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.white70 : AppColors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Card 3: HOẠT ĐỘNG GẦN ĐÂY
  Widget _buildRecentActivities(bool isDark) {
    final LogActivityController logController = Get.find<LogActivityController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: Color(0xFF00ACC1), size: 18),
              const SizedBox(width: 8),
              Text(
                AppStrings.recentActivities,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  color: isDark ? Colors.white : AppColors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (logController.isLoading.value && logController.logs.isEmpty) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const SkeletonLoader(
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 52,
                    radius: 10,
                  ),
                ),
              );
            }
            if (logController.logs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(AppStrings.noActivities, style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              );
            }

            final displayLogs = logController.logs.length > 5 ? logController.logs.take(5).toList() : logController.logs;

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayLogs.length,
              separatorBuilder: (context, index) => Divider(
                height: 18,
                thickness: 0.6,
                color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
              ),
              itemBuilder: (context, index) {
                final log = displayLogs[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00ACC1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00ACC1).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        log.method,
                        style: const TextStyle(
                          color: Color(0xFF00838F),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.description,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            log.ipAddress,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.white30 : AppColors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      log.createdAt,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: isDark ? AppColors.white30 : AppColors.grey[500],
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
