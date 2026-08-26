import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_controller.dart';
import '../../../untils/app_colors.dart';

class StatisticTopFiltersWidget extends StatelessWidget {
  final TaskController taskController;
  final bool isDark;
  final VoidCallback onRefresh;

  const StatisticTopFiltersWidget({
    super.key,
    required this.taskController,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Obx(() {
        final startDate = taskController.startDate.value;
        final endDate = taskController.endDate.value;

        return Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                const Text('Khoảng thời gian:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              DateTime? currentEnd = endDate != null ? DateTime.tryParse(endDate) : null;
                              taskController.setDateRange(picked, currentEnd);
                              onRefresh();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardItemDark : AppColors.lightBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    startDate ?? 'Từ ngày',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: startDate != null ? (isDark ? AppColors.white : AppColors.black) : AppColors.grey,
                                      fontWeight: startDate != null ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (startDate != null)
                                  GestureDetector(
                                    onTap: () {
                                      DateTime? currentEnd = endDate != null ? DateTime.tryParse(endDate) : null;
                                      taskController.setDateRange(null, currentEnd);
                                      onRefresh();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2),
                                      child: Icon(Icons.close, size: 12, color: AppColors.grey),
                                    ),
                                  )
                                else
                                  Icon(Icons.keyboard_arrow_down, size: 12, color: AppColors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Text('-', style: TextStyle(color: AppColors.grey, fontSize: 10)),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              DateTime? currentStart = startDate != null ? DateTime.tryParse(startDate) : null;
                              taskController.setDateRange(currentStart, picked);
                              onRefresh();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardItemDark : AppColors.lightBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    endDate ?? 'Đến ngày',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: endDate != null ? (isDark ? AppColors.white : AppColors.black) : AppColors.grey,
                                      fontWeight: endDate != null ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (endDate != null)
                                  GestureDetector(
                                    onTap: () {
                                      DateTime? currentStart = startDate != null ? DateTime.tryParse(startDate) : null;
                                      taskController.setDateRange(currentStart, null);
                                      onRefresh();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2),
                                      child: Icon(Icons.close, size: 12, color: AppColors.grey),
                                    ),
                                  )
                                else
                                  Icon(Icons.keyboard_arrow_down, size: 12, color: AppColors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.business_outlined, size: 15, color: AppColors.grey[600]),
                const SizedBox(width: 6),
                const Text('Đơn vị:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardItemDark : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: (taskController.selectedDepartmentId.value != null && taskController.departments.any((d) => d.id == taskController.selectedDepartmentId.value)) ? taskController.selectedDepartmentId.value : null,
                        hint: const Text('Tất cả phòng ban', style: TextStyle(fontSize: 11)),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.grey[600]),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Tất cả phòng ban', style: TextStyle(fontSize: 11)),
                          ),
                          ...{for (var d in taskController.departments) d.id: d}.values.map((dept) {
                            return DropdownMenuItem<int>(
                              value: dept.id,
                              child: Text(dept.name, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          taskController.setDepartment(value);
                          onRefresh();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
