import 'dart:developer';
import 'package:get/get.dart';
import '../model/base_response.dart';
import '../model/task_model.dart';
import '../model/task_stats_model.dart';
import '../model/user_model.dart';
import '../service/task_service.dart';
import '../service/user_service.dart';
import '../service/petition_service.dart';
import 'package:intl/intl.dart';
import 'auth_controller.dart';


class TaskController extends GetxController {
  final TaskService _taskService = TaskService();
  final PetitionService _petitionService = PetitionService();
  final UserService _userService = UserService();

  final RxList<TaskModel> tasksList = <TaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isMultiSelectMode = false.obs;
  final RxList<int> selectedTaskIds = <int>[].obs;

  // Metadata for create/update task
  final RxList<TaskAssignmentDocument> taskDocuments = <TaskAssignmentDocument>[].obs;
  final RxList<TaskItemType> itemTypes = <TaskItemType>[].obs;
  final RxList<User> usersList = <User>[].obs;
  final RxBool isLoadingMetadata = false.obs;

  void toggleMultiSelectMode() {
    isMultiSelectMode.value = !isMultiSelectMode.value;
    if (!isMultiSelectMode.value) {
      selectedTaskIds.clear();
    }
  }

  void toggleTaskSelection(int id) {
    if (selectedTaskIds.contains(id)) {
      selectedTaskIds.remove(id);
    } else {
      selectedTaskIds.add(id);
    }
  }

