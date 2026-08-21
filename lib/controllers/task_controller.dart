import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api_constants.dart';
import '../core/widgets/import_excel_button.dart';
import '../core/widgets/export_excel_button.dart';
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

  /// ============================================================================
  /// 📦 1. QUẢN LÝ DANH SÁCH CÔNG VIỆC THEO TAB
  /// ============================================================================
  
  /// Danh sách công việc chung (Toàn bộ / Mới nhất tại Trang chủ)
  final RxList<TaskModel> tasksList = <TaskModel>[].obs;
  /// Danh sách công việc tôi đã giao (Tab "Đang giao" - type: 'sent')
  final RxList<TaskModel> sentTasksList = <TaskModel>[].obs;
  /// Danh sách công việc tôi được giao (Tab "Được giao" - type: 'received')
  final RxList<TaskModel> receivedTasksList = <TaskModel>[].obs;

  /// Helper lấy danh sách RxList tương ứng với từng Tab
  RxList<TaskModel> getTasksList(String? type) {
    if (type == 'sent') return sentTasksList;
    if (type == 'received') return receivedTasksList;
    return tasksList;
  }

  /// ============================================================================
  /// ⏳ 2. QUẢN LÝ TRẠNG THÁI LOADING THÔNG MINH
  /// ============================================================================

  /// Cờ loading chung
  final RxBool isLoading = false.obs;
  /// Map theo dõi trạng thái loading độc lập cho từng tab ('sent', 'received', 'all')
  final RxMap<String, bool> isLoadingMap = <String, bool>{}.obs;
  /// Tập hợp lưu các tab đã tải xong lần đầu (Dùng để quyết định kích hoạt Full Skeleton)
  final RxSet<String> initialLoadedTypes = <String>{}.obs;
  /// Cờ xác định người dùng đang chủ động vuốt màn hình để làm mới (Pull-to-refresh)
  final RxBool isManualRefreshing = false.obs;

  /// Kiểm tra tab hiện tại có đang trong trạng thái cần hiển thị Skeleton hay không.
  /// Trả về `true` nếu:
  /// - Tab đang thực hiện request mạng (`isLoadingMap[key] == true`)
  /// - Tab này chưa từng tải xong lần đầu (`!initialLoadedTypes.contains(key)`)
  bool isTypeLoading(String? type) {
    final key = type ?? 'all';
    if (isLoadingMap[key] == true) return true;
    if (!initialLoadedTypes.contains(key)) return true;
    return false;
  }

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

  /// Dữ liệu thống kê số liệu (Dùng cho Trang chủ & Trang Thống kê)
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
    fetchStats();
  }

  /// Tải mới toàn bộ dữ liệu (công việc chung, đang giao, được giao, thống kê)
  Future<void> refreshTasks() async {
    await Future.wait([
      fetchTasks(type: null, isRefresh: true),
      fetchTasks(type: 'sent', isRefresh: true),
      fetchTasks(type: 'received', isRefresh: true),
      fetchStats(),
    ]);
  }

  /// Tải danh sách phòng ban từ máy chủ
  Future<void> fetchDepartments() async {
    try {
      final response = await _petitionService.getAvailableDepartments();
      if (response != null && response.statusCode == 200) {
        departments.value = response.data;
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

  Future<void> fetchTasks({
    String? type, 
    bool isRefresh = true, 
    bool isManualPull = false,
    int limit = 50,
  }) async {
    final targetList = getTasksList(type);
    final key = type ?? 'all';
    
    if (isManualPull) {
      isManualRefreshing.value = true;
    }

    isLoadingMap[key] = true;
    isLoading.value = true;

    if (isRefresh) {
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
        limit: limit,
      );
      if (response != null && response.statusCode == 200) {
        if (isRefresh) {
          targetList.assignAll(response.data);
        } else {
          final existingIds = targetList.map((t) => t.id).toSet();
          final newTasks = response.data.where((t) => !existingIds.contains(t.id)).toList();
          targetList.addAll(newTasks);
        }

        if (response.data.length < limit) {
          hasMoreTasks.value = false;
        } else {
          hasMoreTasks.value = true;
        }

        log("✅ Tải danh sách công việc (${type ?? 'tất cả'}) trang ${currentPage.value} thành công (nhận ${response.data.length} mục). Tổng hiện tại: ${targetList.length}");
      } else {
        if (isRefresh) {
          targetList.clear();
        }
        hasMoreTasks.value = false;
        final msg = response?.message ?? "Không thể tải danh sách công việc.";
        if (msg.contains("quyền") || msg.toLowerCase().contains("unauthorized") || msg.contains("403")) {
          errorMessage.value = '';
        } else {
          errorMessage.value = msg;
        }
        log("ℹ️ Tải danh sách công việc: $msg");
      }
    } catch (e) {
      if (isRefresh) {
        targetList.clear();
      }
      hasMoreTasks.value = false;
      final errorMsg = e.toString().replaceAll("Exception: ", "");
      if (errorMsg.contains("quyền") || errorMsg.toLowerCase().contains("unauthorized") || errorMsg.contains("403")) {
        errorMessage.value = '';
      } else {
        errorMessage.value = errorMsg;
      }
      log("ℹ️ Ngoại lệ khi tải công việc: $e");
    } finally {
      isLoadingMap[key] = false;
      isLoading.value = isLoadingMap.values.any((val) => val == true);
      isLoadingMore.value = false;
      isManualRefreshing.value = false;
      initialLoadedTypes.add(key);
    }
  }


  Future<void> deleteTask(int id) async {
    sentTasksList.removeWhere((t) => t.id == id);
    receivedTasksList.removeWhere((t) => t.id == id);
    tasksList.removeWhere((t) => t.id == id);

    try {
      final success = await _taskService.deleteTask(id);
      if (success) {
        Get.snackbar(
          'Thành công',
          'Đã xóa công việc thành công',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        fetchStats();
      } else {
        Get.snackbar('Lỗi', 'Không thể xóa công việc', backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi xóa công việc: $e', backgroundColor: Colors.red.shade100);
    }
  }


  Future<void> exportTasks({String? type}) async {
    isLoading.value = true;
    try {
      final response = await _taskService.exportTasks(
        type: type,
        userId: Get.find<AuthController>().currentUser.value?.id,
      );
      if (response != null) {
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
      sentTasksList.removeWhere((t) => ids.contains(t.id));
      receivedTasksList.removeWhere((t) => ids.contains(t.id));
      tasksList.removeWhere((t) => ids.contains(t.id));
      Get.snackbar('Thành công', 'Đã xóa các công việc đã chọn');
      fetchStats();
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
      }
    } catch (e) {
      log("❌ Lỗi khi tải thống kê theo phòng ban: $e");
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
      }
    } catch (e) {
      log("❌ Lỗi khi tải thống kê theo loại công việc: $e");
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
      if (response != null && response['data'] is Map<String, dynamic>) {
        stats.value = TaskStatsModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      await Future.wait([
        fetchDepartmentStats(),
        fetchItemTypeStats(),
      ]);
    } catch (e) {
      log("❌ Lỗi tải thống kê: $e");
    } finally {
      isStatsLoading.value = false;
    }
  }


  Future<void> fetchMetadata() async {
    isLoadingMetadata.value = true;
    try {
      final results = await Future.wait([
        _taskService.getTaskAssignmentDocuments(),
        _taskService.getTaskItemTypes(),
        _taskService.getTaskDepartments(),
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

      final deptsRes = results[2] as BaseResponse<List<DepartmentModel>>?;
      if (deptsRes != null && deptsRes.statusCode == 200 && deptsRes.data.isNotEmpty) {
        departments.value = deptsRes.data;
      }

      final usersRes = results[3] as BaseResponse<List<User>>?;
      final globalUsers = (usersRes != null && usersRes.statusCode == 200) ? usersRes.data : <User>[];

      // Tải danh sách nhân viên hợp lệ đã đăng ký trong các phòng ban Task Assignment
      final List<User> validTaskUsers = [];
      for (var dept in departments) {
        final deptUsersRes = await _taskService.getDepartmentUsers(dept.id);
        if (deptUsersRes != null && deptUsersRes.statusCode == 200) {
          validTaskUsers.addAll(deptUsersRes.data);
        }
      }

      if (validTaskUsers.isNotEmpty) {
        final uniqueUsers = <int, User>{};
        for (var u in validTaskUsers) {
          uniqueUsers[u.id] = u;
        }
        usersList.value = uniqueUsers.values.toList();
      } else {
        usersList.value = globalUsers;
      }

      log("✅ Tải metadata tạo công việc thành công: ${taskDocuments.length} docs, ${itemTypes.length} types, ${departments.length} depts, ${usersList.length} task users");
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
        fetchTasks();
        fetchStats();
        return true;
      } else {
        final msg = response?.message ?? 'Không thể tạo công việc';
        Get.snackbar('Lỗi', msg, backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll("Exception: ", "");
      Get.snackbar('Lỗi', errorMsg, backgroundColor: Colors.red.shade100);
      return false;
    }
  }

  Future<bool> updateTask(int id, Map<String, dynamic> payload) async {
    try {
      final response = await _taskService.updateTask(id, payload);
      if (response != null && response.statusCode == 200) {
        fetchTasks(type: 'sent');
        fetchTasks(type: 'received');
        fetchTasks(type: null);
        fetchStats();
        return true;
      } else {
        final msg = response?.message ?? 'Không thể cập nhật công việc';
        Get.snackbar('Lỗi', msg, backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll("Exception: ", "");
      Get.snackbar('Lỗi', errorMsg, backgroundColor: Colors.red.shade100);
      return false;
    }
  }

  /// Tạm dừng hoặc tiếp tục công việc
  Future<bool> togglePauseTask(TaskModel task) async {
    final newStatus = task.processingStatus == 'paused' ? 'in_progress' : 'paused';
    final actionName = newStatus == 'paused' ? 'Tạm dừng' : 'Tiếp tục';
    
    final payload = <String, dynamic>{
      'name': task.name,
      'processing_status': newStatus,
    };
    
    final success = await updateTask(task.id, payload);
    if (success) {
      Get.snackbar(
        'Thành công',
        '$actionName công việc thành công',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    }
    return success;
  }

  /// Hủy công việc
  Future<bool> cancelTaskStatus(TaskModel task) async {
    final payload = <String, dynamic>{
      'name': task.name,
      'processing_status': 'cancelled',
    };
    
    final success = await updateTask(task.id, payload);
    if (success) {
      Get.snackbar(
        'Thành công',
        'Đã hủy công việc thành công',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
    return success;
  }

  /// Điều chuyển công việc cho người dùng mới
  Future<bool> reassignTask(TaskModel task, int newUserId, {String? newUserName}) async {
    final userObj = usersList.firstWhereOrNull((u) => u.id == newUserId);
    final defaultDeptId = departments.isNotEmpty ? departments.first.id : 1;
    final deptId = userObj?.departmentId ?? defaultDeptId;

    final payload = <String, dynamic>{
      'name': task.name,
      'assignee_ids': [newUserId],
      'user_ids': [newUserId],
      'users': [
        {
          'user_id': newUserId,
          'department_id': deptId,
          'department_role': userObj?.departmentRole ?? 'main',
          'assignment_role': userObj?.assignmentRole ?? 'main',
        }
      ],
    };

    final success = await updateTask(task.id, payload);
    if (success) {
      Get.snackbar(
        'Thành công',
        'Đã điều chuyển công việc cho ${newUserName ?? userObj?.name ?? 'nhân viên mới'}',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    }
    return success;
  }

  /// Nộp báo cáo tiến độ mới
  Future<bool> submitProgressReport(TaskModel task, int newPercent, String? note) async {
    final status = newPercent >= 100 ? 'done' : (task.processingStatus == 'todo' ? 'in_progress' : task.processingStatus);
    final payload = <String, dynamic>{
      'name': task.name,
      'completion_percent': newPercent,
      'processing_status': status,
    };
    if (note != null && note.isNotEmpty) {
      payload['report_note'] = note;
    }

    final success = await updateTask(task.id, payload);
    if (success) {
      Get.snackbar(
        'Thành công',
        'Đã cập nhật tiến độ $newPercent%',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    }
    return success;
  }

  /// ============================================================================
  /// 📊 3. NGHIỆP VỤ NHẬP / XUẤT DỮ LIỆU EXCEL (CHUẨN MVVM - KHÔNG HARDCODE URL)
  /// ============================================================================

  /// Nhập danh sách công việc từ file Excel và tự động làm mới dữ liệu
  Future<void> importExcel() async {
    await ImportExcelButton.pickAndUpload(
      uploadUrl: ApiConstants.taskImport,
      onSuccess: () => refreshTasks(),
    );
  }

  /// Xuất danh sách công việc ra file Excel và lưu vào máy
  Future<void> exportExcel({
    required Map<String, dynamic> queryParams,
    required String fileNamePrefix,
  }) async {
    await ExportExcelButton.downloadAndSave(
      url: ApiConstants.taskExport,
      queryParams: queryParams,
      fileNamePrefix: fileNamePrefix,
    );
  }
}
