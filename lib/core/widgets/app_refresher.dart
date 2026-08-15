import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// Helper / Widget tái sử dụng cho tính năng kéo vuốt tải lại dữ liệu (Pull to Refresh)
///
/// Ví dụ sử dụng:
/// ```dart
/// AppRefresher(
///   onRefresh: () async {
///     await controller.refreshData();
///   },
///   child: Column(...),
/// )
/// ```
class AppRefresher extends StatelessWidget {
  /// Hàm async được gọi khi kéo vuốt tải lại
  final Future<void> Function() onRefresh;

  /// Widget nội dung
  final Widget child;

  /// ScrollController tùy chọn nếu muốn theo dõi vị trí cuộn
  final ScrollController? controller;

  /// Padding bao quanh nội dung
  final EdgeInsetsGeometry? padding;

  /// Màu sắc của vòng quay loading
  final Color? color;

  /// Màu nền của vòng quay
  final Color? backgroundColor;

  /// Nếu `child` đã là Scrollable (ListView, CustomScrollView...), đặt true
  /// Nếu `child` là Widget thông thường (Column, Container...), để mặc định false
  final bool isScrollable;

  const AppRefresher({
    super.key,
    required this.onRefresh,
    required this.child,
    this.controller,
    this.padding,
    this.color,
    this.backgroundColor,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (!isScrollable) {
      content = SingleChildScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: child,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.primary,
      backgroundColor: backgroundColor,
      child: content,
    );
  }
}
