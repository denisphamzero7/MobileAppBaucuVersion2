import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ============================================================================
/// 🏛️ [BaseListController<T>] - CONTROLLER CƠ SỞ CHO MỌI MODULE DANH SÁCH
/// ============================================================================
/// Cung cấp sẵn 100% các biến trạng thái và hàm xử lý chuẩn:
/// - Smart Loading: `isLoading`, `isInitialLoaded`, `isManualRefreshing`
/// - Phân trang: `currentPage`, `isPageChanging`, `perPage`, `changePage()`
/// - Tìm kiếm & Lọc: `searchText`, `selectedStatus`
/// - Chọn nhiều: `isMultiSelectMode`, `selectedIds`, `toggleSelection()`
abstract class BaseListController<T> extends GetxController {
  // 1. Danh sách dữ liệu chính
  final RxList<T> allItems = <T>[].obs;

  // 2. Trạng thái Loading thông minh (Smart Skeleton)
  final RxBool isLoading = true.obs;
  final RxBool isInitialLoaded = false.obs;
  final RxBool isManualRefreshing = false.obs;

  // 3. Quản lý phân trang (Pagination)
  final RxInt currentPage = 1.obs;
  final RxBool isPageChanging = false.obs;
  int get perPage => 10;

  // 4. Tìm kiếm & Lọc trạng thái
  final RxString searchText = ''.obs;
  final RxString selectedStatus = 'all'.obs;

  // 5. Chế độ chọn nhiều & Xóa hàng loạt
  final RxBool isMultiSelectMode = false.obs;
  final RxSet<int> selectedIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// Hàm trừu tượng tải dữ liệu ban đầu (Module con bắt buộc triển khai)
  Future<void> loadData();

  /// Nạp dữ liệu lần đầu có cờ isLoading kích hoạt Skeleton Shimmer
  Future<void> loadInitialData() async {
    isLoading.value = true;
    try {
      await loadData();
    } finally {
      isLoading.value = false;
      isInitialLoaded.value = true;
    }
  }

  /// Làm mới dữ liệu (Pull-to-refresh)
  Future<void> onRefresh() async {
    isManualRefreshing.value = true;
    currentPage.value = 1;
    await loadInitialData();
    isManualRefreshing.value = false;
  }

  /// Chuyển trang mượt mà kèm hiệu ứng cuộn êm
  void changePage(int newPage, ScrollController? scrollController) {
    if (newPage == currentPage.value || newPage < 1) return;
    isPageChanging.value = true;
    currentPage.value = newPage;

    if (scrollController != null && scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      isPageChanging.value = false;
    });
  }

  /// Bật / Tắt chế độ chọn nhiều
  void toggleMultiSelectMode() {
    isMultiSelectMode.toggle();
    if (!isMultiSelectMode.value) {
      selectedIds.clear();
    }
  }

  /// Chọn / Bỏ chọn một mục
  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
      if (selectedIds.isEmpty) {
        isMultiSelectMode.value = false;
      }
    } else {
      selectedIds.add(id);
    }
  }

  /// Chọn tất cả mục
  void selectAll(List<int> ids) {
    selectedIds.assignAll(ids);
  }
}
