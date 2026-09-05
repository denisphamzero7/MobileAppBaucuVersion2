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
    aliases: ['tat_ca', 'tatca', 'tat-ca', 'tất cả'],
  ),
  todo(
    key: 'todo',
    label: 'Chưa thực hiện',
    icon: Icons.access_time,
    color: AppColors.todo,
    aliases: ['new', 'chua_thuc_hien', 'chưa thực hiện', '0', 'created'],
  ),
  inProgress(
    key: 'in_progress',
    label: 'Đang thực hiện',
    icon: Icons.rotate_right,
    color: AppColors.inProgress,
    aliases: ['processing', 'dang_thuc_hien', 'đang thực hiện', 'running', 'in-progress'],
  ),
  pendingApproval(
    key: 'pending_approval',
    label: 'Chờ duyệt',
    icon: Icons.error_outline,
    color: AppColors.pendingApproval,
    aliases: ['pending', 'cho_duyet', 'chờ duyệt', 'review', 'waiting'],
  ),
  done(
    key: 'done',
    label: 'Hoàn thành',
    icon: Icons.check_circle_outline,
    color: AppColors.done,
    aliases: ['completed', 'hoan_thanh', 'hoàn thành', 'finished', '1', 'closed'],
  ),
  paused(
    key: 'paused',
    label: 'Tạm dừng',
    icon: Icons.pause_circle_outline,
    color: AppColors.paused,
    aliases: ['tam_dung', 'tạm dừng', 'hold', 'on_hold'],
  ),
  cancelled(
    key: 'cancelled',
    label: 'Đã hủy',
    icon: Icons.cancel_outlined,
    color: AppColors.cancelled,
    aliases: ['canceled', 'da_huy', 'đã hủy', 'rejected'],
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> aliases;

  const TaskProcessingStatus({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    this.aliases = const [],
  });

  // Lookup map O(1)
  static final Map<String, TaskProcessingStatus> _lookupMap = () {
    final map = <String, TaskProcessingStatus>{};
    for (final status in TaskProcessingStatus.values) {
      map[status.key.toLowerCase()] = status;
      for (final alias in status.aliases) {
        map[alias.toLowerCase()] = status;
      }
    }
    return map;
  }();

  /// Parse cho Entity / Data Model: Mặc định fallback về 'todo' (Chưa thực hiện)
  static TaskProcessingStatus fromKey(
    String? key, {
    TaskProcessingStatus fallback = TaskProcessingStatus.todo,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toLowerCase().trim()] ?? fallback;
  }

  /// Parse riêng cho Bộ lọc Filter / Query Param: Mặc định fallback về 'all'
  static TaskProcessingStatus fromFilterKey(String? key) {
    return fromKey(key, fallback: TaskProcessingStatus.all);
  }

  /// Danh sách đầy đủ cho thanh Filter, Tabs thống kê (Có 'all')
  static List<TaskProcessingStatus> get filterOptions => TaskProcessingStatus.values;

  /// Danh sách cho Dropdown Form Tạo mới/Sửa Task (Loại bỏ 'all')
  static List<TaskProcessingStatus> get formOptions =>
      TaskProcessingStatus.values.where((e) => e != TaskProcessingStatus.all).toList();

  bool get isDone => this == TaskProcessingStatus.done;
  bool get isClosed => this == TaskProcessingStatus.done || this == TaskProcessingStatus.cancelled;
  bool get isActive => this == TaskProcessingStatus.todo || this == TaskProcessingStatus.inProgress;
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
    aliases: ['tat_ca', 'tatca', 'tat-ca', 'tất cả'],
  ),
  upcoming(
    key: 'upcoming',
    label: 'Chưa đến hạn',
    icon: Icons.access_time,
    color: AppColors.upcoming,
    aliases: ['chua_den_han', 'chưa đến hạn', 'not_due'],
  ),
  dueSoon(
    key: 'due_soon',
    label: 'Sắp đến hạn',
    icon: Icons.warning_amber_outlined,
    color: AppColors.warningOrange,
    aliases: ['sap_den_han', 'sắp đến hạn', 'warning'],
  ),
  overdue(
    key: 'overdue',
    label: 'Quá hạn',
    icon: Icons.error_outline,
    color: AppColors.overdue,
    aliases: ['qua_han', 'quá hạn', 'expired'],
  ),
  completedEarly(
    key: 'early',
    label: 'Sớm hạn',
    icon: Icons.verified_outlined,
    color: AppColors.early,
    aliases: ['completed_early', 'som_han', 'sớm hạn'],
  ),
  completedOnTime(
    key: 'on_time',
    label: 'Đúng hạn',
    icon: Icons.check_circle_outline,
    color: AppColors.onTime,
    aliases: ['completed_on_time', 'dung_han', 'đúng hạn'],
  ),
  completedLate(
    key: 'late',
    label: 'Trễ hạn',
    icon: Icons.history_toggle_off,
    color: AppColors.late,
    aliases: ['completed_late', 'tre_han', 'trễ hạn'],
  ),
  cancelled(
    key: 'cancelled',
    label: 'Đã hủy',
    icon: Icons.cancel_outlined,
    color: AppColors.timingCancelled,
    aliases: ['canceled', 'da_huy', 'đã hủy'],
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> aliases;

  const TaskTimingStatus({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    this.aliases = const [],
  });

  // Lookup map O(1)
  static final Map<String, TaskTimingStatus> _lookupMap = () {
    final map = <String, TaskTimingStatus>{};
    for (final status in TaskTimingStatus.values) {
      map[status.key.toLowerCase()] = status;
      for (final alias in status.aliases) {
        map[alias.toLowerCase()] = status;
      }
    }
    return map;
  }();

  /// Parse cho Entity / Data Model: Mặc định fallback về 'upcoming'
  static TaskTimingStatus fromKey(
    String? key, {
    TaskTimingStatus fallback = TaskTimingStatus.upcoming,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toLowerCase().trim()] ?? fallback;
  }

  /// Parse riêng cho Bộ lọc Filter / Query Param: Mặc định fallback về 'all'
  static TaskTimingStatus fromFilterKey(String? key) {
    return fromKey(key, fallback: TaskTimingStatus.all);
  }

  /// Danh sách đầy đủ cho thanh Filter, Tabs thống kê (Có 'all')
  static List<TaskTimingStatus> get filterOptions => TaskTimingStatus.values;

  /// Danh sách cho Dropdown Form Tạo mới/Sửa Task (Loại bỏ 'all')
  static List<TaskTimingStatus> get formOptions =>
      TaskTimingStatus.values.where((e) => e != TaskTimingStatus.all).toList();

  bool get isOverdue => this == TaskTimingStatus.overdue;
  bool get isCompleted =>
      this == TaskTimingStatus.completedEarly ||
      this == TaskTimingStatus.completedOnTime ||
      this == TaskTimingStatus.completedLate;
}

