import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_document_controller.dart';
import '../../../untils/app_colors.dart';
import '../../task/widgets/stat_card_widget.dart';

class TaskDocumentStatsGridWidget extends StatelessWidget {
  final TaskDocumentController controller;
  final bool isDark;

  const TaskDocumentStatsGridWidget({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.stats.value;
      return Row(
        children: [
          // Card 1: Tổng số
          Expanded(
            child: StatCardWidget(
              icon: Icons.description_outlined,
              label: 'Tổng số',
              count: stats.total,
              color: AppColors.primary,
              isSelected: controller.selectedStatus.value == 'all',
              onTap: () {
                controller.selectedStatus.value = 'all';
                controller.currentPage.value = 1;
              },
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 6),
          // Card 2: Đã ban hành
          Expanded(
            child: StatCardWidget(
              icon: Icons.check_circle_outline,
              label: 'Đã ban hành',
              count: stats.published,
              color: AppColors.done,
              isSelected: controller.selectedStatus.value == 'published',
              onTap: () {
                if (controller.selectedStatus.value == 'published') {
                  controller.selectedStatus.value = 'all';
                } else {
                  controller.selectedStatus.value = 'published';
                }
                controller.currentPage.value = 1;
              },
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 6),
          // Card 3: Bản nháp
          Expanded(
            child: StatCardWidget(
              icon: Icons.access_time_outlined,
              label: 'Bản nháp',
              count: stats.draft,
              color: AppColors.paused,
              isSelected: controller.selectedStatus.value == 'draft',
              onTap: () {
                if (controller.selectedStatus.value == 'draft') {
                  controller.selectedStatus.value = 'all';
                } else {
                  controller.selectedStatus.value = 'draft';
                }
                controller.currentPage.value = 1;
              },
              isDark: isDark,
            ),
          ),
        ],
      );
    });
  }
}
