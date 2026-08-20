import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// 🌟 [SmartSkeletonWrapper] - THÀNH PHẦN ĐIỀU PHỐI GIAO DIỆN TẢI THÔNG MINH
/// ============================================================================
/// 
/// 📌 MỤC ĐÍCH:
/// Đóng gói toàn bộ luồng hiển thị giữa **Khung xương (Skeleton)**, **Kéo làm mới (Pull-to-refresh)**,
/// và **Giao diện dữ liệu thật**, giúp loại bỏ 100% lỗi xung đột/phân mảnh loading trong toàn bộ dự án.
///
/// 🎯 NGUYÊN TẮC HOẠT ĐỘNG (Standard Architecture Pattern):
/// 1. **Khi đang tải dữ liệu (`showSkeleton == true`)**:
///    - Lập tức hiển thị [skeleton] (khung xương mô phỏng 1-1 toàn trang).
///    - Ngăn chặn triệt để hiện tượng chớp màn hình trắng hoặc hiện giao diện rỗng trước khi có data.
/// 2. **Khi đã có dữ liệu (`showSkeleton == false`)**:
///    - Hiển thị ngay lập tức [child] (dữ liệu thật) mà không có bất kỳ độ trễ nào.
///    - Khi chuyển qua lại giữa các Tab đã có data: Không bao giờ bị nhấp nháy lại Skeleton.
/// 3. **Khi người dùng chủ động vuốt xuống để làm mới (`onRefresh != null`)**:
///    - Tự động bọc [RefreshIndicator] để kích hoạt lại quá trình nạp dữ liệu mới nhất từ server.
///
/// 💡 CÁCH DÙNG CHUẨN TRONG MỌI TRANG MỚI:
/// ```dart
/// SmartSkeletonWrapper(
///   showSkeleton: controller.isLoading.value,     // 👈 Cờ điều kiện từ GetX Controller
///   skeleton: AppSkeleton.fullPageLayout(...),      // 👈 Mẫu khung xương từ AppSkeleton
///   onRefresh: () => controller.fetchData(...),     // 👈 Hàm tải lại dữ liệu khi vuốt xuống
///   child: SingleChildScrollView(child: ...),       // 👈 Giao diện thật khi tải xong
/// )
/// ```
class SmartSkeletonWrapper extends StatelessWidget {
  /// Cờ xác định có đang hiển thị khung xương hay không.
  /// Thường được liên kết trực tiếp với biến phản ứng `controller.isLoading.value` hoặc `isTypeLoading()`.
  final bool showSkeleton;

  /// Widget khung xương hiển thị khi [showSkeleton] là `true`.
  /// Khuyên dùng các mẫu có sẵn trong [AppSkeleton] (ví dụ: `AppSkeleton.fullPageLayout()`, `AppSkeleton.statisticPageLayout()`).
  final Widget skeleton;

  /// Widget giao diện dữ liệu thật sẽ được hiển thị khi [showSkeleton] là `false`.
  /// Lưu ý: Bên trong [child] KHÔNG được viết thêm các lệnh `if (isLoading)` rải rác.
  final Widget child;

  /// Hàm bất đồng bộ kích hoạt khi người dùng kéo màn hình xuống để làm mới (Pull-to-refresh).
  /// Nếu truyền `null`, màn hình sẽ không có tính năng kéo làm mới.
  final Future<void> Function()? onRefresh;

  /// Màu sắc của con quay khi kéo làm mới (mặc định lấy [AppColors.primary]).
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
    // 1. Nếu đang ở trạng thái nạp dữ liệu -> Hiển thị khung xương toàn trang
    if (showSkeleton) {
      return skeleton;
    }

    // 2. Nếu đã có dữ liệu thật và có hỗ trợ vuốt làm mới -> Bọc RefreshIndicator
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: refreshIndicatorColor ?? AppColors.primary,
        child: child,
      );
    }

    // 3. Hiển thị dữ liệu thật thuần túy
    return child;
  }
}
