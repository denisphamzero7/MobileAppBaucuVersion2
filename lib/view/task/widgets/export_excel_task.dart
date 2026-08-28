import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/export_excel_button.dart';
import '../../../controllers/task_controller.dart';
import '../../../controllers/auth_controller.dart';

class ExportExcelTask extends GetView<TaskController> {
  final String? type;
  final RxString searchText;
  final RxString selectedStatusFilter;
  final RxString selectedTimingFilter;

  const ExportExcelTask({
    super.key,
    this.type,
    required this.searchText,
    required this.selectedStatusFilter,
    required this.selectedTimingFilter,
  });

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final canExport = authCtrl.can('read', 'TaskAssignmentItems');
    if (!canExport) return const SizedBox.shrink();

    return Obx(() {
      final userId = authCtrl.currentUser.value?.id;
      final queryParams = <String, dynamic>{};
      
      if (type == 'received' && userId != null) {
        queryParams['assignee_id'] = userId;
      } else if (type == 'sent' && userId != null) {
        queryParams['assigner_id'] = userId;
      }
      if (type != null && type!.isNotEmpty) {
        queryParams['type'] = type;
      }
      
      if (searchText.value.isNotEmpty) queryParams['search'] = searchText.value;
      if (selectedStatusFilter.value != 'all') queryParams['processing_status'] = selectedStatusFilter.value;
      if (selectedTimingFilter.value != 'all') queryParams['timing_status'] = selectedTimingFilter.value;

      final fileNamePrefix = type == 'received' 
          ? 'CongViecDuocGiao' 
          : (type == 'sent' ? 'CongViecDangGiao' : 'DanhSachCongViec');

      return ExportExcelButton(
        url: 'task-assignment-items/export',
        queryParams: queryParams,
        fileNamePrefix: fileNamePrefix,
      );
    });
  }
}
