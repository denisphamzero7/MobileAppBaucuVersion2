import 'package:flutter/material.dart';
import '../../view/widgets/skeleton_loader.dart';

/// ============================================================================
/// 🌟 [AppPagedListWrapper] - WIDGET ĐIỀU PHỐI CHUYỂN TRANG DANH SÁCH DÙNG CHUNG
/// ============================================================================
/// 
/// 📌 MỤC ĐÍCH:
/// 1. Cung cấp hiệu ứng chuyển trang mượt mà (Smooth Page Transition) cho tất cả
///    danh sách có phân trang trong ứng dụng (Công việc, Văn bản, Cử tri, Thống kê...).
/// 2. Hiển thị khung xương Shimmer cục bộ ([skeleton]) trong lúc nạp trang mới mà
///    KHÔNG làm chớp giật thanh tìm kiếm, các ô đếm thống kê hay thanh phân trang bên ngoài.
/// 3. Loại bỏ 100% việc lặp lại code animation/transition ở nhiều màn hình khác nhau (DRY).
///
/// 🎯 CÁCH SỬ DỤNG:
/// ```dart
/// AppPagedListWrapper(
///   isChangingPage: isPageChanging.value, // Cờ báo hiệu đang đổi trang
///   child: ListView.builder(...),          // Danh sách dữ liệu thật của bạn
/// )
/// ```
class AppPagedListWrapper extends StatelessWidget {
  /// Cờ xác định trạng thái đang nạp / chuyển trang.
  /// Khi là `true`, khung xương [skeleton] sẽ nhấp nháy quét sáng.
  /// Khi là `false`, dữ liệu thật [child] sẽ trượt nhẹ vào êm dịu.
  final bool isChangingPage;

  /// Widget khung xương mô phỏng danh sách đang tải.
  /// Mặc định: 5 thẻ bo góc cao 68px chuẩn thiết kế hệ thống ([AppSkeleton.listCards]).
  final Widget? skeleton;

  /// Widget danh sách dữ liệu thật (thường là [ListView.builder] hoặc [Column]).
  final Widget child;

  /// Thời gian hiệu ứng chuyển đổi mượt (mặc định 220 mili-giây).
  final Duration duration;

  const AppPagedListWrapper({
    super.key,
    required this.isChangingPage,
    this.skeleton,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
  });

  @override
  Widget build(BuildContext context) {
    // Khung xương mặc định mô phỏng 5 thẻ danh sách chuẩn 68px nếu không truyền tùy chỉnh
    final defaultSkeleton = SkeletonLoader(
      child: skeleton ?? AppSkeleton.listCards(count: 5, height: 68),
    );

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      // Hiệu ứng Fade mờ dần + Trượt nhẹ 3% từ dưới lên giúp thị giác người dùng êm dịu
      transitionBuilder: (Widget currentChild, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.03),
              end: Offset.zero,
            ).animate(animation),
            child: currentChild,
          ),
        );
      },
      child: isChangingPage
          ? KeyedSubtree(
              key: const ValueKey<String>('paged_list_skeleton_state'),
              child: defaultSkeleton,
            )
          : KeyedSubtree(
              key: const ValueKey<String>('paged_list_content_state'),
              child: child,
            ),
    );
  }
}