/// ============================================================================
/// 3. MỨC ĐỘ ƯU TIÊN CÔNG VIỆC (PRIORITY LEVEL)
/// ============================================================================
enum TaskPriorityLevel {
  urgent(
    key: 'urgent',
    label: 'Khẩn cấp',
    color: AppColors.priorityUrgent,
    aliases: ['critical', 'khan_cap', 'khẩn cấp', 'very_high', '4'],
  ),
  high(
    key: 'high',
    label: 'Cao',
    color: AppColors.priorityHigh,
    aliases: ['cao', '3'],
  ),
  medium(
    key: 'medium',
    label: 'Trung bình',
    color: AppColors.priorityMedium,
    aliases: ['normal', 'trung_binh', 'trung bình', '2', 'default'],
  ),
  low(
    key: 'low',
    label: 'Thấp',
    color: AppColors.priorityLow,
    aliases: ['thap', 'thấp', '1'],
  );

  final String key;
  final String label;
  final Color color;
  final List<String> aliases;

  const TaskPriorityLevel({
    required this.key,
    required this.label,
    required this.color,
    this.aliases = const [],
  });

  // Lookup map O(1)
  static final Map<String, TaskPriorityLevel> _lookupMap = () {
    final map = <String, TaskPriorityLevel>{};
    for (final priority in TaskPriorityLevel.values) {
      map[priority.key.toLowerCase()] = priority;
      for (final alias in priority.aliases) {
        map[alias.toLowerCase()] = priority;
      }
    }
    return map;
  }();

  static TaskPriorityLevel fromKey(
    String? key, {
    TaskPriorityLevel fallback = TaskPriorityLevel.medium,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toLowerCase().trim()] ?? fallback;
  }

  /// Danh sách mức độ ưu tiên theo thứ tự từ Thấp đến Khẩn cấp cho Form
  static List<TaskPriorityLevel> get formOptions => [
    TaskPriorityLevel.low,
    TaskPriorityLevel.medium,
    TaskPriorityLevel.high,
    TaskPriorityLevel.urgent,
  ];
}

/// ============================================================================
/// 4. HÌNH THỨC THỜI HẠN CÔNG VIỆC (DEADLINE TYPE)
/// ============================================================================
enum TaskDeadlineType {
  hasDeadline(
    key: 'has_deadline',
    label: 'Có thời hạn',
    icon: Icons.calendar_today_outlined,
    color: AppColors.primary,
    aliases: ['co_han', 'có thời hạn', 'hasdeadline', '1', 'true'],
  ),
  noDeadline(
    key: 'no_deadline',
    label: 'Không có hạn',
    icon: Icons.event_busy_outlined,
    color: AppColors.grey,
    aliases: ['khong_han', 'không có hạn', 'nodeadline', '0', 'false'],
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> aliases;

  const TaskDeadlineType({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    this.aliases = const [],
  });

  static final Map<String, TaskDeadlineType> _lookupMap = () {
    final map = <String, TaskDeadlineType>{};
    for (final type in TaskDeadlineType.values) {
      map[type.key.toLowerCase()] = type;
      for (final alias in type.aliases) {
        map[alias.toLowerCase()] = type;
      }
    }
    return map;
  }();

  static TaskDeadlineType fromKey(
    String? key, {
    TaskDeadlineType fallback = TaskDeadlineType.hasDeadline,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toLowerCase().trim()] ?? fallback;
  }

  static List<TaskDeadlineType> get formOptions => TaskDeadlineType.values;
}
