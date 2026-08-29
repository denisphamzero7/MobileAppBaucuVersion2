import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_baucu_version1/controllers/task_controller.dart';
import 'package:app_baucu_version1/controllers/navigation.dart';
import 'package:app_baucu_version1/model/task_model.dart';
import 'package:app_baucu_version1/untils/app_colors.dart';
import 'package:app_baucu_version1/untils/app_strings.dart';
import '../../core/enums/task_enums.dart';
import 'create_task_screen.dart';
import '../../core/widgets/app_pagination_widget.dart';
import '../../core/widgets/app_paged_list_wrapper.dart';
import '../widgets/quick_action_bottom_sheet.dart';

import '../../controllers/auth_controller.dart';
import '../widgets/skeleton_loader.dart';
import 'widgets/stat_card_widget.dart';
import 'widgets/task_card_widget.dart';
import 'widgets/task_empty.dart';
import '../widgets/smart_skeleton_wrapper.dart';
import '../../model/advanced_filter_data.dart';
import '../../core/widgets/app_advanced_filter_bottom_sheet.dart';
import '../../helper/date_helper.dart';

/// ============================================================================
/// 📋 [TaskScreen] - MÀN HÌNH QUẢN LÝ CÔNG VIỆC (ĐANG GIAO / ĐƯỢC GIAO)
/// ============================================================================
/// 
/// 📌 CHỨC NĂNG CHÍNH:
/// 1. Hiển thị danh sách công việc theo phân loại:
///    - `type: 'sent'` -> Công việc tôi đã giao cho người khác.
///    - `type: 'received'` -> Công việc người khác giao cho tôi.
/// 2. Thống kê nhanh bằng 2 lưới số liệu:
///    - Lưới 7 ô: Trạng thái xử lý (Chưa làm, Đang làm, Chờ duyệt, Hoàn thành, Tạm dừng, Đã hủy).
///    - Lưới 6 ô: Tiến độ công việc (Chưa đến hạn, Sớm hạn, Đúng hạn, Trễ hạn, Quá hạn, Đã hủy).
/// 3. Bộ lọc thời gian thực: Tìm kiếm từ khóa, Lọc theo ô thống kê, Phân trang.
/// 4. Các tiện ích: Nhập/Xuất Excel, Thêm việc mới, Chọn nhiều & Xóa hàng loạt.
/// 5. Ứng dụng [SmartSkeletonWrapper] để hiển thị khung xương tải trang 100% Full Page.
class TaskScreen extends StatefulWidget {
  /// Phân loại tab công việc:
  /// - `'sent'`: Màn hình Công việc đang giao
  /// - `'received'`: Màn hình Công việc được giao
  final String? type;

  const TaskScreen({super.key, this.type});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final TaskController controller;

  // --- Các biến phản ứng (Reactive State) phục vụ tìm kiếm & bộ lọc ---
  final RxString selectedStatusFilter = 'all'.obs;  // Bộ lọc trạng thái xử lý
  final RxString selectedTimingFilter = 'all'.obs;  // Bộ lọc tiến độ
  final Rx<AdvancedFilterData> advancedFilter = AdvancedFilterData.initial.obs; // Bộ lọc nâng cao
  final RxString searchText = ''.obs;               // Từ khóa tìm kiếm
  final RxInt currentPage = 1.obs;                  // Trang hiện tại
  final RxBool isPageChanging = false.obs;          // Cờ hiệu ứng chuyển trang cục bộ
  final ScrollController _scrollController = ScrollController(); // Điều khiển cuộn mượt về đầu trang
  static const int itemsPerPage = 10;               // Số lượng việc trên mỗi trang

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 1. Khởi tạo / Tìm Controller
    if (!Get.isRegistered<TaskController>()) {
      controller = Get.put(TaskController());
    } else {
      controller = Get.find<TaskController>();
    }

