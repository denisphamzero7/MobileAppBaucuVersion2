import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

enum TaskDocumentStatus {
  all(
    key: 'all',
    label: 'Tổng số',
    icon: Icons.description_outlined,
    color: AppColors.primary,
  ),
  published(
    key: 'published',
    label: 'Đã ban hành',
    icon: Icons.check_circle_outline,
    color: AppColors.done,
  ),
  draft(
    key: 'draft',
    label: 'Bản nháp',
    icon: Icons.access_time_outlined,
    color: AppColors.paused,
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const TaskDocumentStatus({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  static TaskDocumentStatus fromKey(String? key) {
    return TaskDocumentStatus.values.firstWhere(
      (e) => e.key == key,
      orElse: () => TaskDocumentStatus.all,
    );
  }
}
