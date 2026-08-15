import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:app_baucu_version1/controllers/task_controller.dart';
import 'package:app_baucu_version1/controllers/navigation.dart';
import 'package:app_baucu_version1/model/task_model.dart';
import 'package:app_baucu_version1/untils/app_colors.dart';
import 'create_task_screen.dart';
import '../../core/widgets/can_access.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/export_excel_task.dart';
import 'widgets/import_excel_task.dart';

import 'widgets/stat_card_widget.dart';
import 'widgets/task_card_widget.dart';
class TaskScreen extends GetView<TaskController> {
  final String? type; // 'sent' or 'received' or null
  TaskScreen({super.key, this.type});

  // Reactive filters
  final RxString selectedStatusFilter = 'all'.obs;
  final RxString selectedTimingFilter = 'all'.obs;
  final RxString searchText = ''.obs;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTasks(type: type);
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final storage = GetStorage();

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
          CanAccess(
            action: 'store', // Giả định quyền tạo/import
            subject: 'TaskAssignmentItems',
            child: const ImportExcelTask(),
          ),
          CanAccess(
            action: 'export',
            subject: 'TaskAssignmentItems',
            child: ExportExcelTask(
              type: type,
              searchText: searchText,
              selectedStatusFilter: selectedStatusFilter,
              selectedTimingFilter: selectedTimingFilter,
            ),
          ),
          CanAccess(
            action: 'store',
            subject: 'TaskAssignmentItems',
            child: IconButton(
              icon: const Icon(Icons.add, size: 22),
              tooltip: 'Tạo công việc',
              onPressed: () => Get.to(() => const CreateTaskScreen()),
            ),
          ),
          CanAccess(
            action: 'bulkDestroy',
            subject: 'TaskAssignmentItems',
            child: Obx(() => IconButton(
              icon: Icon(controller.isMultiSelectMode.value ? Icons.close : Icons.checklist, size: 22),
              tooltip: 'Chọn nhiều (để xóa)',
              onPressed: () => controller.toggleMultiSelectMode(),
            )),
          ),
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
                 }
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
          // 1. Get base tasks list
          final actualTasks = controller.tasksList;

          // Calculate statistics based on active task list
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
                    if (filteredTasks.isEmpty)
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
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
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
