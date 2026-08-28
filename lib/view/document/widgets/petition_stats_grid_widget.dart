import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/petition_controller.dart';
import '../../../untils/app_colors.dart';
import '../../task/widgets/stat_card_widget.dart';

class PetitionStatsGridWidget extends StatelessWidget {
  final PetitionController controller;
  final bool isDark;

  const PetitionStatsGridWidget({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.stats.value;
      final dynamicTotal = s.total;
      final dynamicNew = s.todo;
      final dynamicProcessing = s.inProgress;
      final dynamicCompleted = s.done;
      final dynamicPaused = s.paused;
      final dynamicCancelled = s.cancelled;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRẠNG THÁI XỬ LÝ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: AppColors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 2.1,
            children: [
              StatCardWidget(
                label: 'Tổng',
                count: dynamicTotal,
                icon: Icons.filter_list,
                color: AppColors.primary,
                isSelected: controller.selectedStatusFilter.value == 'all',
                onTap: () {
                  controller.selectedStatusFilter.value = 'all';
                  controller.currentPage.value = 1;
                  controller.fetchPetitions();
                },
                isDark: isDark,
              ),
              StatCardWidget(
                label: 'Mới tiếp nhận',
                count: dynamicNew,
                icon: Icons.access_time,
                color: AppColors.todo,
                isSelected: controller.selectedStatusFilter.value == 'new',
                onTap: () {
                  controller.selectedStatusFilter.value = 'new';
                  controller.currentPage.value = 1;
                  controller.fetchPetitions();
                },
                isDark: isDark,
              ),
              StatCardWidget(
                label: 'Đang xử lý',
                count: dynamicProcessing,
                icon: Icons.rotate_right,
                color: AppColors.inProgress,
                isSelected: controller.selectedStatusFilter.value == 'processing',
                onTap: () {
                  controller.selectedStatusFilter.value = 'processing';
                  controller.currentPage.value = 1;
                  controller.fetchPetitions();
                },
                isDark: isDark,
              ),
              StatCardWidget(
                label: 'Đã hoàn thành',
                count: dynamicCompleted,
                icon: Icons.done_all,
                color: AppColors.done,
                isSelected: controller.selectedStatusFilter.value == 'completed',
                onTap: () {
                  controller.selectedStatusFilter.value = 'completed';
                  controller.currentPage.value = 1;
                  controller.fetchPetitions();
                },
                isDark: isDark,
              ),
              StatCardWidget(
                label: 'Tạm dừng',
                count: dynamicPaused,
                icon: Icons.pause_circle_outline,
                color: AppColors.paused,
                isSelected: controller.selectedStatusFilter.value == 'paused',
                onTap: () {
                  controller.selectedStatusFilter.value = 'paused';
                  controller.currentPage.value = 1;
                  controller.fetchPetitions();
                },
                isDark: isDark,
              ),
              StatCardWidget(
                label: 'Đã hủy',
                count: dynamicCancelled,
                icon: Icons.cancel_outlined,
                color: AppColors.overdue,
                isSelected: controller.selectedStatusFilter.value == 'cancelled',
                onTap: () {
                  controller.selectedStatusFilter.value = 'cancelled';
                  controller.currentPage.value = 1;
                  controller.fetchPetitions();
                },
                isDark: isDark,
              ),
            ],
          ),
        ],
      );
    });
  }
}
