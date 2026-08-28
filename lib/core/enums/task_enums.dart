import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// 1. TRẠNG THÁI XỬ LÝ CÔNG VIỆC
enum TaskProcessingStatus {
  all(
    key: 'all',
    label: 'Tất cả',
    icon: Icons.filter_list,
    color: AppColors.primary,
  ),
  todo(
    key: 'todo',
    label: 'Chưa thực hiện',
    icon: Icons.access_time,
    color: AppColors.todo,
  ),
  inProgress(
    key: 'in_progress',
    label: 'Đang thực hiện',
    icon: Icons.rotate_right,
    color: AppColors.inProgress,
  ),
  pendingApproval(
    key: 'pending_approval',
    label: 'Chờ duyệt',
    icon: Icons.error_outline,
    color: AppColors.pendingApproval,
  ),
  done(
    key: 'done',
    label: 'Hoàn thành',
    icon: Icons.check_circle_outline,
    color: AppColors.done,
  ),
  paused(
    key: 'paused',
    label: 'Tạm dừng',
    icon: Icons.pause_circle_outline,
    color: AppColors.paused,
  ),
  cancelled(
    key: 'cancelled',
    label: 'Đã hủy',
    icon: Icons.cancel_outlined,
    color: AppColors.cancelled,
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const TaskProcessingStatus({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  static TaskProcessingStatus fromKey(String? key) {
    return TaskProcessingStatus.values.firstWhere(
      (e) => e.key == key,
      orElse: () => TaskProcessingStatus.all,
    );
  }
}

/// 2. TRẠNG THÁI TIẾN ĐỘ THỜI HẠN CÔNG VIỆC
enum TaskTimingStatus {
  all(
    key: 'all',
    label: 'Tất cả',
    icon: Icons.filter_list,
    color: AppColors.primary,
  ),
  upcoming(
    key: 'upcoming',
    label: 'Chưa đến hạn',
    icon: Icons.access_time,
    color: AppColors.upcoming,
  ),
  dueSoon(
    key: 'due_soon',
    label: 'Sắp đến hạn',
    icon: Icons.warning_amber_outlined,
    color: AppColors.warningOrange,
  ),
  overdue(
    key: 'overdue',
    label: 'Quá hạn',
    icon: Icons.error_outline,
    color: AppColors.overdue,
  ),
  completedEarly(
    key: 'completed_early',
    label: 'Sớm hạn',
    icon: Icons.verified_outlined,
    color: AppColors.early,
  ),
  completedOnTime(
    key: 'completed_on_time',
    label: 'Đúng hạn',
    icon: Icons.check_circle_outline,
    color: AppColors.onTime,
  ),
  completedLate(
    key: 'completed_late',
    label: 'Trễ hạn',
    icon: Icons.history_toggle_off,
    color: AppColors.late,
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const TaskTimingStatus({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  static TaskTimingStatus fromKey(String? key) {
    return TaskTimingStatus.values.firstWhere(
      (e) => e.key == key,
      orElse: () => TaskTimingStatus.all,
    );
  }
}

/// 3. MỨC ĐỘ ƯU TIÊN CÔNG VIỆC
enum TaskPriorityLevel {
  urgent(
    key: 'urgent',
    label: 'Khẩn cấp',
    color: AppColors.priorityUrgent,
  ),
  high(
    key: 'high',
    label: 'Cao',
    color: AppColors.priorityHigh,
  ),
  medium(
    key: 'medium',
    label: 'Trung bình',
    color: AppColors.priorityMedium,
  ),
  low(
    key: 'low',
    label: 'Thấp',
    color: AppColors.priorityLow,
  );

  final String key;
  final String label;
  final Color color;

  const TaskPriorityLevel({
    required this.key,
    required this.label,
    required this.color,
  });

  static TaskPriorityLevel fromKey(String? key) {
    return TaskPriorityLevel.values.firstWhere(
      (e) => e.key == key,
      orElse: () => TaskPriorityLevel.medium,
    );
  }
}
