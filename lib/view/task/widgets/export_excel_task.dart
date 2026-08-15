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
    Key? key,
    this.type,
    required this.searchText,
    required this.selectedStatusFilter,
    required this.selectedTimingFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userId = Get.find<AuthController>().currentUser.value?.id;
      final queryParams = <String, dynamic>{};
      
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
