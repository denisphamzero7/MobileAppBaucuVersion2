import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/task_document_controller.dart';
import '../../../untils/app_colors.dart';
import 'task_document_filter_modal.dart';

class TaskDocumentSearchFilterBar extends StatelessWidget {
  final TaskDocumentController controller;
  final TextEditingController searchController;
  final bool isDark;

  const TaskDocumentSearchFilterBar({
    super.key,
    required this.controller,
    required this.searchController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Ô TÌM KIẾM
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.lightBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (val) {
                controller.searchText.value = val;
                controller.currentPage.value = 1;
              },
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm văn bản theo tên, số hiệu...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.grey),
                prefixIcon: Icon(Icons.search, size: 18, color: AppColors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 2. NÚT BỘ LỌC
        Obx(() {
          final bool hasActiveFilter = controller.selectedStatus.value != 'all' || controller.selectedDepartmentId.value != null;
          return Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasActiveFilter
                    ? AppColors.primary
                    : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05)),
                width: hasActiveFilter ? 1.5 : 1.0,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_alt_outlined,
                size: 18,
                color: hasActiveFilter ? AppColors.primary : AppColors.grey,
              ),
              tooltip: 'Bộ lọc',
              onPressed: () => TaskDocumentFilterModal.show(context, controller, isDark),
            ),
          );
        }),

        // 3. NÚT XUẤT EXCEL (KIỂM TRA QUYỀN CASL)
        if (Get.find<AuthController>().can('read', 'TaskAssignmentDocuments')) ...[
          const SizedBox(width: 8),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.badgeGreenBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.white10 : AppColors.borderGreen,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.description_outlined, size: 18, color: AppColors.textGreen),
              tooltip: 'Xuất Excel',
              onPressed: () => controller.exportExcel(),
            ),
          ),
        ],
      ],
    );
  }
}
