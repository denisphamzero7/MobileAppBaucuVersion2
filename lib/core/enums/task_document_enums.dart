import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// TRẠNG THÁI VĂN BẢN GIAO VIỆC (TASK DOCUMENT STATUS)
/// ============================================================================
enum TaskDocumentStatus {
  all(
    key: 'all',
    label: 'Tổng số',
    icon: Icons.description_outlined,
    color: AppColors.primary,
    aliases: ['tat_ca', 'tatca', 'tổng số', 'tong_so', 'tong'],
  ),
  published(
    key: 'published',
    label: 'Đã ban hành',
    icon: Icons.check_circle_outline,
    color: AppColors.done,
    aliases: ['issued', 'active', '1', 'done', 'ban_hanh', 'đã ban hành', 'ban hành'],
  ),
  draft(
    key: 'draft',
    label: 'Bản nháp',
    icon: Icons.access_time_outlined,
    color: AppColors.paused,
    aliases: ['0', 'pending', 'nhap', 'bản nháp', 'bản_nháp'],
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> aliases;

  const TaskDocumentStatus({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    this.aliases = const [],
  });

  // Lookup map O(1)
  static final Map<String, TaskDocumentStatus> _lookupMap = () {
    final map = <String, TaskDocumentStatus>{};
    for (final status in TaskDocumentStatus.values) {
      map[status.key.toLowerCase()] = status;
      for (final alias in status.aliases) {
        map[alias.toLowerCase()] = status;
      }
    }
    return map;
  }();

  /// Parse cho Entity / Data Model: Mặc định fallback về 'draft' (Bản nháp)
  static TaskDocumentStatus fromKey(
    String? key, {
    TaskDocumentStatus fallback = TaskDocumentStatus.draft,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toLowerCase().trim()] ?? fallback;
  }

  /// Parse riêng cho Bộ lọc Filter / Query Param: Mặc định fallback về 'all'
  static TaskDocumentStatus fromFilterKey(String? key) {
    return fromKey(key, fallback: TaskDocumentStatus.all);
  }

  /// Danh sách đầy đủ cho thanh Filter, Tabs thống kê (Có 'all')
  static List<TaskDocumentStatus> get filterOptions => TaskDocumentStatus.values;

  /// Danh sách cho Dropdown Form Tạo mới/Sửa Văn bản (Loại bỏ 'all')
  static List<TaskDocumentStatus> get formOptions =>
      TaskDocumentStatus.values.where((e) => e != TaskDocumentStatus.all).toList();

  bool get isPublished => this == TaskDocumentStatus.published;
  bool get isDraft => this == TaskDocumentStatus.draft;
}
