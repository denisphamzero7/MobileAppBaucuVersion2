import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'package:app_baucu_version1/controllers/task_controller.dart';
import 'package:app_baucu_version1/controllers/auth_controller.dart';
import 'package:app_baucu_version1/controllers/navigation.dart';
import 'package:app_baucu_version1/model/task_model.dart';
import 'package:app_baucu_version1/model/auth_model.dart';
import 'package:app_baucu_version1/untils/app_colors.dart';

class TaskScreen extends GetView<TaskController> {
  final String? type; // 'sent' or 'received' or null
  TaskScreen({super.key, this.type});

  // Reactive filters
  final RxString selectedStatusFilter = 'all'.obs;
  final RxString selectedTimingFilter = 'all'.obs;
  final RxString searchText = ''.obs;

  @override
  Widget build(BuildContext context) {
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
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SafeArea(
        child: Obx(() {
          // 1. Get base tasks list
          final baseTasks = type == 'sent'
              ? controller.tasksList.where((t) => t.id % 2 == 0).toList()
              : type == 'received'
                  ? controller.tasksList.where((t) => t.id % 2 != 0).toList()
                  : controller.tasksList;

          final actualTasks = baseTasks.isEmpty && controller.tasksList.isEmpty
              ? _getMockTasks()
              : baseTasks;

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

          return RefreshIndicator(
            onRefresh: controller.refreshTasks,
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
                            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            onChanged: (val) => searchText.value = val,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm công việc',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey),
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
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.filter_alt_outlined, size: 18, color: Colors.grey),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.5),
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
                      _buildStatCard(
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
                      _buildStatCard(
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
                      _buildStatCard(
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
                      _buildStatCard(
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
                      _buildStatCard(
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
                      _buildStatCard(
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
                      _buildStatCard(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.5),
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
                      _buildStatCard(
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
                      _buildStatCard(
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
                      _buildStatCard(
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
                      _buildStatCard(
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
                      _buildStatCard(
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
                      _buildStatCard(
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
                  const Divider(height: 1, color: Colors.black12),
                  const SizedBox(height: 10),

                  // D. TASKS LIST
                  if (filteredTasks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Không tìm thấy công việc phù hợp',
                              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return _buildTaskCard(context, task, isDark, primaryColor);
                      },
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task, bool isDark, Color primaryColor) {
    // Determine status text
    String statusText = 'Đang thực hiện';
    if (task.processingStatus == 'todo') statusText = 'Chưa thực hiện';
    if (task.processingStatus == 'done') statusText = 'Hoàn thành';
    if (task.processingStatus == 'paused') statusText = 'Tạm dừng';
    if (task.processingStatus == 'cancelled') statusText = 'Đã hủy';

    // Determine timing text
    String timingText = 'ĐÚNG HẠN';
    if (task.isOverdue || task.timingStatus == 'overdue') {
      timingText = 'QUÁ HẠN';
    } else if (task.timingStatus == 'late') {
      timingText = 'TRỄ HẠN';
    } else if (task.timingStatus == 'early') {
      timingText = 'SỚM HẠN';
    } else if (task.timingStatus == 'upcoming') {
      timingText = 'CHƯA ĐẾN HẠN';
    }

    // Format deadline
    String deadlineStr = 'N/A';
    if (task.endAt != null && task.endAt!.isNotEmpty) {
      try {
        final spaceParts = task.endAt!.trim().split(' ');
        String datePart = spaceParts.length >= 2 ? spaceParts[1] : spaceParts[0];
        if (datePart.contains('/')) {
          final dateParts = datePart.split('/');
          if (dateParts.length >= 2) {
            deadlineStr = '${dateParts[0]}/${dateParts[1]}';
          }
        } else if (datePart.contains('-')) {
          final dateParts = datePart.split('-');
          if (dateParts.length >= 3) {
            if (dateParts[0].length == 4) {
              deadlineStr = '${dateParts[2]}/${dateParts[1]}';
            } else {
              deadlineStr = '${dateParts[0]}/${dateParts[1]}';
            }
          }
        }
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showTaskDetailsDialog(context, task, isDark, primaryColor),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Nguyễn Văn Hùng', style: TextStyle(fontSize: 9, color: Colors.grey[700])),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.circle, size: 3, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('Hạn: $deadlineStr', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                        const SizedBox(width: 6),
                        const Icon(Icons.circle, size: 3, color: Colors.grey),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('• ${task.completionPercent}%', style: const TextStyle(fontSize: 9, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusText == 'Hoàn thành' ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusText == 'Hoàn thành' ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: timingText == 'QUÁ HẠN' ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    timingText,
                    style: TextStyle(
                      color: timingText == 'QUÁ HẠN' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TaskModel> _getMockTasks() {
    return [
      TaskModel(
        id: 1,
        name: 'Kiểm tra công tác trang trí, khánh tiết Đại hội',
        description: 'Kiểm tra chuẩn bị đại hội',
        deadlineType: 'has_deadline',
        startAt: '01/03/2026',
        endAt: '01/04/2026',
        processingStatus: 'in_progress',
        completionPercent: 70,
        priority: 'high',
        isOverdue: true,
        timingStatus: 'overdue',
        createdAt: '01/03/2026',
      ),
      TaskModel(
        id: 2,
        name: 'Soạn đề cương biên soạn lịch sử Đảng bộ TP',
        description: 'Soạn đề cương biên soạn lịch sử Đảng bộ TP',
        deadlineType: 'has_deadline',
        startAt: '02/03/2026',
        endAt: '02/04/2026',
        processingStatus: 'in_progress',
        completionPercent: 40,
        priority: 'medium',
        isOverdue: true,
        timingStatus: 'overdue',
        createdAt: '02/03/2026',
      ),
      TaskModel(
        id: 3,
        name: 'Rà soát các trang mạng xã hội có nội dung xuyên tạc',
        description: 'Rà soát các trang mạng xã hội có nội dung xuyên tạc',
        deadlineType: 'has_deadline',
        startAt: '03/03/2026',
        endAt: '03/04/2026',
        processingStatus: 'in_progress',
        completionPercent: 50,
        priority: 'high',
        isOverdue: true,
        timingStatus: 'overdue',
        createdAt: '03/03/2026',
      ),
      TaskModel(
        id: 4,
        name: 'Phối hợp tổ chức đêm biểu diễn văn nghệ',
        description: 'Phối hợp tổ chức đêm biểu diễn văn nghệ',
        deadlineType: 'has_deadline',
        startAt: '10/03/2026',
        endAt: '29/04/2026',
        processingStatus: 'todo',
        completionPercent: 0,
        priority: 'medium',
        isOverdue: true,
        timingStatus: 'overdue',
        createdAt: '10/03/2026',
      ),
      TaskModel(
        id: 5,
        name: '14/07 - 1',
        description: 'Đại biểu 1',
        deadlineType: 'has_deadline',
        startAt: '15/06/2026',
        endAt: '15/07/2026',
        processingStatus: 'todo',
        completionPercent: 0,
        priority: 'low',
        isOverdue: true,
        timingStatus: 'overdue',
        createdAt: '15/06/2026',
      ),
      TaskModel(
        id: 6,
        name: 'Soạn đề cương tuyên truyền kỷ niệm 96 năm ngày thành lập Đảng',
        description: 'Tuyên truyền kỷ niệm 96 năm ngày thành lập Đảng',
        deadlineType: 'has_deadline',
        startAt: '10/01/2026',
        endAt: '10/02/2026',
        processingStatus: 'done',
        completionPercent: 100,
        priority: 'high',
        isOverdue: false,
        timingStatus: 'early',
        createdAt: '10/01/2026',
      ),
      TaskModel(
        id: 7,
        name: 'Tổ chức gặp mặt chức sắc tôn giáo nhân dịp Tết',
        description: 'Gặp mặt chức sắc tôn giáo nhân dịp Tết',
        deadlineType: 'has_deadline',
        startAt: '15/01/2026',
        endAt: '20/01/2026',
        processingStatus: 'done',
        completionPercent: 100,
        priority: 'medium',
        isOverdue: false,
        timingStatus: 'early',
        createdAt: '15/01/2026',
      ),
    ];
  }

  void _showTaskDetailsDialog(BuildContext context, TaskModel task, bool isDark, Color primaryColor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            task.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPriorityBadge(task.priority),
                    _buildStatusBadge(task.processingStatus),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mô tả chi tiết:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  task.description.isNotEmpty ? task.description : 'Không có mô tả chi tiết.',
                  style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Tiến độ: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '${task.completionPercent}%',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Bắt đầu: ${task.startAt ?? 'N/A'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 18, color: task.isOverdue ? Colors.red : Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Hạn chót: ${task.endAt ?? 'Không hạn'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: task.isOverdue ? Colors.red : null,
                        fontWeight: task.isOverdue ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    Color bgColor;
    String label;

    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red[700]!;
        bgColor = Colors.red[50]!;
        label = 'Khẩn';
        break;
      case 'medium':
        color = Colors.orange[700]!;
        bgColor = Colors.orange[50]!;
        label = 'Trung bình';
        break;
      case 'low':
      default:
        color = Colors.green[700]!;
        bgColor = Colors.green[50]!;
        label = 'Thường';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    String label;

    switch (status.toLowerCase()) {
      case 'todo':
        color = Colors.grey[700]!;
        bgColor = Colors.grey[100]!;
        label = 'Chưa làm';
        break;
      case 'in_progress':
        color = Colors.blue[700]!;
        bgColor = Colors.blue[50]!;
        label = 'Đang làm';
        break;
      case 'completed':
      case 'done':
        color = Colors.green[700]!;
        bgColor = Colors.green[50]!;
        label = 'Đã xong';
        break;
      default:
        color = Colors.grey[700]!;
        bgColor = Colors.grey[100]!;
        label = status;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
