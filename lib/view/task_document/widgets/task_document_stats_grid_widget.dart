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
    required String statusKey,
    required Color borderColor,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    final bool isSelected = controller.selectedStatus.value == statusKey;

    Color effectiveBg = isDark ? AppColors.cardDark : bgColor;
    if (isSelected) {
      effectiveBg = isDark ? AppColors.primary.withValues(alpha: 0.18) : AppColors.badgeBlueBg;
    }

    return GestureDetector(
      onTap: () {
        if (controller.selectedStatus.value == statusKey) {
          controller.selectedStatus.value = 'all';
        } else {
          controller.selectedStatus.value = statusKey;
        }
        controller.currentPage.value = 1;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.white10 : borderColor),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? AppColors.primary : iconColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.grey : textColor),
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
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.white : textColor),
              ),
            ),
          ],
        ),
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
              statusKey: 'all',
              borderColor: AppColors.borderBlue,
              bgColor: AppColors.badgeBlueBg,
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
              statusKey: 'published',
              borderColor: AppColors.borderGreen,
              bgColor: AppColors.badgeGreenBg,
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
              statusKey: 'draft',
              borderColor: AppColors.borderAmber,
              bgColor: AppColors.warningBg,
              textColor: AppColors.warningOrange,
              iconColor: AppColors.paused,
            ),
          ),
        ],
      );
    });
  }
}
