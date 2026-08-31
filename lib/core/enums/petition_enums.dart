import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// TRẠNG THÁI XỬ LÝ ĐƠN THƯ & KIẾN NGHỊ (PETITION PROCESSING STATUS)
/// ============================================================================
enum PetitionProcessingStatus {
  all(
    key: 'all',
    label: 'Tổng',
    icon: Icons.filter_list,
    color: AppColors.primary,
    aliases: ['tat_ca', 'tatca', 'tất cả', 'tong', 'tổng'],
  ),
  newReceived(
    key: 'new',
    label: 'Mới tiếp nhận',
    icon: Icons.access_time,
    color: AppColors.todo,
    aliases: ['moi_tiep_nhan', 'mới tiếp nhận', 'received', 'created', '0', 'new_received'],
  ),
  processing(
    key: 'processing',
    label: 'Đang xử lý',
    icon: Icons.rotate_right,
    color: AppColors.inProgress,
    aliases: ['in_progress', 'dang_xu_ly', 'đang xử lý', 'running'],
  ),
  completed(
    key: 'completed',
    label: 'Đã hoàn thành',
    icon: Icons.check_circle_outline,
    color: AppColors.done,
    aliases: ['done', 'hoan_thanh', 'hoàn thành', 'finished', 'resolved', '1'],
  ),
  paused(
    key: 'paused',
    label: 'Tạm dừng',
    icon: Icons.pause_circle_outline,
    color: AppColors.paused,
    aliases: ['tam_dung', 'tạm dừng', 'hold', 'pending'],
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

  const PetitionProcessingStatus({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    this.aliases = const [],
  });

  // Lookup map O(1)
  static final Map<String, PetitionProcessingStatus> _lookupMap = () {
    final map = <String, PetitionProcessingStatus>{};
    for (final status in PetitionProcessingStatus.values) {
      map[status.key.toLowerCase()] = status;
      for (final alias in status.aliases) {
        map[alias.toLowerCase()] = status;
      }
    }
    return map;
  }();

  /// Parse cho Entity / Data Model: Mặc định fallback về 'newReceived' (Mới tiếp nhận)
  static PetitionProcessingStatus fromKey(
    String? key, {
    PetitionProcessingStatus fallback = PetitionProcessingStatus.newReceived,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toLowerCase().trim()] ?? fallback;
  }

  /// Parse riêng cho Bộ lọc Filter / Query Param: Mặc định fallback về 'all'
  static PetitionProcessingStatus fromFilterKey(String? key) {
    return fromKey(key, fallback: PetitionProcessingStatus.all);
  }

  /// Danh sách đầy đủ cho thanh Filter, Tabs thống kê (Có 'all')
  static List<PetitionProcessingStatus> get filterOptions => PetitionProcessingStatus.values;

  /// Danh sách cho Dropdown Form Tạo mới/Sửa Đơn thư (Loại bỏ 'all')
  static List<PetitionProcessingStatus> get formOptions =>
      PetitionProcessingStatus.values.where((e) => e != PetitionProcessingStatus.all).toList();

  bool get isCompleted => this == PetitionProcessingStatus.completed;
  bool get isClosed => this == PetitionProcessingStatus.completed || this == PetitionProcessingStatus.cancelled;
  bool get isActive => this == PetitionProcessingStatus.newReceived || this == PetitionProcessingStatus.processing;
}
