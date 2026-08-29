import 'package:flutter/material.dart';
import '../../../controllers/task_document_controller.dart';
import '../../../core/enums/task_document_enums.dart';
import '../../../untils/app_colors.dart';

class TaskDocumentFilterModal {
  static void show(BuildContext context, TaskDocumentController controller, bool isDark) {
    String tempStatus = controller.selectedStatus.value;
    int? tempDeptId = controller.selectedDepartmentId.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bộ lọc văn bản',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempStatus = 'all';
                            tempDeptId = null;
                          });
                          controller.selectedStatus.value = 'all';
                          controller.selectedDepartmentId.value = null;
                          controller.currentPage.value = 1;
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Đặt lại',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Trạng thái văn bản',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: TaskDocumentStatus.values.map((status) {
                      return _buildFilterChip(
                        status.label,
                        status.key,
                        tempStatus,
                        (v) => setModalState(() => tempStatus = v),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (controller.departments.isNotEmpty) ...[
                    const Text(
                      'Phòng ban',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white10 : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: tempDeptId,
                          hint: const Text('Tất cả phòng ban', style: TextStyle(fontSize: 13)),
                          dropdownColor: isDark ? AppColors.cardDark : AppColors.white,
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Tất cả phòng ban', style: TextStyle(fontSize: 13)),
                            ),
                            ...controller.departments.map(
                              (d) => DropdownMenuItem<int?>(
                                value: d.id,
                                child: Text(d.name, style: const TextStyle(fontSize: 13)),
                              ),
                            ),
                          ],
                          onChanged: (val) => setModalState(() => tempDeptId = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        controller.selectedStatus.value = tempStatus;
                        controller.selectedDepartmentId.value = tempDeptId;
                        controller.currentPage.value = 1;
                        Navigator.pop(ctx);
                      },
                      child: const Text('Áp dụng bộ lọc', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildFilterChip(String label, String value, String current, Function(String) onSelect) {
    final isSelected = value == current;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : AppColors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.borderLight,
      onSelected: (_) => onSelect(value),
    );
  }
}
