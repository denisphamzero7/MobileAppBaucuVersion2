import 'package:flutter/material.dart';
import '../../../model/task_model.dart';
import '../../../untils/app_colors.dart';

class TaskDetailsDialog extends StatelessWidget {
  final TaskModel task;
  final bool isDark;
  final Color primaryColor;

  const TaskDetailsDialog({
    Key? key,
    required this.task,
    required this.isDark,
    required this.primaryColor,
  }) : super(key: key);

  Widget _buildPriorityBadge(String priority) {
    Color color;
    Color bgColor;
    String label;

    switch (priority.toLowerCase()) {
      case 'high':
        color = AppColors.red[700]!;
        bgColor = AppColors.red[50]!;
        label = 'Khẩn';
        break;
      case 'medium':
        color = AppColors.orange[700]!;
        bgColor = AppColors.orange[50]!;
        label = 'Trung bình';
        break;
      case 'low':
      default:
        color = AppColors.green[700]!;
        bgColor = AppColors.green[50]!;
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
        color = AppColors.grey[700]!;
        bgColor = AppColors.grey[100]!;
        label = 'Chưa làm';
        break;
      case 'in_progress':
        color = AppColors.blue[700]!;
        bgColor = AppColors.blue[50]!;
        label = 'Đang làm';
        break;
      case 'completed':
      case 'done':
        color = AppColors.green[700]!;
        bgColor = AppColors.green[50]!;
        label = 'Đã xong';
        break;
      default:
        color = AppColors.grey[700]!;
        bgColor = AppColors.grey[100]!;
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

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(color: isDark ? AppColors.grey[300] : AppColors.grey[700], fontSize: 14),
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
                const Icon(Icons.access_time_outlined, size: 18, color: AppColors.grey),
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
                Icon(Icons.calendar_today_outlined, size: 18, color: task.isOverdue ? AppColors.red : AppColors.grey),
                const SizedBox(width: 8),
                Text(
                  'Hạn chót: ${task.endAt ?? 'Không hạn'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: task.isOverdue ? AppColors.red : null,
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
  }
}

// Hàm trợ giúp để dễ dàng gọi Dialog
void showTaskDetailsDialog(BuildContext context, TaskModel task, bool isDark, Color primaryColor) {
  showDialog(
    context: context,
    builder: (context) => TaskDetailsDialog(
      task: task,
      isDark: isDark,
      primaryColor: primaryColor,
    ),
  );
}
