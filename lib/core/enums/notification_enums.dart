import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// 1. PHÂN LOẠI THÔNG BÁO (NOTIFICATION TYPE)
/// ============================================================================
enum NotificationType {
  voteSuccess(
    key: 'VOTE_SUCCESS',
    label: 'Bầu cử thành công',
    icon: Icons.check_circle_outline,
    color: AppColors.green,
    aliases: ['vote_success', 'voted', 'bau_cu_thanh_cong'],
  ),
  voteWarning(
    key: 'VOTE_WARNING',
    label: 'Cảnh báo bầu cử',
    icon: Icons.warning_amber_rounded,
    color: AppColors.orange,
    aliases: ['vote_warning', 'warning', 'canh_bao'],
  ),
  system(
    key: 'SYSTEM',
    label: 'Thông báo hệ thống',
    icon: Icons.info_outline,
    color: AppColors.blue,
    aliases: ['system', 'he_thong', 'sys'],
  ),
  updateVoter(
    key: 'UPDATE_VOTER',
    label: 'Cập nhật cử tri',
    icon: Icons.person_search_outlined,
    color: AppColors.purple,
    aliases: ['update_voter', 'voter_updated', 'cap_nhat_cu_tri'],
  ),
  task(
    key: 'TASK',
    label: 'Công việc / Nhiệm vụ',
    icon: Icons.assignment_outlined,
    color: AppColors.primary,
    aliases: ['task', 'task_assignment', 'cong_viec'],
  ),
  document(
    key: 'DOCUMENT',
    label: 'Văn bản chỉ đạo',
    icon: Icons.description_outlined,
    color: AppColors.warningOrange,
    aliases: ['document', 'petition', 'van_ban'],
  ),
  general(
    key: 'GENERAL',
    label: 'Thông báo chung',
    icon: Icons.notifications_none,
    color: AppColors.grey,
    aliases: ['general', 'other', 'default', ''],
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> aliases;

  const NotificationType({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    this.aliases = const [],
  });

  static final Map<String, NotificationType> _lookupMap = () {
    final map = <String, NotificationType>{};
    for (final t in NotificationType.values) {
      map[t.key.toUpperCase()] = t;
      for (final alias in t.aliases) {
        map[alias.toUpperCase()] = t;
      }
    }
    return map;
  }();

  static NotificationType fromKey(
    String? key, {
    NotificationType fallback = NotificationType.general,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toUpperCase().trim()] ?? fallback;
  }
}

/// ============================================================================
/// 2. BỘ LỌC TRẠNG THÁI ĐỌC THÔNG BÁO (NOTIFICATION READ FILTER)
/// ============================================================================
enum NotificationReadFilter {
  all(
    key: 'all',
    label: 'Tất cả',
    icon: Icons.notifications_outlined,
  ),
  unread(
    key: 'unread',
    label: 'Chưa đọc',
    icon: Icons.mark_email_unread_outlined,
  ),
  read(
    key: 'read',
    label: 'Đã đọc',
    icon: Icons.mark_email_read_outlined,
  );

  final String key;
  final String label;
  final IconData icon;

  const NotificationReadFilter({
    required this.key,
    required this.label,
    required this.icon,
  });
}
