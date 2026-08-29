import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// 1. TRẠNG THÁI XỬ LÝ CÔNG VIỆC (PROCESSING STATUS)
/// ============================================================================
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
    if (key == null) return TaskProcessingStatus.all;
    final k = key.toLowerCase().trim();
    if (k == 'todo' || k == 'new' || k == 'chua_thuc_hien') return TaskProcessingStatus.todo;
    if (k == 'in_progress' || k == 'processing' || k == 'dang_thuc_hien') return TaskProcessingStatus.inProgress;
    if (k == 'pending_approval' || k == 'pending' || k == 'cho_duyet') return TaskProcessingStatus.pendingApproval;
    if (k == 'done' || k == 'completed' || k == 'hoan_thanh') return TaskProcessingStatus.done;
    if (k == 'paused' || k == 'tam_dung') return TaskProcessingStatus.paused;
    if (k == 'cancelled' || k == 'canceled' || k == 'da_huy') return TaskProcessingStatus.cancelled;

    return TaskProcessingStatus.values.firstWhere(
      (e) => e.key == k,
      orElse: () => TaskProcessingStatus.all,
    );
  }
}

/// ============================================================================
/// 2. TRẠNG THÁI TIẾN ĐỘ THỜI HẠN CÔNG VIỆC (TIMING STATUS)
/// ============================================================================
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
    key: 'early',
    label: 'Sớm hạn',
    icon: Icons.verified_outlined,
    color: AppColors.early,
  ),
  completedOnTime(
    key: 'on_time',
    label: 'Đúng hạn',
    icon: Icons.check_circle_outline,
    color: AppColors.onTime,
  ),
  completedLate(
    key: 'late',
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
    if (key == null) return TaskTimingStatus.all;
    final k = key.toLowerCase().trim();
    if (k == 'early' || k == 'completed_early' || k == 'som_han' || k == 'sớm hạn') {
      return TaskTimingStatus.completedEarly;
    }
    if (k == 'on_time' || k == 'completed_on_time' || k == 'dung_han' || k == 'đúng hạn') {
      return TaskTimingStatus.completedOnTime;
    }
    if (k == 'late' || k == 'completed_late' || k == 'tre_han' || k == 'trễ hạn') {
      return TaskTimingStatus.completedLate;
    }
    if (k == 'overdue' || k == 'qua_han' || k == 'quá hạn') {
      return TaskTimingStatus.overdue;
    }
    if (k == 'due_soon' || k == 'sap_den_han' || k == 'sắp đến hạn') {
      return TaskTimingStatus.dueSoon;
    }
    if (k == 'upcoming' || k == 'chua_den_han' || k == 'chưa đến hạn') {
      return TaskTimingStatus.upcoming;
    }

    return TaskTimingStatus.values.firstWhere(
      (e) => e.key == k,
      orElse: () => TaskTimingStatus.all,
    );
  }
}

/// ============================================================================
/// 3. MỨC ĐỘ ƯU TIÊN CÔNG VIỆC (PRIORITY LEVEL)
/// ============================================================================
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
    if (key == null) return TaskPriorityLevel.medium;
    final k = key.toLowerCase().trim();
    if (k == 'urgent' || k == 'critical' || k == 'khan_cap' || k == 'khẩn cấp' || k == 'very_high') {
      return TaskPriorityLevel.urgent;
    }
    if (k == 'high' || k == 'cao') {
      return TaskPriorityLevel.high;
    }
    if (k == 'medium' || k == 'normal' || k == 'trung_binh' || k == 'trung bình') {
      return TaskPriorityLevel.medium;
    }
    if (k == 'low' || k == 'thap' || k == 'thấp') {
      return TaskPriorityLevel.low;
    }

    return TaskPriorityLevel.values.firstWhere(
      (e) => e.key == k,
      orElse: () => TaskPriorityLevel.medium,
    );
  }
}
