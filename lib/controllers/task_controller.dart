import 'dart:developer';
import 'package:get/get.dart';
import '../model/task_model.dart';
import '../service/task_service.dart';

class TaskController extends GetxController {
  final TaskService _taskService = TaskService();

  final RxList<TaskModel> tasksList = <TaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _taskService.getTasks();
      if (response != null && response.statusCode == 200 && response.data != null) {
        tasksList.value = response.data!;
        log("✅ Tải danh sách công việc thành công. Số lượng: ${tasksList.length}");
      } else {
        final msg = response?.message ?? "Không thể tải danh sách công việc.";
        errorMessage.value = msg;
        log("❌ Lỗi tải công việc: $msg");
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll("Exception: ", "");
      errorMessage.value = errorMsg;
      log("❌ Ngoại lệ khi tải công việc: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTasks() async {
    await fetchTasks();
  }
}
