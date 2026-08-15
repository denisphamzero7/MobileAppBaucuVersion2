import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:app_baucu_version1/controllers/task_controller.dart';
import 'package:app_baucu_version1/controllers/navigation.dart';
import 'package:app_baucu_version1/model/task_model.dart';
import 'package:app_baucu_version1/untils/app_colors.dart';
import 'create_task_screen.dart';
import '../../core/widgets/import_excel_button.dart';
import '../../core/widgets/export_excel_button.dart';
import '../widgets/quick_action_bottom_sheet.dart';

import '../../controllers/auth_controller.dart';
import '../../core/widgets/can_access.dart';
import '../widgets/skeleton_loader.dart';
import 'widgets/stat_card_widget.dart';
import 'widgets/task_card_widget.dart';

class TaskScreen extends GetView<TaskController> {

  final String? type; // 'sent' or 'received' or null
  TaskScreen({super.key, this.type});

  // Reactive filters
  final RxString selectedStatusFilter = 'all'.obs;
  final RxString selectedTimingFilter = 'all'.obs;
  final RxString searchText = ''.obs;

  void _openQuickActions(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final userId = authCtrl.currentUser.value?.id;
    final queryParams = <String, dynamic>{};

    if (type == 'received' && userId != null) {
      queryParams['assignee_id'] = userId;
    } else if (type == 'sent' && userId != null) {
      queryParams['assigner_id'] = userId;
    }
    if (type != null && type!.isNotEmpty) {
      queryParams['type'] = type;
    }
    if (searchText.value.isNotEmpty) queryParams['search'] = searchText.value;
    if (selectedStatusFilter.value != 'all') queryParams['processing_status'] = selectedStatusFilter.value;
    if (selectedTimingFilter.value != 'all') queryParams['timing_status'] = selectedTimingFilter.value;

    final fileNamePrefix = type == 'received'
        ? 'CongViecDuocGiao'
        : (type == 'sent' ? 'CongViecDangGiao' : 'DanhSachCongViec');

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
      Get.snackbar("Thông báo", "Bạn không có quyền thực hiện thao tác nào.");
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTasks(type: type);
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

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
          type == 'sent'
              ? 'Công việc đang giao'
              : type == 'received'
                  ? 'Công việc được giao'
                  : 'Danh sách công việc',
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
                textConfirm: 'Xóa',
                textCancel: 'Hủy',
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
          // 1. Get base tasks list & tab stats from server
          final actualTasks = controller.tasksList;
          final tabStats = controller.tabStats.value;
          final bool hasTabStats = tabStats.total > 0;

          // Calculate statistics based on server tabStats (fallback to loaded list)
          final totalCount = hasTabStats ? tabStats.total : actualTasks.length;
          final todoCount = hasTabStats ? tabStats.todo : actualTasks.where((t) => t.processingStatus == 'todo').length;
          final inProgressCount = hasTabStats ? tabStats.inProgress : actualTasks.where((t) => t.processingStatus == 'in_progress').length;
          final pendingApprovalCount = hasTabStats ? tabStats.pendingApproval : actualTasks.where((t) => t.processingStatus == 'pending_approval').length;
          final doneCount = hasTabStats ? tabStats.done : actualTasks.where((t) => t.processingStatus == 'done' || t.processingStatus == 'completed').length;
          final pausedCount = hasTabStats ? tabStats.paused : actualTasks.where((t) => t.processingStatus == 'paused').length;
          final cancelledCount = hasTabStats ? tabStats.cancelled : actualTasks.where((t) => t.processingStatus == 'cancelled').length;

          final upcomingCount = hasTabStats ? tabStats.timingStats.upcoming : actualTasks.where((t) => t.timingStatus == 'upcoming').length;
          final earlyCount = hasTabStats ? tabStats.timingStats.early : actualTasks.where((t) => t.timingStatus == 'early').length;
          final onTimeCount = hasTabStats ? tabStats.timingStats.onTime : actualTasks.where((t) => t.timingStatus == 'on_time').length;
          final lateCount = hasTabStats ? tabStats.timingStats.late : actualTasks.where((t) => t.timingStatus == 'late').length;
          final overdueCount = hasTabStats ? tabStats.timingStats.overdue : actualTasks.where((t) => t.isOverdue || t.timingStatus == 'overdue').length;
          final cancelledTimingCount = hasTabStats ? tabStats.timingStats.cancelled : actualTasks.where((t) => t.timingStatus == 'cancelled').length;

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

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                controller.loadMoreTasks(type: type);
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () => controller.fetchTasks(type: type, isRefresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
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
                              color: isDark ? AppColors.cardDark : AppColors.lightBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              onChanged: (val) => searchText.value = val,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Tìm kiếm công việc',
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
                            border: Border.all(color: isDark ? AppColors.white10 : AppColors.black.withOpacity(0.05)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.filter_alt_outlined, size: 18, color: AppColors.grey),
                            onPressed: () {
                              // Reset filters
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
                    if (controller.isLoading.value && controller.tasksList.isEmpty)
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
                                'Không tìm thấy công việc phù hợp',
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
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return TaskCardWidget(task: task, isDark: isDark, primaryColor: primaryColor);
                            },
                          ),
                          Obx(() {
                            if (controller.isLoadingMore.value) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: SkeletonLoader(
                                  child: SkeletonBox(
                                    width: double.infinity,
                                    height: 80,
                                    radius: 12,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );
        }),
      ),

    );
  }
}
