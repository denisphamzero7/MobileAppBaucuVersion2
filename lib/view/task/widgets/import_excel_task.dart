import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/import_excel_button.dart';
import '../../../controllers/task_controller.dart';

class ImportExcelTask extends GetView<TaskController> {
  const ImportExcelTask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImportExcelButton(
      uploadUrl: 'task-assignment-items/import', // API giả định theo chuẩn hệ thống
      tooltip: 'Nhập công việc từ Excel',
      onSuccess: () {
        // Tải lại danh sách sau khi import thành công
        controller.refreshTasks();
      },
    );
  }
}
