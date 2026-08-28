import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/advanced_filter_data.dart';
import '../model/department_model.dart';
import '../service/petition_service.dart';
import '../controllers/auth_controller.dart';
import '../core/widgets/export_excel_button.dart';

class PetitionController extends GetxController {
  final PetitionService _petitionService = PetitionService();

  // ==========================================
  // 1. OBSERVABLE STATE (DỮ LIỆU PHẢN ỨNG)
  // ==========================================
  final RxList<PetitionItemModel> petitionsList = <PetitionItemModel>[].obs;
  final Rx<PetitionStatsModel> stats = PetitionStatsModel().obs;
  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  final Rxn<DepartmentModel> selectedDepartment = Rxn<DepartmentModel>();

  // Filter & Search
  final RxString selectedStatusFilter = 'all'.obs;
  final Rx<AdvancedFilterData> advancedFilter = AdvancedFilterData.initial.obs;
  final RxString searchText = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool isPageChanging = false.obs;
  static const int itemsPerPage = 10;

  // Loading & Refresh State
  final RxBool isLoading = true.obs;
  final RxBool isInitialLoaded = false.obs;
  final RxBool isManualRefreshing = false.obs;

  // Multi-select & Bulk Delete
  final RxBool isMultiSelectMode = false.obs;
  final RxSet<int> selectedPetitionIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  // ==========================================
  // 2. FETCH DATA & API LOGIC
  // ==========================================
  Future<void> fetchInitialData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchPetitions(),
        fetchStats(),
        fetchDepartments(),
      ]);
    } finally {
      isLoading.value = false;
      isInitialLoaded.value = true;
    }
  }

  Future<void> onRefresh() async {
    isManualRefreshing.value = true;
    currentPage.value = 1;
    await fetchInitialData();
    isManualRefreshing.value = false;
  }

  Future<void> fetchPetitions() async {
    final response = await _petitionService.getPetitions(
      search: searchText.value.isNotEmpty ? searchText.value : null,
      processingStatus: selectedStatusFilter.value != 'all' ? selectedStatusFilter.value : null,
      departmentId: selectedDepartment.value?.id,
    );
    if (response != null && response.statusCode == 200) {
      petitionsList.assignAll(response.data);
    } else {
      petitionsList.clear();
    }
  }

  Future<void> fetchStats() async {
    final res = await _petitionService.getPetitionStats();
    if (res != null) {
      stats.value = res;
    }
  }

  Future<void> fetchDepartments() async {
    final response = await _petitionService.getAvailableDepartments();
    if (response != null && response.statusCode == 200) {
      departments.assignAll(response.data);
    }
  }

  // ==========================================
  // 3. PAGINATION & NAVIGATION
  // ==========================================
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
  // 4. MULTI-SELECT & ACTIONS
  // ==========================================
  void toggleMultiSelectMode() {
    isMultiSelectMode.value = !isMultiSelectMode.value;
    if (!isMultiSelectMode.value) {
      selectedPetitionIds.clear();
    }
  }

  void togglePetitionSelection(int id) {
    if (selectedPetitionIds.contains(id)) {
      selectedPetitionIds.remove(id);
    } else {
      selectedPetitionIds.add(id);
    }
  }

  Future<void> deleteSinglePetition(int id) async {
    final success = await _petitionService.deletePetition(id);
    if (success) {
      petitionsList.removeWhere((p) => p.id == id);
      Get.snackbar(
        'Thành công',
        'Đã xóa đơn thư thành công',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      fetchStats();
    } else {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa đơn thư này',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      onRefresh();
    }
  }

  Future<void> bulkDeleteSelected() async {
    if (selectedPetitionIds.isEmpty) return;
    final idsToDelete = selectedPetitionIds.toList();
    final success = await _petitionService.bulkDeletePetitions(idsToDelete);
    if (success) {
      petitionsList.removeWhere((p) => idsToDelete.contains(p.id));
      Get.snackbar(
        'Thành công',
        'Đã xóa ${idsToDelete.length} đơn thư được chọn',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      selectedPetitionIds.clear();
      isMultiSelectMode.value = false;
      fetchStats();
    } else {
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra khi xóa hàng loạt',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      onRefresh();
    }
  }

  Future<bool> createPetition(Map<String, dynamic> data) async {
    try {
      final res = await _petitionService.createPetition(data);
      if (res != null) {
        onRefresh();
        return true;
      }
      return false;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Lỗi tạo đơn thư',
        msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return false;
    }
  }

  Future<bool> updatePetition(int id, Map<String, dynamic> data) async {
    try {
      final res = await _petitionService.updatePetition(id, data);
      if (res != null) {
        onRefresh();
        return true;
      }
      return false;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Lỗi cập nhật',
        msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return false;
    }
  }

  void exportExcel() {
    final authCtrl = Get.find<AuthController>();
    final canExport = authCtrl.can('read', 'TaskAssignmentPetitions');
    if (!canExport) {
      Get.snackbar('Thông báo', 'Bạn không có quyền xuất dữ liệu đơn thư.');
      return;
    }

    final queryParams = <String, dynamic>{};
    if (searchText.value.isNotEmpty) queryParams['search'] = searchText.value;
    if (selectedStatusFilter.value != 'all') queryParams['processing_status'] = selectedStatusFilter.value;
    if (selectedDepartment.value != null) queryParams['department_id'] = selectedDepartment.value!.id;

    ExportExcelButton.downloadAndSave(
      url: 'task-assignment-petitions/export',
      queryParams: queryParams,
      fileNamePrefix: 'DonThuKienNghi',
    );
  }
}