    // 2. Tự động tải dữ liệu ban đầu cho Tab hiện tại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTasks(type: widget.type, isRefresh: true);
    });
  }

  void _openQuickActions(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final userId = authCtrl.currentUser.value?.id;
    final queryParams = <String, dynamic>{};

    if (widget.type == 'received' && userId != null) {
      queryParams['assignee_id'] = userId;
    } else if (widget.type == 'sent' && userId != null) {
      queryParams['assigner_id'] = userId;
    }
    if (widget.type != null && widget.type!.isNotEmpty) {
      queryParams['type'] = widget.type;
    }
    if (searchText.value.isNotEmpty) queryParams['search'] = searchText.value;
    if (selectedStatusFilter.value != 'all') queryParams['processing_status'] = selectedStatusFilter.value;
    if (selectedTimingFilter.value != 'all') queryParams['timing_status'] = selectedTimingFilter.value;

    final fileNamePrefix = widget.type == 'received'
        ? 'CongViecDuocGiao'
        : (widget.type == 'sent' ? 'CongViecDangGiao' : 'DanhSachCongViec');

    final canCreate = authCtrl.can('create', 'TaskAssignmentItems');
    final canDelete = authCtrl.can('destroy', 'TaskAssignmentItems');
    final canExport = authCtrl.can('read', 'TaskAssignmentItems');

    final List<QuickActionItem> items = [];

    if (canCreate) {
      items.add(
        QuickActionItem(
          title: AppStrings.createTaskAction,
          subtitle: AppStrings.createTaskSubtitle,
          icon: Icons.add_task_rounded,
          color: AppColors.primary,
          onTap: () => Get.to(() => const CreateTaskScreen()),
        ),
      );
      items.add(
        QuickActionItem(
          title: AppStrings.importExcelAction,
          subtitle: AppStrings.importExcelSubtitle,
          icon: Icons.upload_file_rounded,
          color: Colors.green,
          onTap: () => controller.importExcel(),
        ),
      );
    }

    if (canExport) {
      items.add(
        QuickActionItem(
          title: AppStrings.exportExcelAction,
          subtitle: AppStrings.exportExcelSubtitle,
          icon: Icons.download_rounded,
          color: Colors.orange,
          onTap: () => controller.exportExcel(
            queryParams: queryParams,
            fileNamePrefix: fileNamePrefix,
          ),
        ),
      );
    }

    if (canDelete) {
      items.add(
        QuickActionItem(
          title: controller.isMultiSelectMode.value ? AppStrings.cancelSelectMode : AppStrings.deleteSelectedAction,
          subtitle: AppStrings.deleteSelectedSubtitle,
          icon: controller.isMultiSelectMode.value ? Icons.close_rounded : Icons.checklist_rtl_rounded,
          color: Colors.purple,
          badge: controller.selectedTaskIds.isNotEmpty ? '${controller.selectedTaskIds.length}' : null,
          onTap: () => controller.toggleMultiSelectMode(),
        ),
      );
    }

    if (items.isEmpty) {
      Get.snackbar(AppStrings.notificationTitle, "Bạn không có quyền thực hiện thao tác nào.");
      return;
    }

    QuickActionBottomSheet.show(
      context,
      title: AppStrings.taskDetails,
      subtitle: 'Chọn tác vụ bạn muốn thực hiện',
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final screenTitle = widget.type == 'sent'
        ? AppStrings.taskSent
        : widget.type == 'received'
            ? AppStrings.taskReceived
            : 'Danh sách công việc';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () {
            Get.find<NavigationController>().changeIndex(0);
          },
        ),
        title: Text(
          screenTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            if (controller.isMultiSelectMode.value) {
              return IconButton(
                icon: const Icon(Icons.close, size: 22),
                tooltip: 'Thoát chọn nhiều',
                onPressed: () => controller.toggleMultiSelectMode(),
              );
            }
            return QuickActionButton(
              tooltip: 'Thao tác nhanh',
              onPressed: () => _openQuickActions(context),
            );
          }),
        ],
        elevation: 0,
        backgroundColor: isDark ? AppColors.black : AppColors.white,
        foregroundColor: isDark ? AppColors.white : AppColors.black87,
      ),
      floatingActionButton: Obx(() {
        if (controller.isMultiSelectMode.value && controller.selectedTaskIds.isNotEmpty) {
          return FloatingActionButton.extended(
            onPressed: () {
              Get.defaultDialog(
                title: AppStrings.deleteTask,
                middleText: 'Bạn có chắc chắn muốn xóa ${controller.selectedTaskIds.length} công việc này?',
                textConfirm: AppStrings.delete,
                textCancel: AppStrings.cancel,
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back();
                  controller.bulkDeleteTasks(controller.selectedTaskIds.toList());
                  controller.toggleMultiSelectMode();
                },
              );
            },
            backgroundColor: Colors.red,
            icon: const Icon(Icons.delete, color: Colors.white),
            label: Text('${AppStrings.delete} (${controller.selectedTaskIds.length})', style: const TextStyle(color: Colors.white)),
          );
        }
        return const SizedBox.shrink();
      }),
      // ======================================================================
      // 🌟 THÂN TRANG (BODY) - TÍCH HỢP SMARTSKELETONWRAPPER ĐIỀU PHỐI TẢI
      // ======================================================================
      body: SafeArea(
        child: Obx(() {
          // 1. Lấy danh sách công việc của Tab hiện tại ('sent' hoặc 'received')
          final actualTasks = controller.getTasksList(widget.type);
          final isTaskLoading = controller.isTypeLoading(widget.type);

          // 2. Điều kiện hiển thị Skeleton: Khi Controller đang tải -> LUÔN HIỆN FULL SKELETON
          final showSkeleton = isTaskLoading;

          // 3. Tính toán số liệu thống kê cho 2 Lưới (Dựa trên danh sách của Tab này)
          final totalCount = actualTasks.length;
          final todoCount = actualTasks.where((t) => t.processingStatus == 'todo').length;
          final inProgressCount = actualTasks.where((t) => t.processingStatus == 'in_progress').length;
          final pendingApprovalCount = actualTasks.where((t) => t.processingStatus == 'pending_approval').length;
          final doneCount = actualTasks.where((t) => t.processingStatus == 'done' || t.processingStatus == 'completed').length;
          final pausedCount = actualTasks.where((t) => t.processingStatus == 'paused').length;
          final cancelledCount = actualTasks.where((t) => t.processingStatus == 'cancelled').length;

          final upcomingCount = actualTasks.where((t) => t.timingStatus == 'upcoming').length;
          final earlyCount = actualTasks.where((t) => t.timingStatus == 'early').length;
          final onTimeCount = actualTasks.where((t) => t.timingStatus == 'on_time').length;
          final lateCount = actualTasks.where((t) => t.timingStatus == 'late').length;
          final overdueCount = actualTasks.where((t) => t.isOverdue || t.timingStatus == 'overdue').length;
          final cancelledTimingCount = actualTasks.where((t) => t.timingStatus == 'cancelled').length;

          // 4. Áp dụng bộ lọc tìm kiếm, bộ lọc nhanh & bộ lọc nâng cao
          var filteredTasks = List<TaskModel>.from(actualTasks);

          if (searchText.value.isNotEmpty) {
            filteredTasks = filteredTasks
                .where((t) => t.name.toLowerCase().contains(searchText.value.toLowerCase()))
                .toList();
          }

          if (selectedStatusFilter.value != 'all') {
            filteredTasks = filteredTasks
                .where((t) => t.processingStatus == selectedStatusFilter.value)
                .toList();
          }

          if (selectedTimingFilter.value != 'all') {
            filteredTasks = filteredTasks
                .where((t) => t.timingStatus == selectedTimingFilter.value)
                .toList();
          }

          // --- BỘ LỌC NÂNG CAO (ADVANCED FILTER) ---
          final af = advancedFilter.value;
          if (af.priority != 'all') {
            filteredTasks = filteredTasks
                .where((t) => t.priority.toLowerCase() == af.priority.toLowerCase())
                .toList();
          }

          if (af.deadlineType != 'all') {
            if (af.deadlineType == 'has_deadline') {
              filteredTasks = filteredTasks
                  .where((t) => t.deadlineType != 'no_deadline' && (t.endAt != null && t.endAt!.isNotEmpty))
                  .toList();
            } else if (af.deadlineType == 'no_deadline') {
              filteredTasks = filteredTasks
                  .where((t) => t.deadlineType == 'no_deadline' || t.endAt == null || t.endAt!.isEmpty)
                  .toList();
            }
          }

          if (af.departmentId != null) {
            filteredTasks = filteredTasks.where((t) {
              if (t.rawJson != null) {
                final users = t.rawJson!['users'];
                if (users is List) {
                  return users.any((u) => u is Map && u['department_id'] == af.departmentId);
                }
              }
              return true;
            }).toList();
          }

          if (af.fromDate != null) {
            filteredTasks = filteredTasks.where((t) {
              final date = DateHelper.parseDateTime(t.createdAt) ?? DateHelper.parseDateTime(t.startAt);
              if (date == null) return true;
              return date.isAfter(af.fromDate!) || date.isAtSameMomentAs(af.fromDate!);
            }).toList();
          }

          if (af.toDate != null) {
            final endOfDay = DateTime(af.toDate!.year, af.toDate!.month, af.toDate!.day, 23, 59, 59);
            filteredTasks = filteredTasks.where((t) {
              final date = DateHelper.parseDateTime(t.createdAt) ?? DateHelper.parseDateTime(t.endAt);
              if (date == null) return true;
              return date.isBefore(endOfDay) || date.isAtSameMomentAs(endOfDay);
            }).toList();
          }

          // 5. Tính toán phân trang dữ liệu (10 mục/trang)
          final int totalFilteredItems = filteredTasks.length;
          final int totalPages = (totalFilteredItems / itemsPerPage).ceil().clamp(1, 9999);
          if (currentPage.value > totalPages) {
            currentPage.value = totalPages;
          }
          final int startIndex = (currentPage.value - 1) * itemsPerPage;
          final pagedTasks = filteredTasks.skip(startIndex).take(itemsPerPage).toList();

          // ==================================================================
          // 👇 VỊ TRÍ BỌC SKELETON DUY NHẤT TRÊN TOÀN MÀN HÌNH
          // ==================================================================
          return SmartSkeletonWrapper(
            // A. Cờ điều kiện (true -> Hiện Skeleton, false -> Hiện child)
            showSkeleton: showSkeleton,

            // B. Mẫu khung xương Full Page mô phỏng 1-1 (Search + 2 Lưới + 5 Thẻ việc 68px)
            skeleton: AppSkeleton.fullPageLayout(
              statusGridCount: 7,
              statusGridCols: 4,
              statusGridRatio: 1.32,
              timingGridCount: 6,
              timingGridCols: 3,
              timingGridRatio: 1.92,
              cardCount: 5,
              cardHeight: 68,
            ),

            // C. Hàm kích hoạt khi người dùng kéo xuống làm mới (Pull-to-refresh)
            onRefresh: () => controller.fetchTasks(type: widget.type, isRefresh: true, isManualPull: true),

            // D. Giao diện dữ liệu thật khi đã nạp xong (KHÔNG bọc skeleton lẻ bên trong)
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- KHỐI A. THANH TÌM KIẾM & BỘ LỌC ---
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: TextField(
                            onChanged: (val) {
                              searchText.value = val;
                              currentPage.value = 1;
                            },
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: AppStrings.searchTaskHint,
                              hintStyle: TextStyle(fontSize: 13, color: AppColors.grey),
                              prefixIcon: Icon(Icons.search, size: 18, color: AppColors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // NÚT BỘ LỌC NÂNG CAO (CLICK MỞ BOTTOM SHEET TIỆN LỢI)
                      Obx(() {
                        final isFilterActive = advancedFilter.value.isActive;
                        final activeCount = advancedFilter.value.activeCount;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: isFilterActive
                                    ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                                    : (isDark ? AppColors.cardDark : AppColors.white),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isFilterActive
                                      ? AppColors.primary
                                      : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05)),
                                  width: isFilterActive ? 1.5 : 1.0,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.filter_alt_outlined,
                                  size: 18,
                                  color: isFilterActive ? AppColors.primary : AppColors.grey,
                                ),
                                onPressed: () {
                                  AppAdvancedFilterBottomSheet.show(
                                    context,
                                    initialData: advancedFilter.value,
                                    departments: controller.departments,
                                    onApply: (data) {
                                      advancedFilter.value = data;
                                      currentPage.value = 1;
                                    },
                                    onReset: () {
                                      advancedFilter.value = AdvancedFilterData.initial;
                                      currentPage.value = 1;
                                    },
                                  );
                                },
                              ),
                            ),
                            if (isFilterActive && activeCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Center(
                                    child: Text(
                                      '$activeCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                      if (Get.find<AuthController>().can('read', 'TaskAssignmentItems')) ...[
                        const SizedBox(width: 8),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.white10 : const Color(0xFFA7F3D0),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.description_outlined, size: 18, color: Color(0xFF059669)),
                            tooltip: 'Xuất Excel',
                            onPressed: () {
                              final authCtrl = Get.find<AuthController>();
                              final userId = authCtrl.currentUser.value?.id;
                              final queryParams = <String, dynamic>{};
                              if (widget.type == 'received' && userId != null) {
                                queryParams['assignee_id'] = userId;
                              } else if (widget.type == 'sent' && userId != null) {
                                queryParams['assigner_id'] = userId;
                              }
                              final fileNamePrefix = widget.type == 'received'
                                  ? 'CongViecDuocGiao'
                                  : (widget.type == 'sent' ? 'CongViecDangGiao' : 'DanhSachCongViec');
                              controller.exportExcel(queryParams: queryParams, fileNamePrefix: fileNamePrefix);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // B. TRẠNG THÁI XỬ LÝ GRID
                  const Text(
                    AppStrings.processingStatusSection,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.grey, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1.32,
                    children: TaskProcessingStatus.values.map((status) {
                      int count = 0;
                      switch (status) {
                        case TaskProcessingStatus.all:
                          count = totalCount;
                          break;
                        case TaskProcessingStatus.todo:
                          count = todoCount;
                          break;
                        case TaskProcessingStatus.inProgress:
                          count = inProgressCount;
                          break;
                        case TaskProcessingStatus.pendingApproval:
                          count = pendingApprovalCount;
                          break;
                        case TaskProcessingStatus.done:
                          count = doneCount;
                          break;
                        case TaskProcessingStatus.paused:
                          count = pausedCount;
                          break;
                        case TaskProcessingStatus.cancelled:
                          count = cancelledCount;
                          break;
                      }
                      final isSelected = selectedStatusFilter.value == status.key;
                      return StatCardWidget(
                        label: status.label,
                        count: count,
                        icon: status.icon,
                        color: status.color,
                        isSelected: isSelected,
                        onTap: () {
                          selectedStatusFilter.value = isSelected && status != TaskProcessingStatus.all ? 'all' : status.key;
                          selectedTimingFilter.value = 'all';
                        },
                        isDark: isDark,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // C. TIẾN ĐỘ CÔNG VIỆC GRID
                  const Text(
                    AppStrings.timingStatusSection,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.grey, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1.92,
                    children: [
                      TaskTimingStatus.upcoming,
                      TaskTimingStatus.completedEarly,
                      TaskTimingStatus.completedOnTime,
                      TaskTimingStatus.completedLate,
                      TaskTimingStatus.overdue,
                      TaskTimingStatus.cancelled,
                    ].map((status) {
                      int count = 0;
                      switch (status) {
                        case TaskTimingStatus.upcoming:
                          count = upcomingCount;
                          break;
                        case TaskTimingStatus.completedEarly:
                          count = earlyCount;
                          break;
                        case TaskTimingStatus.completedOnTime:
                          count = onTimeCount;
                          break;
                        case TaskTimingStatus.completedLate:
                          count = lateCount;
                          break;
                        case TaskTimingStatus.overdue:
                          count = overdueCount;
                          break;
                        case TaskTimingStatus.cancelled:
                          count = cancelledTimingCount;
                          break;
                        default:
                          count = 0;
                      }
                      final isSelected = selectedTimingFilter.value == status.key;
                      return StatCardWidget(
                        label: status.label,
                        count: count,
                        icon: status.icon,
                        color: status.color,
                        isSelected: isSelected,
                        onTap: () {
                          selectedTimingFilter.value = isSelected ? 'all' : status.key;
                          selectedStatusFilter.value = 'all';
                        },
                        isDark: isDark,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.black12),
                  const SizedBox(height: 10),

                  // D. TASKS LIST
                  if (filteredTasks.isEmpty)
                    const TaskEmpty()
                  else
                    Column(
                      children: [
                        // Bọc danh sách bằng AppPagedListWrapper để hiển thị Skeleton cục bộ khi đổi trang
                        AppPagedListWrapper(
                          isChangingPage: isPageChanging.value,
                          skeleton: AppSkeleton.listCards(count: 5, height: 68),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pagedTasks.length,
                            itemBuilder: (context, index) {
                              final task = pagedTasks[index];
                              return TaskCardWidget(task: task, isDark: isDark, primaryColor: primaryColor);
                            },
                          ),
                        ),
                        if (totalFilteredItems > 0) ...[
                          const SizedBox(height: 16),
                          AppPaginationWidget(
                            currentPage: currentPage.value,
                            totalPages: totalPages,
                            totalItems: totalFilteredItems,
                            itemsPerPage: itemsPerPage,
                            isLoading: isTaskLoading || isPageChanging.value,
                            onPageChanged: (newPage) async {
                              if (currentPage.value == newPage) return;
                              // 1. Bật cờ hiệu ứng chuyển trang cục bộ
                              isPageChanging.value = true;
                              currentPage.value = newPage;

                              // 2. Cuộn nhẹ lên đầu danh sách để đọc từ mục đầu tiên
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                );
                              }

                              // 3. Tắt trạng thái nạp sau khi hoàn tất hiệu ứng êm dịu (200ms)
                              await Future.delayed(const Duration(milliseconds: 200));
                              isPageChanging.value = false;
                            },
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
