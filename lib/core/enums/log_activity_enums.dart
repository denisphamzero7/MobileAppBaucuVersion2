import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// 1. PHƯƠNG THỨC HTTP / HÀNH ĐỘNG NHẬT KÝ (LOG ACTIVITY METHOD)
/// ============================================================================
enum LogActivityMethod {
  get(
    method: 'GET',
    label: 'Xem / Truy cập',
    color: AppColors.primary,
    icon: Icons.visibility_outlined,
    aliases: ['read', 'view', 'access'],
  ),
  post(
    method: 'POST',
    label: 'Tạo mới',
    color: AppColors.done,
    icon: Icons.add_circle_outline,
    aliases: ['create', 'add', 'insert'],
  ),
  put(
    method: 'PUT',
    label: 'Cập nhật',
    color: AppColors.warningOrange,
    icon: Icons.edit_outlined,
    aliases: ['update', 'replace'],
  ),
  patch(
    method: 'PATCH',
    label: 'Chỉnh sửa',
    color: AppColors.warningOrange,
    icon: Icons.edit_note_outlined,
    aliases: ['modify', 'partial_update'],
  ),
  delete(
    method: 'DELETE',
    label: 'Xóa',
    color: AppColors.dangerText,
    icon: Icons.delete_outline,
    aliases: ['remove', 'destroy'],
  );

  final String method;
  final String label;
  final Color color;
  final IconData icon;
  final List<String> aliases;

  const LogActivityMethod({
    required this.method,
    required this.label,
    required this.color,
    required this.icon,
    this.aliases = const [],
  });

  String get key => method;

  // Lookup map O(1)
  static final Map<String, LogActivityMethod> _lookupMap = () {
    final map = <String, LogActivityMethod>{};
    for (final m in LogActivityMethod.values) {
      map[m.method.toUpperCase()] = m;
      for (final alias in m.aliases) {
        map[alias.toUpperCase()] = m;
      }
    }
    return map;
  }();

  static LogActivityMethod fromKey(
    String? methodStr, {
    LogActivityMethod fallback = LogActivityMethod.get,
  }) {
    if (methodStr == null || methodStr.trim().isEmpty) return fallback;
    return _lookupMap[methodStr.toUpperCase().trim()] ?? fallback;
  }

  /// Tương thích ngược với các nơi đang gọi fromString
  static LogActivityMethod fromString(String? methodStr) => fromKey(methodStr);
}

/// ============================================================================
/// 2. TAB PHÂN LOẠI NHẬT KÝ
/// ============================================================================
enum LogActivityTab {
  overview(
    label: 'Tổng quan',
    icon: Icons.dashboard_outlined,
  ),
  personalInfo(
    label: 'Thông tin cá nhân',
    icon: Icons.person_outline,
  ),
  securitySettings(
    label: 'Cài đặt bảo mật',
    icon: Icons.security_outlined,
  );

  final String label;
  final IconData icon;

  const LogActivityTab({
    required this.label,
    required this.icon,
  });
}
