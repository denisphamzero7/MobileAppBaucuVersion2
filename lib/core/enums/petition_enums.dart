import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

enum PetitionProcessingStatus {
  all(
    key: 'all',
    label: 'Tổng',
    icon: Icons.filter_list,
    color: AppColors.primary,
  ),
  newReceived(
    key: 'new',
    label: 'Mới tiếp nhận',
    icon: Icons.access_time,
    color: AppColors.todo,
  ),
  processing(
    key: 'processing',
    label: 'Đang xử lý',
    icon: Icons.rotate_right,
    color: AppColors.inProgress,
  ),
  completed(
    key: 'completed',
    label: 'Đã hoàn thành',
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

  const PetitionProcessingStatus({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  static PetitionProcessingStatus fromKey(String? key) {
    return PetitionProcessingStatus.values.firstWhere(
      (e) => e.key == key,
      orElse: () => PetitionProcessingStatus.all,
    );
  }
}
