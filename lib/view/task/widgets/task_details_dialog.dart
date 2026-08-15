import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../create_task_screen.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/task_controller.dart';
import '../../../model/task_model.dart';
import '../../../untils/app_colors.dart';

class TaskDetailsBottomSheet extends StatelessWidget {
  final TaskModel task;
  final bool isDark;
  final Color primaryColor;

  const TaskDetailsBottomSheet({
    Key? key,
    required this.task,
    required this.isDark,
    required this.primaryColor,
  }) : super(key: key);

  String _formatDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Không có';
    final trimmed = raw.trim();
    try {
      if (trimmed.contains(' ')) {
        final parts = trimmed.split(' ');
        if (parts.length >= 2) {
          // If format is "HH:mm:ss dd/MM/yyyy"
          if (parts[0].contains(':') && parts[1].contains('/')) {
            final timePart = parts[0].length >= 5 ? parts[0].substring(0, 5) : parts[0];
            return '${parts[1]} ($timePart)';
          }
          // If format is "yyyy-MM-dd HH:mm:ss"
          if (parts[0].contains('-') && parts[1].contains(':')) {
            final dateParts = parts[0].split('-');
            final timePart = parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];
            if (dateParts.length == 3) {
              return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]} ($timePart)';
            }
          }
        }
      }
    } catch (_) {}
    return trimmed;
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    Color bgColor;
    String label;

    switch (priority.toLowerCase()) {
      case 'urgent':
        color = AppColors.red;
        bgColor = AppColors.badgeRedBg;
        label = 'Khẩn cấp';
        break;
      case 'high':
        color = AppColors.red[700]!;
        bgColor = AppColors.red[50]!;
        label = 'Cao';
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
        label = 'Thấp';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
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
        bgColor = AppColors.grey[200]!;
        label = 'Chưa làm';
        break;
      case 'pending_approval':
      case 'pending':
        color = AppColors.pendingApproval;
        bgColor = AppColors.bgPurpleLight;
        label = 'Chờ duyệt';
        break;
      case 'in_progress':
      case 'processing':
        color = AppColors.blue[700]!;
        bgColor = AppColors.badgeBlueBg;
        label = 'Đang làm';
        break;
      case 'completed':
      case 'done':
        color = AppColors.done;
        bgColor = AppColors.badgeGreenBg;
        label = 'Hoàn thành';
        break;
      case 'paused':
        color = AppColors.paused;
        bgColor = AppColors.bgYellowLight;
        label = 'Tạm dừng';
        break;
      case 'cancelled':
        color = AppColors.cancelled;
        bgColor = AppColors.bgRedLight;
        label = 'Đã hủy';
        break;
      default:
        color = AppColors.grey[700]!;
        bgColor = AppColors.grey[200]!;
        label = status;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTimingBadge() {
    Color color = AppColors.done;
    Color bgColor = AppColors.badgeGreenBg;
    String label = 'Đúng hạn';

    if (task.isOverdue || task.timingStatus == 'overdue') {
      color = AppColors.overdue;
      bgColor = AppColors.badgeRedBg;
      label = 'Quá hạn';
    } else if (task.timingStatus == 'late') {
      color = AppColors.late;
      bgColor = AppColors.bgYellowLight;
      label = 'Trễ hạn';
    } else if (task.timingStatus == 'early') {
      color = AppColors.early;
      bgColor = AppColors.badgeGreenBg;
      label = 'Sớm hạn';
    } else if (task.timingStatus == 'upcoming') {
      color = AppColors.primary;
      bgColor = AppColors.badgeBlueBg;
      label = 'Chưa đến hạn';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final canUpdate = authCtrl.can('update', 'TaskAssignmentItems');
    final canDelete = authCtrl.can('destroy', 'TaskAssignmentItems');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.white24 : AppColors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Title & Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: isDark ? AppColors.white : AppColors.black87,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.close, size: 20, color: isDark ? AppColors.white.withValues(alpha: 0.6) : AppColors.grey[600]),
                ),
              ),

            ],
          ),
          const SizedBox(height: 12),

          // Badges Row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildStatusBadge(task.processingStatus),
              _buildPriorityBadge(task.priority),
              _buildTimingBadge(),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.white10 : AppColors.lightBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ thực hiện',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white70 : AppColors.grey[700],
                      ),
                    ),
                    Text(
                      '${task.completionPercent}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (task.completionPercent.clamp(0, 100)) / 100.0,
                    backgroundColor: isDark ? AppColors.white24 : AppColors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Dates Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.white10 : AppColors.lightBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.play_circle_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Bắt đầu:', style: TextStyle(fontSize: 12, color: AppColors.grey[600])),
                    const Spacer(),
                    Text(
                      _formatDateTime(task.startAt),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white : AppColors.black87,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: task.isOverdue ? AppColors.red : AppColors.done,
                    ),
                    const SizedBox(width: 8),
                    Text('Hạn chót:', style: TextStyle(fontSize: 12, color: AppColors.grey[600])),
                    const Spacer(),
                    Text(
                      _formatDateTime(task.endAt),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: task.isOverdue
                            ? AppColors.red
                            : (isDark ? AppColors.white : AppColors.black87),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Description Section
          if (task.description.isNotEmpty) ...[
            Text(
              'Mô tả chi tiết',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isDark ? AppColors.white70 : AppColors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.white10 : AppColors.lightBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.description,
                style: TextStyle(
                  color: isDark ? AppColors.grey[300] : AppColors.black87,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 18),
          ] else ...[
            const SizedBox(height: 12),
          ],

          // Actions Row
          Row(
            children: [
              if (canDelete) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Get.defaultDialog(
                      title: 'Xác nhận xóa',
                      middleText: 'Bạn có chắc chắn muốn xóa công việc "${task.name}"?',
                      textConfirm: 'Xóa',
                      textCancel: 'Hủy',
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.red,
                      onConfirm: () {
                        Get.back();
                        if (Get.isRegistered<TaskController>()) {
                          Get.find<TaskController>().deleteTask(task.id);
                        }
                      },
                    );
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Xóa', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
              ] else if (!canUpdate) ...[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? AppColors.white24 : AppColors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Đóng',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white70 : AppColors.grey[800],
                      ),
                    ),
                  ),
                ),
              ],
              if (canUpdate) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(() => CreateTaskScreen(taskToUpdate: task));
                    },
                    icon: const Icon(Icons.edit_note_rounded, size: 20),
                    label: const Text(
                      'Cập nhật công việc',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Helper to show Task Details Bottom Sheet
void showTaskDetailsDialog(BuildContext context, TaskModel task, bool isDark, Color primaryColor) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TaskDetailsBottomSheet(
      task: task,
      isDark: isDark,
      primaryColor: primaryColor,
    ),
  );
}


