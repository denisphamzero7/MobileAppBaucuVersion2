import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:app_baucu_version1/controllers/task_controller.dart';
import 'package:app_baucu_version1/controllers/navigation.dart';
import 'package:app_baucu_version1/model/task_model.dart';
import 'package:app_baucu_version1/untils/app_colors.dart';
import 'package:app_baucu_version1/untils/app_strings.dart';
import 'create_task_screen.dart';
import '../../core/widgets/import_excel_button.dart';
import '../../core/widgets/export_excel_button.dart';
import '../../core/widgets/app_pagination_widget.dart';
import '../widgets/quick_action_bottom_sheet.dart';

import '../../controllers/auth_controller.dart';
import '../widgets/skeleton_loader.dart';
import 'widgets/stat_card_widget.dart';
import 'widgets/task_card_widget.dart';
import '../widgets/smart_skeleton_wrapper.dart';

class TaskScreen extends StatefulWidget {
  final String? type; // 'sent' or 'received' or null
  const TaskScreen({super.key, this.type});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final TaskController controller;

  // Reactive filters & pagination
  final RxString selectedStatusFilter = 'all'.obs;
  final RxString selectedTimingFilter = 'all'.obs;
  final RxString searchText = ''.obs;
  final RxInt currentPage = 1.obs;
  static const int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<TaskController>()) {
      controller = Get.put(TaskController());
    } else {
      controller = Get.find<TaskController>();
    }
    // Chỉ tự động tải dữ liệu nếu danh sách đang rỗng (chưa có dữ liệu)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final actualTasks = controller.getTasksList(widget.type);
      if (actualTasks.isEmpty) {
        controller.fetchTasks(type: widget.type, isRefresh: true);
      }
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
          title: 'Tạo việc mới',
          subtitle: 'Thêm & phân công',
          icon: Icons.add_task_rounded,
          color: AppColors.primary,
          onTap: () => Get.to(() => const CreateTaskScreen()),
        ),
      );
      items.add(
        QuickActionItem(
          title: 'Nhập Excel',
          subtitle: 'Tải danh sách việc',
          icon: Icons.upload_file_rounded,
          color: Colors.green,
          onTap: () {
            ImportExcelButton.pickAndUpload(
              uploadUrl: 'task-assignment-items/import',
              onSuccess: () => controller.refreshTasks(),
            );
          },
        ),
      );
    }

    if (canExport) {
      items.add(
        QuickActionItem(
          title: 'Xuất Excel',
          subtitle: 'Tải báo cáo tệp',
          icon: Icons.download_rounded,
          color: Colors.orange,
          onTap: () {
            ExportExcelButton.downloadAndSave(
              url: 'task-assignment-items/export',
              queryParams: queryParams,
              fileNamePrefix: fileNamePrefix,
            );
          },
        ),
      );
    }

    if (canDelete) {
      items.add(
        QuickActionItem(
          title: controller.isMultiSelectMode.value ? 'Hủy chọn' : 'Chọn nhiều',
          subtitle: 'Xóa hàng loạt',
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
      title: 'Thao tác công việc',
      subtitle: 'Chọn tác vụ bạn muốn thực hiện',
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                title: 'Xóa công việc',
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
            label: Text('Xóa (${controller.selectedTaskIds.length})', style: const TextStyle(color: Colors.white)),
          );
        }
        return const SizedBox.shrink();
      }),
      body: SafeArea(
        child: Obx(() {
          // 1. Lấy danh sách việc tương ứng với type hiện tại
          final actualTasks = controller.getTasksList(widget.type);
          final isTaskLoading = controller.isTypeLoading(widget.type);

          // Chỉ hiện Skeleton khi chưa có dữ liệu HOẶC khi người dùng chủ động vuốt làm mới
          final showSkeleton = isTaskLoading && (actualTasks.isEmpty || controller.isManualRefreshing.value);

          // Calculate statistics based on this tab's actual tasks
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

          // 2. Apply search and card filters
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

          final int totalFilteredItems = filteredTasks.length;
          final int totalPages = (totalFilteredItems / itemsPerPage).ceil().clamp(1, 9999);
          if (currentPage.value > totalPages) {
            currentPage.value = totalPages;
          }
          final int startIndex = (currentPage.value - 1) * itemsPerPage;
          final pagedTasks = filteredTasks.skip(startIndex).take(itemsPerPage).toList();

          return SmartSkeletonWrapper(
            showSkeleton: showSkeleton,
            skeleton: AppSkeleton.fullPageLayout(
              statusGridCount: 7,
              statusGridCols: 4,
              statusGridRatio: 1.4,
              timingGridCount: 6,
              timingGridCols: 3,
              timingGridRatio: 2.1,
              cardCount: 4,
              cardHeight: 110,
            ),
            onRefresh: () => controller.fetchTasks(type: widget.type, isRefresh: true, isManualPull: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. SEARCH BAR & FILTER BUTTON
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
                      const SizedBox(width: 10),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.filter_alt_outlined, size: 18, color: AppColors.grey),
                          onPressed: () {
                            selectedStatusFilter.value = 'all';
                            selectedTimingFilter.value = 'all';
                            searchText.value = '';
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // B. TRẠNG THÁI XỬ LÝ GRID
                  const Text(
                    'TRẠNG THÁI XỬ LÝ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.grey, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1.4,
                    children: [
                      StatCardWidget(
                        label: 'Tổng',
                        count: totalCount,
                        icon: Icons.filter_list,
                        color: AppColors.primary,
                        isSelected: selectedStatusFilter.value == 'all',
                        onTap: () {
                          selectedStatusFilter.value = 'all';
                          selectedTimingFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Chưa thực hiện',
                        count: todoCount,
                        icon: Icons.access_time,
                        color: AppColors.todo,
                        isSelected: selectedStatusFilter.value == 'todo',
                        onTap: () {
                          selectedStatusFilter.value = 'todo';
                          selectedTimingFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Đang thực hiện',
                        count: inProgressCount,
                        icon: Icons.rotate_right,
                        color: AppColors.inProgress,
                        isSelected: selectedStatusFilter.value == 'in_progress',
                        onTap: () {
                          selectedStatusFilter.value = 'in_progress';
                          selectedTimingFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Chờ duyệt',
                        count: pendingApprovalCount,
                        icon: Icons.error_outline,
                        color: AppColors.pendingApproval,
                        isSelected: selectedStatusFilter.value == 'pending_approval',
                        onTap: () {
                          selectedStatusFilter.value = 'pending_approval';
                          selectedTimingFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Hoàn thành',
                        count: doneCount,
                        icon: Icons.check_circle_outline,
                        color: AppColors.done,
                        isSelected: selectedStatusFilter.value == 'done',
                        onTap: () {
                          selectedStatusFilter.value = 'done';
                          selectedTimingFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Tạm dừng',
                        count: pausedCount,
                        icon: Icons.pause_circle_outline,
                        color: AppColors.paused,
                        isSelected: selectedStatusFilter.value == 'paused',
                        onTap: () {
                          selectedStatusFilter.value = 'paused';
                          selectedTimingFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Đã hủy',
                        count: cancelledCount,
                        icon: Icons.cancel_outlined,
                        color: AppColors.cancelled,
                        isSelected: selectedStatusFilter.value == 'cancelled',
                        onTap: () {
                          selectedStatusFilter.value = 'cancelled';
                          selectedTimingFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // C. TIẾN ĐỘ CÔNG VIỆC GRID
                  const Text(
                    'TIẾN ĐỘ CÔNG VIỆC',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.grey, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 2.1,
                    children: [
                      StatCardWidget(
                        label: 'Chưa đến hạn',
                        count: upcomingCount,
                        icon: Icons.access_time,
                        color: AppColors.upcoming,
                        isSelected: selectedTimingFilter.value == 'upcoming',
                        onTap: () {
                          selectedTimingFilter.value = 'upcoming';
                          selectedStatusFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Sớm hạn',
                        count: earlyCount,
                        icon: Icons.star_outline,
                        color: AppColors.early,
                        isSelected: selectedTimingFilter.value == 'early',
                        onTap: () {
                          selectedTimingFilter.value = 'early';
                          selectedStatusFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Đúng hạn',
                        count: onTimeCount,
                        icon: Icons.done_all,
                        color: AppColors.onTime,
                        isSelected: selectedTimingFilter.value == 'on_time',
                        onTap: () {
                          selectedTimingFilter.value = 'on_time';
                          selectedStatusFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Trễ hạn',
                        count: lateCount,
                        icon: Icons.access_time,
                        color: AppColors.late,
                        isSelected: selectedTimingFilter.value == 'late',
                        onTap: () {
                          selectedTimingFilter.value = 'late';
                          selectedStatusFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Quá hạn',
                        count: overdueCount,
                        icon: Icons.warning_amber_outlined,
                        color: AppColors.overdue,
                        isSelected: selectedTimingFilter.value == 'overdue',
                        onTap: () {
                          selectedTimingFilter.value = 'overdue';
                          selectedStatusFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Đã hủy',
                        count: cancelledTimingCount,
                        icon: Icons.cancel_outlined,
                        color: AppColors.timingCancelled,
                        isSelected: selectedTimingFilter.value == 'cancelled',
                        onTap: () {
                          selectedTimingFilter.value = 'cancelled';
                          selectedStatusFilter.value = 'all';
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.black12),
                  const SizedBox(height: 10),

                  // D. TASKS LIST
                  if (isTaskLoading)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        child: SkeletonLoader(
                          child: SkeletonBox(
                            width: double.infinity,
                            height: 110,
                            radius: 16,
                          ),
                        ),
                      ),
                    )
                  else if (filteredTasks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppColors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.noTasksFound,
                              style: TextStyle(fontSize: 13, color: AppColors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pagedTasks.length,
                          itemBuilder: (context, index) {
                            final task = pagedTasks[index];
                            return TaskCardWidget(task: task, isDark: isDark, primaryColor: primaryColor);
                          },
                        ),
                        if (totalFilteredItems > 0) ...[
                          const SizedBox(height: 16),
                          AppPaginationWidget(
                            currentPage: currentPage.value,
                            totalPages: totalPages,
                            totalItems: totalFilteredItems,
                            itemsPerPage: itemsPerPage,
                            isLoading: isTaskLoading,
                            onPageChanged: (newPage) {
                              currentPage.value = newPage;
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
