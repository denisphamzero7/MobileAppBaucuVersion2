import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/petition_controller.dart';
import '../../../core/widgets/app_advanced_filter_bottom_sheet.dart';
import '../../../model/advanced_filter_data.dart';
import '../../../untils/app_colors.dart';

class PetitionSearchFilterBar extends StatelessWidget {
  final PetitionController controller;
  final TextEditingController searchController;
  final bool isDark;

  const PetitionSearchFilterBar({
    super.key,
    required this.controller,
    required this.searchController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 1. Ô TÌM KIẾM
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (val) {
                    controller.searchText.value = val.trim();
                    controller.currentPage.value = 1;
                    controller.fetchPetitions();
                  },
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm đơn thư, kiến nghị',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.grey),
                    suffixIcon: Obx(() => controller.searchText.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              searchController.clear();
                              controller.searchText.value = '';
                              controller.currentPage.value = 1;
                              controller.fetchPetitions();
                            },
                          )
                        : const SizedBox.shrink()),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 2. NÚT BỘ LỌC NÂNG CAO ĐƠN THƯ
            Obx(() {
              final isFilterActive = controller.advancedFilter.value.isActive;
              final activeCount = controller.advancedFilter.value.activeCount;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isFilterActive
                          ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                          : (isDark ? AppColors.cardDark : AppColors.white),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isFilterActive
                            ? AppColors.primary
                            : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05)),
                        width: isFilterActive ? 1.5 : 1.0,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.filter_alt_outlined,
                        size: 18,
                        color: isFilterActive ? AppColors.primary : AppColors.grey,
                      ),
                      tooltip: 'Bộ lọc nâng cao',
                      onPressed: () {
                        AppAdvancedFilterBottomSheet.show(
                          context,
                          initialData: controller.advancedFilter.value,
                          departments: controller.departments,
                          showPriority: false,
                          onApply: (data) {
                            controller.advancedFilter.value = data;
                            if (data.departmentId != null) {
                              final found = controller.departments.where((d) => d.id == data.departmentId);
                              controller.selectedDepartment.value = found.isNotEmpty ? found.first : null;
                            } else {
                              controller.selectedDepartment.value = null;
                            }
                            controller.currentPage.value = 1;
                            controller.fetchPetitions();
                          },
                          onReset: () {
                            controller.advancedFilter.value = AdvancedFilterData.initial;
                            controller.selectedDepartment.value = null;
                            controller.currentPage.value = 1;
                            controller.fetchPetitions();
                          },
                        );
                      },
                    ),
                  ),
                  if (isFilterActive && activeCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Center(
                          child: Text(
                            '$activeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),

            // 3. NÚT XUẤT EXCEL (KIỂM TRA QUYỀN CASL)
            if (Get.find<AuthController>().can('read', 'TaskAssignmentPetitions')) ...[
              const SizedBox(width: 8),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.white10 : const Color(0xFFECFDF5),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.description_outlined, size: 18, color: Color(0xFF059669)),
                  tooltip: 'Xuất Excel',
                  onPressed: () => controller.exportExcel(),
                ),
              ),
            ],
          ],
        ),

        // 4. HUY HIỆU PHÒNG BAN ĐANG CHỌN
        Obx(() {
          final deptName = controller.advancedFilter.value.departmentName ?? controller.selectedDepartment.value?.name;
          if (deptName == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Phòng ban: $deptName',
                    style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      controller.selectedDepartment.value = null;
                      controller.advancedFilter.value = controller.advancedFilter.value.copyWith(clearDepartment: true);
                      controller.currentPage.value = 1;
                      controller.fetchPetitions();
                    },
                    child: const Icon(Icons.close, size: 14, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
