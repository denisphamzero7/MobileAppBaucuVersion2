import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'package:app_baucu_version1/controllers/task_controller.dart';
import 'package:app_baucu_version1/controllers/auth_controller.dart';
import 'package:app_baucu_version1/model/task_model.dart';
import 'package:app_baucu_version1/model/auth_model.dart';

class TaskScreen extends GetView<TaskController> {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final storage = GetStorage();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh sách công việc',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh hiển thị đơn vị hiện tại & đổi đơn vị công tác linh hoạt
            Obx(() {
              final authController = Get.find<AuthController>();
              final orgs = authController.getAvailableOrganizations();
              final currentOrgId = authController.currentOrganizationId.value;
              final currentOrg = orgs.firstWhereOrNull((x) => x.id == currentOrgId);

              if (currentOrg == null) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: isDark ? const Color(0xFF1E1E1E) : primaryColor.withOpacity(0.05),
                child: Row(
                  children: [
                    Icon(Icons.business_outlined, size: 20, color: primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đơn vị: ${currentOrg.name}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[300] : primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Danh sách công việc
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshTasks,
                child: Obx(() {
                  if (controller.isLoading.value && controller.tasksList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.errorMessage.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                            const SizedBox(height: 16),
                            Text(
                              controller.errorMessage.value,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: controller.fetchTasks,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (controller.tasksList.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_turned_in_outlined, size: 72, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có công việc nào được giao',
                                style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hãy kéo xuống để làm mới hoặc chọn đơn vị công tác khác.',
                                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: controller.tasksList.length,
                    itemBuilder: (context, index) {
                      final task = controller.tasksList[index];
                      return _buildTaskCard(context, task, isDark, primaryColor);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task, bool isDark, Color primaryColor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showTaskDetailsDialog(context, task, isDark, primaryColor);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng 1: Badge độ ưu tiên & Badge trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriorityBadge(task.priority),
                  _buildStatusBadge(task.processingStatus),
                ],
              ),
              const SizedBox(height: 12),

              // Hàng 2: Tên công việc
              Text(
                task.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Hàng 3: Mô tả ngắn gọn
              if (task.description.isNotEmpty) ...[
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Hàng 4: Tiến độ hoàn thành
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: task.completionPercent / 100,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(task.processingStatus, primaryColor),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${task.completionPercent}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Hàng 5: Hạn chót
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    task.endAt != null ? 'Hạn: ${task.endAt}' : 'Không có thời hạn',
                    style: TextStyle(
                      fontSize: 13,
                      color: task.isOverdue ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: task.isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (task.isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Quá hạn',
                        style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Badge độ ưu tiên
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

  // Badge trạng thái xử lý
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

  Color _getProgressColor(String status, Color primaryColor) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      default:
        return primaryColor;
    }
  }

  // Dialog hiển thị chi tiết công việc
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
  }}
