import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// Component điều phối hiển thị thông minh:
/// 1. Khi đang tải lần đầu (chưa có data) HOẶC khi chủ động vuốt làm mới -> Hiển thị Skeleton Loader.
/// 2. Khi đã có data trong bộ nhớ -> Hiển thị ngay lập tức (không chớp màn hình khi chuyển tab).
/// 3. Tự động tích hợp Pull-to-refresh mượt mà.
class SmartSkeletonWrapper extends StatelessWidget {
  final bool showSkeleton;
  final Widget skeleton;
  final Widget child;
  final Future<void> Function()? onRefresh;
  final Color? refreshIndicatorColor;

  const SmartSkeletonWrapper({
    super.key,
    required this.showSkeleton,
    required this.skeleton,
    required this.child,
    this.onRefresh,
    this.refreshIndicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    if (showSkeleton) {
      return skeleton;
    }

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: refreshIndicatorColor ?? AppColors.primary,
        child: child,
      );
    }

    return child;
  }
}
