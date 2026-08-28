import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_document_controller.dart';
import '../../../untils/app_colors.dart';

class TaskDocumentStatsGridWidget extends StatelessWidget {
  final TaskDocumentController controller;
  final bool isDark;

  const TaskDocumentStatsGridWidget({
    super.key,
    required this.controller,
    required this.isDark,
  });

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color borderColor,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.white10 : borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.grey : textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.stats.value;
      return Row(
        children: [
          // Card 1: Tổng số
          Expanded(
            child: _buildStatCard(
              icon: Icons.description_outlined,
              label: 'Tổng số',
              count: stats.total,
              borderColor: AppColors.borderBlue,
              bgColor: isDark ? AppColors.cardDark : AppColors.badgeBlueBg,
              textColor: AppColors.textMain,
              iconColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          // Card 2: Đã ban hành
          Expanded(
            child: _buildStatCard(
              icon: Icons.check_circle_outline,
              label: 'Đã ban hành',
              count: stats.published,
              borderColor: AppColors.borderGreen,
              bgColor: isDark ? AppColors.cardDark : AppColors.badgeGreenBg,
              textColor: AppColors.textGreen,
              iconColor: AppColors.done,
            ),
          ),
          const SizedBox(width: 8),
          // Card 3: Bản nháp
          Expanded(
            child: _buildStatCard(
              icon: Icons.access_time_outlined,
              label: 'Bản nháp',
              count: stats.draft,
              borderColor: AppColors.borderAmber,
              bgColor: isDark ? AppColors.cardDark : AppColors.warningBg,
              textColor: AppColors.warningOrange,
              iconColor: AppColors.paused,
            ),
          ),
        ],
      );
    });
  }
}
