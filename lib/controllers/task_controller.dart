import 'dart:developer';
import 'package:get/get.dart';
import '../model/task_model.dart';
import '../model/task_stats_model.dart';
import '../service/task_service.dart';
import '../service/petition_service.dart';
import 'package:intl/intl.dart';

class TaskController extends GetxController {
  final TaskService _taskService = TaskService();
  final PetitionService _petitionService = PetitionService();

  final RxList<TaskModel> tasksList = <TaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<TaskStatsModel> stats = TaskStatsModel.empty().obs;
  final RxBool isStatsLoading = false.obs;

  // Filters for stats
  final RxnString startDate = RxnString(null);
  final RxnString endDate = RxnString(null);
  final RxnInt selectedDepartmentId = RxnInt(null);

  // Departments list
  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDepartments();
    fetchTasks();
    fetchStats();
  }

  Future<void> fetchDepartments() async {
    try {
      final response = await _petitionService.getAvailableDepartments();
      if (response != null && response.statusCode == 200 && response.data != null) {
        departments.value = response.data!;
      }
    } catch (e) {
      log("❌ Lỗi khi tải danh sách phòng ban: $e");
    }
  }

  void setDateRange(DateTime? start, DateTime? end) {
    if (start != null) {
      startDate.value = DateFormat('yyyy-MM-dd').format(start);
    } else {
      startDate.value = null;
    }
    
    if (end != null) {
      endDate.value = DateFormat('yyyy-MM-dd').format(end);
    } else {
      endDate.value = null;
    }
    fetchStats();
  }

  void setDepartment(int? deptId) {
    selectedDepartmentId.value = deptId;
    fetchStats();
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

  Future<void> fetchStats() async {
    isStatsLoading.value = true;
    try {
      final response = await _taskService.getTaskStats(
        startDate: startDate.value,
        endDate: endDate.value,
        departmentId: selectedDepartmentId.value,
      );
      if (response != null && response['success'] == true && response['data'] != null) {
        stats.value = TaskStatsModel.fromJson(response['data'] as Map<String, dynamic>);
        log("✅ Tải thống kê công việc thành công: ${stats.value.total}");
      } else {
        _setMockStats();
      }
    } catch (e) {
      log("❌ Lỗi khi tải thống kê công việc: $e");
      _setMockStats();
    } finally {
      isStatsLoading.value = false;
    }
  }

  void _setMockStats() {
    stats.value = TaskStatsModel.fromJson({
      "total": 61,
      "todo": 17,
      "in_progress": 18,
      "pending_approval": 1,
      "done": 25,
      "paused": 0,
      "cancelled": 0,
      "timing_stats": {
        "upcoming": 19,
        "early": 21,
        "on_time": 1,
        "late": 3,
        "overdue": 17,
        "cancelled": 0
      }
    });
  }

  Future<void> refreshTasks() async {
    await Future.wait([
      fetchTasks(),
      fetchStats(),
    ]);
  }
}
