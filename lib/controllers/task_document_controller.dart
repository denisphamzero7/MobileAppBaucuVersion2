import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/department_model.dart';
import '../model/task_assignment_document_model.dart';
import '../service/task_assignment_documents_service.dart';
import '../controllers/auth_controller.dart';
import '../core/widgets/export_excel_button.dart';

class TaskDocumentController extends GetxController {
  final TaskAssignmentDocumentsService _docService = TaskAssignmentDocumentsService();

  // ==========================================
  // 1. OBSERVABLE STATE (DỮ LIỆU PHẢN ỨNG)
  // ==========================================
  final RxList<TaskAssignmentDocumentModel> allDocuments = <TaskAssignmentDocumentModel>[].obs;
  final Rx<TaskAssignmentDocumentStatsModel> stats = TaskAssignmentDocumentStatsModel().obs;
  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;

  // Filter & Search
  final RxString selectedStatus = 'all'.obs; // 'all', 'published', 'draft'
  final Rx<int?> selectedDepartmentId = Rx<int?>(null);
  final RxString searchText = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool isPageChanging = false.obs;
  static const int perPage = 10;

  // Loading & Multi-select
  final RxBool isLoading = true.obs;
  final RxBool isInitialLoaded = false.obs;
  final RxBool isManualRefreshing = false.obs;
  final RxBool isMultiSelectMode = false.obs;
  final RxSet<int> selectedDocIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  // ==========================================
  // 2. FETCH DATA & API LOGIC
  // ==========================================
  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchDepartments(),
        fetchStats(),
        fetchDocuments(),
      ]);
    } finally {
      isLoading.value = false;
      isInitialLoaded.value = true;
    }
  }

  Future<void> onRefresh() async {
    isManualRefreshing.value = true;
    currentPage.value = 1;
    await loadInitialData();
    isManualRefreshing.value = false;
  }

  Future<void> fetchDepartments() async {
    final res = await _docService.getAvailableDepartments();
    if (res != null) {
      departments.assignAll(res.data);
    }
  }

  Future<void> fetchStats() async {
    final res = await _docService.getStats(
      departmentId: selectedDepartmentId.value,
    );
    if (res != null) {
      stats.value = res.data;
    }
  }

  Future<void> fetchDocuments() async {
    try {
      final res = await _docService.getDocuments(
        page: 1,
        perPage: 100,
        search: searchText.value.trim(),
        departmentId: selectedDepartmentId.value,
      );

      if (res != null) {
        allDocuments.assignAll(res.data);

        // Tự động tính toán lại thống kê nếu API không trả về
        if (stats.value.total == 0 && res.data.isNotEmpty) {
          int pub = res.data.where((d) => d.isPublished).length;
          int draft = res.data.where((d) => d.isDraft).length;
          stats.value = TaskAssignmentDocumentStatsModel(
            total: res.data.length,
            published: pub,
            draft: draft,
          );
        }
      }
    } catch (_) {}
  }

  // ==========================================
  // 3. FILTERING & PAGINATION
  // ==========================================
  List<TaskAssignmentDocumentModel> getFilteredDocuments() {
    final search = searchText.value.trim().toLowerCase();
    return allDocuments.where((doc) {
      // 1. Lọc theo từ khóa tìm kiếm
      if (search.isNotEmpty) {
        final matchTitle = doc.title.toLowerCase().contains(search);
        final matchCode = doc.documentNumber?.toLowerCase().contains(search) ?? false;
        final matchDesc = doc.description?.toLowerCase().contains(search) ?? false;
        if (!matchTitle && !matchCode && !matchDesc) return false;
      }

      // 2. Lọc theo trạng thái ban hành
      if (selectedStatus.value == 'published' && !doc.isPublished) return false;
      if (selectedStatus.value == 'draft' && !doc.isDraft) return false;

      // 3. Lọc theo phòng ban
      if (selectedDepartmentId.value != null && doc.departmentId != selectedDepartmentId.value) {
        return false;
      }

      return true;
    }).toList();
  }

  void changePage(int newPage, ScrollController? scrollController) {
    if (newPage == currentPage.value || newPage < 1) return;
    isPageChanging.value = true;
    currentPage.value = newPage;

    if (scrollController != null && scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }

    Future.delayed(const Duration(milliseconds: 250), () {
      isPageChanging.value = false;
    });
  }

  // ==========================================
  // 4. MULTI-SELECT & DELETE ACTIONS
  // ==========================================
  void toggleMultiSelectMode() {
    isMultiSelectMode.toggle();
    if (!isMultiSelectMode.value) {
      selectedDocIds.clear();
    }
  }

  void toggleDocumentSelection(int id) {
    if (selectedDocIds.contains(id)) {
      selectedDocIds.remove(id);
      if (selectedDocIds.isEmpty) {
        isMultiSelectMode.value = false;
      }
    } else {
      selectedDocIds.add(id);
    }
  }

  Future<void> deleteSingleDocument(int id) async {
    final success = await _docService.deleteDocument(id);
    if (success) {
      allDocuments.removeWhere((d) => d.id == id);
      Get.snackbar('Thành công', 'Đã xóa văn bản', backgroundColor: Colors.green, colorText: Colors.white);
      fetchStats();
    } else {
      Get.snackbar('Lỗi', 'Xóa văn bản thất bại', backgroundColor: Colors.red, colorText: Colors.white);
      onRefresh();
    }
  }

  Future<void> bulkDeleteSelected() async {
    if (selectedDocIds.isEmpty) return;
    final idsToDelete = selectedDocIds.toList();
    final success = await _docService.bulkDeleteDocuments(idsToDelete);
    if (success) {
      allDocuments.removeWhere((d) => idsToDelete.contains(d.id));
      Get.snackbar('Thành công', 'Đã xóa ${idsToDelete.length} văn bản', backgroundColor: Colors.green, colorText: Colors.white);
      selectedDocIds.clear();
      isMultiSelectMode.value = false;
      fetchStats();
    } else {
      Get.snackbar('Lỗi', 'Xóa thất bại', backgroundColor: Colors.red, colorText: Colors.white);
      onRefresh();
    }
  }

  void exportExcel() {
    final authCtrl = Get.find<AuthController>();
    final canExport = authCtrl.can('read', 'TaskAssignmentDocuments');
    if (!canExport) {
      Get.snackbar('Thông báo', 'Bạn không có quyền xuất dữ liệu văn bản giao việc.');
      return;
    }

    final Map<String, dynamic> queryParams = {};
    if (selectedStatus.value != 'all') queryParams['status'] = selectedStatus.value;
    if (selectedDepartmentId.value != null) queryParams['department_id'] = selectedDepartmentId.value;

    ExportExcelButton.downloadAndSave(
      url: 'task-assignment-documents/export',
      queryParams: queryParams,
      fileNamePrefix: 'VanBanGiaoViec',
    );
  }
}
