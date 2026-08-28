import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/petition_controller.dart';
import '../../../core/enums/petition_enums.dart';
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

  int _getCountForStatus(PetitionProcessingStatus status) {
    final s = controller.stats.value;
    switch (status) {
      case PetitionProcessingStatus.all:
        return s.total;
      case PetitionProcessingStatus.newReceived:
        return s.todo;
      case PetitionProcessingStatus.processing:
        return s.inProgress;
      case PetitionProcessingStatus.completed:
        return s.done;
      case PetitionProcessingStatus.paused:
        return s.paused;
      case PetitionProcessingStatus.cancelled:
        return s.cancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
            children: PetitionProcessingStatus.values.map((status) {
              final isSelected = controller.selectedStatusFilter.value == status.key;
              final count = _getCountForStatus(status);

              return StatCardWidget(
                label: status.label,
                count: count,
                icon: status.icon,
                color: status.color,
                isSelected: isSelected,
                onTap: () {
                  if (status == PetitionProcessingStatus.all) {
                    controller.selectedStatusFilter.value = 'all';
                  } else {
                    controller.selectedStatusFilter.value =
                        controller.selectedStatusFilter.value == status.key ? 'all' : status.key;
                  }
                  controller.currentPage.value = 1;
                  controller.fetchPetitions();
                },
                isDark: isDark,
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
