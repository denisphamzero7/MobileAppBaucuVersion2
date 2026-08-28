import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// 1. PHƯƠNG THỨC HTTP / HÀNH ĐỘNG NHẬT KÝ
enum LogActivityMethod {
  get(
    method: 'GET',
    label: 'Xem / Truy cập',
    color: AppColors.primary,
    icon: Icons.visibility_outlined,
  ),
  post(
    method: 'POST',
    label: 'Tạo mới',
    color: AppColors.done,
    icon: Icons.add_circle_outline,
  ),
  put(
    method: 'PUT',
    label: 'Cập nhật',
    color: AppColors.warningOrange,
    icon: Icons.edit_outlined,
  ),
  patch(
    method: 'PATCH',
    label: 'Chỉnh sửa',
    color: AppColors.warningOrange,
    icon: Icons.edit_note_outlined,
  ),
  delete(
    method: 'DELETE',
    label: 'Xóa',
    color: AppColors.dangerText,
    icon: Icons.delete_outline,
  );

  final String method;
  final String label;
  final Color color;
  final IconData icon;

  const LogActivityMethod({
    required this.method,
    required this.label,
    required this.color,
    required this.icon,
  });

  static LogActivityMethod fromString(String? methodStr) {
    if (methodStr == null) return LogActivityMethod.get;
    final upper = methodStr.toUpperCase().trim();
    return LogActivityMethod.values.firstWhere(
      (e) => e.method == upper,
      orElse: () => LogActivityMethod.get,
    );
  }
}

/// 2. TAB PHÂN LOẠI NHẬT KÝ
enum LogActivityTab {
  overview(
    index: 0,
    label: 'Tổng quan',
    icon: Icons.dashboard_outlined,
  ),
  personalInfo(
    index: 1,
    label: 'Thông tin cá nhân',
    icon: Icons.person_outline,
  ),
  securitySettings(
    index: 2,
    label: 'Cài đặt bảo mật',
    icon: Icons.security_outlined,
  );

  final int index;
  final String label;
  final IconData icon;

  const LogActivityTab({
    required this.index,
    required this.label,
    required this.icon,
  });
}