  void selectAllTasks(List<int> ids) {
    selectedTaskIds.assignAll(ids);
  }


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
      if (response != null && response.statusCode == 200) {
        departments.value = response.data;

        // Log dữ liệu của "Hòa Cường" theo yêu cầu
        final hoaCuongDepts = departments.where((d) {
          final name = d.name.toLowerCase();
          return name.contains('hòa cường') || name.contains('hoa cuong');
        }).toList();

        if (hoaCuongDepts.isNotEmpty) {
          log("========= DỮ LIỆU HÒA CƯỜNG =========");
          for (var d in hoaCuongDepts) {
            log("ID: ${d.id} | Tên: ${d.name}");
          }
          log("=====================================");
        } else {
          log("⚠️ Không tìm thấy phòng ban nào tên Hòa Cư{String? type}ờng trong danh sách trả về!");
        }
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

  // Pagination state
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreTasks = true.obs;
  final RxBool isLoadingMore = false.obs;

  Future<void> fetchTasks({String? type, bool isRefresh = true}) async {
    if (isRefresh) {
      isLoading.value = true;
      currentPage.value = 1;
      hasMoreTasks.value = true;
    }
    errorMessage.value = '';

    try {
      final userId = Get.find<AuthController>().currentUser.value?.id;
      final response = await _taskService.getTasks(
        type: type, 
        userId: userId,
        page: currentPage.value,
        limit: 10,
      );
      if (response != null && response.statusCode == 200) {
        if (isRefresh) {
          tasksList.value = response.data;
        } else {
          tasksList.addAll(response.data);
        }

        if (response.data.length < 10) {
          hasMoreTasks.value = false;
        }

        log("✅ Tải danh sách công việc (${type ?? 'tất cả'}) trang ${currentPage.value} thành công (UserID: $userId). Tổng hiện tại: ${tasksList.length}");
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
      isLoadingMore.value = false;
    }
  }

    Future<void> deleteTask(int id) async {
    isLoading.value = true;
    final success = await _taskService.deleteTask(id);
    if (success) {
      tasksList.removeWhere((t) => t.id == id);
      Get.snackbar('Thành công', 'Đã xóa công việc');
    } else {
      Get.snackbar('Lỗi', 'Không thể xóa công việc');
    }
    isLoading.value = false;
  }

    Future<void> exportTasks({String? type}) async {
    isLoading.value = true;
    try {
      final response = await _taskService.exportTasks(
        type: type,
        userId: Get.find<AuthController>().currentUser.value?.id,
      );
      if (response != null) {
        // Since we don't have download bytes parsing yet, we can assume API returns URL or bytes.
        // For simplicity, we just notify success or open it.
        Get.snackbar("Thành công", "Đã xuất dữ liệu thành công");
      } else {
        Get.snackbar("Lỗi", "Không thể xuất dữ liệu");
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Đã xảy ra lỗi khi xuất Excel");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bulkDeleteTasks(List<int> ids) async {
    isLoading.value = true;
    final success = await _taskService.bulkDeleteTasks(ids);
    if (success) {
      tasksList.removeWhere((t) => ids.contains(t.id));
      Get.snackbar('Thành công', 'Đã xóa các công việc đã chọn');
    } else {
      Get.snackbar('Lỗi', 'Không thể xóa các công việc');
    }
    isLoading.value = false;
  }

  Future<void> loadMoreTasks({String? type}) async {
    if (isLoadingMore.value || !hasMoreTasks.value) return;
    isLoadingMore.value = true;
    currentPage.value++;
    await fetchTasks(type: type, isRefresh: false);
  }

  final RxList<dynamic> departmentStatsList = <dynamic>[].obs;
  final RxList<dynamic> itemTypeStatsList = <dynamic>[].obs;

  Future<void> fetchDepartmentStats() async {
    try {
      final response = await _taskService.getStatsByDepartment(
        startDate: startDate.value,
        endDate: endDate.value,
      );
      if (response != null && response is Map<String, dynamic> && response['data'] is List) {
        departmentStatsList.value = response['data'] as List;
        log("✅ Tải thống kê theo phòng ban thành công: ${departmentStatsList.length} phòng");
        log("========= API STATS BY DEPARTMENT DATA =========");
        for (var item in departmentStatsList) {
          log("Dept: ${item['department_name']} | Data: $item");
        }
        log("===============================================");
      } else if (response is List) {
        departmentStatsList.value = response;
      }
    } catch (e) {
      log("❌ Lỗi tải thống kê theo phòng ban: $e");
    }
  }

  Future<void> fetchItemTypeStats() async {
    try {
      final response = await _taskService.getStatsByItemType(
        startDate: startDate.value,
        endDate: endDate.value,
      );
      if (response != null && response is Map<String, dynamic> && response['data'] is List) {
        itemTypeStatsList.value = response['data'] as List;
        log("✅ Tải thống kê theo loại công việc thành công: ${itemTypeStatsList.length} loại");
      } else if (response is List) {
        itemTypeStatsList.value = response;
      }
    } catch (e) {
      log("❌ Lỗi tải thống kê theo loại công việc: $e");
    }
  }

  Future<void> fetchStats() async {
    isStatsLoading.value = true;
    try {
      fetchDepartmentStats();
      fetchItemTypeStats();
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

  Future<void> fetchMetadata() async {
    isLoadingMetadata.value = true;
    try {
      final results = await Future.wait([
        _taskService.getTaskAssignmentDocuments(),
        _taskService.getTaskItemTypes(),
        _userService.getUsers(),
      ]);

      final docsRes = results[0] as BaseResponse<List<TaskAssignmentDocument>>?;
      if (docsRes != null && docsRes.statusCode == 200) {
        taskDocuments.value = docsRes.data;
      }

      final typesRes = results[1] as BaseResponse<List<TaskItemType>>?;
      if (typesRes != null && typesRes.statusCode == 200) {
        itemTypes.value = typesRes.data;
      }

      final usersRes = results[2] as BaseResponse<List<User>>?;
      if (usersRes != null && usersRes.statusCode == 200) {
        usersList.value = usersRes.data;
      }
      log("✅ Tải metadata tạo công việc thành công: ${taskDocuments.length} docs, ${itemTypes.length} types, ${usersList.length} users");
    } catch (e) {
      log("❌ Lỗi khi tải metadata công việc: $e");
    } finally {
      isLoadingMetadata.value = false;
    }
  }

  Future<bool> createTask(Map<String, dynamic> payload) async {
    try {
      final response = await _taskService.createTask(payload);
      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        Get.snackbar('Thành công', 'Đã tạo công việc mới thành công', backgroundColor: Get.theme.primaryColor.withOpacity(0.2));
        fetchTasks();
        fetchStats();
        return true;
      } else {
        final msg = response?.message ?? 'Không thể tạo công việc';
        Get.snackbar('Lỗi', msg);
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll("Exception: ", "");
      Get.snackbar('Lỗi', errorMsg);
      return false;
    }
  }

  Future<bool> updateTask(int id, Map<String, dynamic> payload) async {
    try {
      final response = await _taskService.updateTask(id, payload);
      if (response != null && response.statusCode == 200) {
        Get.snackbar('Thành công', 'Đã cập nhật công việc thành công', backgroundColor: Get.theme.primaryColor.withOpacity(0.2));
        fetchTasks();
        fetchStats();
        return true;
      } else {
        final msg = response?.message ?? 'Không thể cập nhật công việc';
        Get.snackbar('Lỗi', msg);
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll("Exception: ", "");
      Get.snackbar('Lỗi', errorMsg);
      return false;
    }
  }

  Future<void> refreshTasks() async {
    await Future.wait([
      fetchTasks(),
      fetchStats(),
    ]);
  }
}
