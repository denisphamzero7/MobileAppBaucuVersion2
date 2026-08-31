import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// 1. VAI TRÒ NGƯỜI DÙNG / PHÂN QUYỀN (USER ROLE)
/// ============================================================================
enum UserRole {
  superAdmin(
    key: 'super_admin',
    label: 'Quản trị cấp cao',
    icon: Icons.shield_outlined,
    color: AppColors.priorityUrgent,
    aliases: ['superadmin', 'root'],
  ),
  admin(
    key: 'admin',
    label: 'Quản trị viên',
    icon: Icons.admin_panel_settings_outlined,
    color: AppColors.primary,
    aliases: ['administrator'],
  ),
  manager(
    key: 'manager',
    label: 'Lãnh đạo / Quản lý',
    icon: Icons.manage_accounts_outlined,
    color: AppColors.warningOrange,
    aliases: ['leader', 'lanh_dao', 'quan_ly'],
  ),
  specialist(
    key: 'specialist',
    label: 'Chuyên viên',
    icon: Icons.badge_outlined,
    color: AppColors.inProgress,
    aliases: ['officer', 'chuyen_vien', 'staff'],
  ),
  user(
    key: 'user',
    label: 'Người dùng',
    icon: Icons.person_outline,
    color: AppColors.grey,
    aliases: ['member', 'nguoi_dung'],
  ),
  voter(
    key: 'voter',
    label: 'Cử tri',
    icon: Icons.how_to_vote_outlined,
    color: AppColors.done,
    aliases: ['cu_tri', 'citizen'],
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> aliases;

  const UserRole({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    this.aliases = const [],
  });

  static final Map<String, UserRole> _lookupMap = () {
    final map = <String, UserRole>{};
    for (final r in UserRole.values) {
      map[r.key.toLowerCase()] = r;
      for (final alias in r.aliases) {
        map[alias.toLowerCase()] = r;
      }
    }
    return map;
  }();

  static UserRole fromKey(
    String? key, {
    UserRole fallback = UserRole.user,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toLowerCase().trim()] ?? fallback;
  }

  bool get isAdminOrHigher => this == UserRole.superAdmin || this == UserRole.admin;
  bool get isManagerOrHigher => isAdminOrHigher || this == UserRole.manager;
}

/// ============================================================================
/// 2. GIỚI TÍNH (GENDER)
/// ============================================================================
enum Gender {
  male(
    key: 'male',
    label: 'Nam',
    icon: Icons.male_outlined,
    aliases: ['nam', '1', 'm'],
  ),
  female(
    key: 'female',
    label: 'Nữ',
    icon: Icons.female_outlined,
    aliases: ['nu', 'nữ', '0', 'f'],
  ),
  other(
    key: 'other',
    label: 'Khác',
    icon: Icons.transgender_outlined,
    aliases: ['khac', 'khác', '2', 'unknown'],
  );

  final String key;
  final String label;
  final IconData icon;
  final List<String> aliases;

  const Gender({
    required this.key,
    required this.label,
    required this.icon,
    this.aliases = const [],
  });

  static final Map<String, Gender> _lookupMap = () {
    final map = <String, Gender>{};
    for (final g in Gender.values) {
      map[g.key.toLowerCase()] = g;
      for (final alias in g.aliases) {
        map[alias.toLowerCase()] = g;
      }
    }
    return map;
  }();

  static Gender fromKey(
    String? key, {
    Gender fallback = Gender.male,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toLowerCase().trim()] ?? fallback;
  }
}
