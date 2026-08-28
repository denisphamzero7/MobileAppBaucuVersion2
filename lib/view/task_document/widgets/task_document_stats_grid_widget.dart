import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_document_controller.dart';
import '../../../core/enums/task_document_enums.dart';
import '../../task/widgets/stat_card_widget.dart';

class TaskDocumentStatsGridWidget extends StatelessWidget {
  final TaskDocumentController controller;
  final bool isDark;

  const TaskDocumentStatsGridWidget({
    super.key,
    required this.controller,
    required this.isDark,
  });

  int _getCountForStatus(TaskDocumentStatus status) {
    final stats = controller.stats.value;
    switch (status) {
      case TaskDocumentStatus.all:
        return stats.total;
      case TaskDocumentStatus.published:
        return stats.published;
      case TaskDocumentStatus.draft:
        return stats.draft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: TaskDocumentStatus.values.map((status) {
          final isSelected = controller.selectedStatus.value == status.key;
          final count = _getCountForStatus(status);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: StatCardWidget(
                icon: status.icon,
                label: status.label,
                count: count,
                color: status.color,
                isSelected: isSelected,
                onTap: () {
                  if (status == TaskDocumentStatus.all) {
                    controller.selectedStatus.value = 'all';
                  } else {
                    controller.selectedStatus.value =
                        controller.selectedStatus.value == status.key ? 'all' : status.key;
                  }
                  controller.currentPage.value = 1;
                },
                isDark: isDark,
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
