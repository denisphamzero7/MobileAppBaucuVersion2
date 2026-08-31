import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// 1. TRẠNG THÁI BỎ PHIẾU CỦA CỬ TRI (VOTER STATUS)
/// ============================================================================
enum VoterStatus {
  all(
    key: 'all',
    label: 'Tất cả cử tri',
    icon: Icons.people_outline,
    color: AppColors.primary,
    aliases: ['tat_ca', 'tatca'],
  ),
  notVoted(
    key: 'not_voted',
    label: 'Chưa bỏ phiếu',
    icon: Icons.access_time,
    color: AppColors.paused,
    aliases: ['chua_bo_phieu', 'chua_bau', '0', 'pending'],
  ),
  voted(
    key: 'voted',
    label: 'Đã bỏ phiếu',
    icon: Icons.check_circle_outline,
    color: AppColors.done,
    aliases: ['da_bo_phieu', 'da_bau', '1', 'completed'],
  ),
  absent(
    key: 'absent',
    label: 'Vắng mặt',
    icon: Icons.cancel_outlined,
    color: AppColors.cancelled,
    aliases: ['vang_mat', 'vang', '2'],
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> aliases;

  const VoterStatus({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    this.aliases = const [],
  });

  static final Map<String, VoterStatus> _lookupMap = () {
    final map = <String, VoterStatus>{};
    for (final s in VoterStatus.values) {
      map[s.key.toLowerCase()] = s;
      for (final alias in s.aliases) {
        map[alias.toLowerCase()] = s;
      }
    }
    return map;
  }();

  static VoterStatus fromKey(
    String? key, {
    VoterStatus fallback = VoterStatus.notVoted,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toLowerCase().trim()] ?? fallback;
  }

  static VoterStatus fromFilterKey(String? key) {
    return fromKey(key, fallback: VoterStatus.all);
  }

  static List<VoterStatus> get filterOptions => VoterStatus.values;
  static List<VoterStatus> get formOptions =>
      VoterStatus.values.where((e) => e != VoterStatus.all).toList();

  bool get isVoted => this == VoterStatus.voted;
}

/// ============================================================================
/// 2. KẾT QUẢ QUÉT MÃ QR / CCCD CỬ TRI (VOTER SCAN RESULT)
/// ============================================================================
enum VoterScanResult {
  valid(
    key: 'VALID',
    label: 'Hợp lệ',
    icon: Icons.verified_outlined,
    color: AppColors.green,
  ),
  alreadyVoted(
    key: 'ALREADY_VOTED',
    label: 'Đã bỏ phiếu trước đó',
    icon: Icons.warning_amber_rounded,
    color: AppColors.orange,
  ),
  invalid(
    key: 'INVALID',
    label: 'Mã QR không hợp lệ',
    icon: Icons.error_outline,
    color: AppColors.dangerText,
  ),
  notFound(
    key: 'NOT_FOUND',
    label: 'Không tìm thấy cử tri',
    icon: Icons.person_off_outlined,
    color: AppColors.grey,
  ),
  error(
    key: 'ERROR',
    label: 'Lỗi hệ thống khi quét',
    icon: Icons.sync_problem_outlined,
    color: AppColors.dangerText,
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const VoterScanResult({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
}
