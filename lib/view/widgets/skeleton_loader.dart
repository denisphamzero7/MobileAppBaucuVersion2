import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../untils/app_colors.dart';

/// 1. Widget Shimmer cốt lõi (tự động đổi màu theo Light/Dark Theme)
class SkeletonLoader extends StatelessWidget {
  final Widget child;

  const SkeletonLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.grey[800]! : AppColors.grey[300]!,
      highlightColor: isDark ? AppColors.grey[700]! : AppColors.grey[100]!,
      child: child,
    );
  }
}

/// 2. Khối hộp chữ nhật bo góc mẫu
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// 3. Khối tròn mẫu (Avatar / Icon)
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 4. BỘ THƯ VIỆN KHUNG GIAO DIỆN TÁI SỬ DỤNG DÙNG CHUNG TOÀN APP (AppSkeleton)
class AppSkeleton {
  AppSkeleton._();

  /// Ô tìm kiếm mẫu
  static Widget searchBar({double height = 40, double radius = 10}) {
    return SkeletonBox(width: double.infinity, height: height, radius: radius);
  }

  /// Lưới ô thống kê / trạng thái (GridView)
  static Widget grid({
    required int crossAxisCount,
    required int itemCount,
    double childAspectRatio = 1.4,
    double height = 50,
    double radius = 10,
    double spacing = 6,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => SkeletonBox(
        width: double.infinity,
        height: height,
        radius: radius,
      ),
    );
  }

  /// Danh sách các thẻ Card (Task Card, Document Card...)
  static Widget listCards({
    int count = 4,
    double height = 110,
    double radius = 16,
    double verticalPadding = 6.0,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: SkeletonBox(
          width: double.infinity,
          height: height,
          radius: radius,
        ),
      ),
    );
  }

  /// Danh sách các dòng dạng ListTile (Thông báo, Danh bạ, Nhật ký...)
  static Widget listTiles({int count = 5}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SkeletonCircle(size: 40),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: double.infinity, height: 14, radius: 4),
                  SizedBox(height: 6),
                  SkeletonBox(width: 140, height: 10, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// MÀN HÌNH TOÀN DIỆN MẪU: Dạng Quản lý (Search Bar + Lưới 1 + Lưới 2 + Danh sách Card)
  /// Sử dụng cho TaskScreen, DocumentScreen, Quản lý công việc...
  static Widget fullPageLayout({
    int statusGridCount = 7,
    int statusGridCols = 4,
    double statusGridRatio = 1.4,
    int timingGridCount = 6,
    int timingGridCols = 3,
    double timingGridRatio = 2.1,
    int cardCount = 4,
    double cardHeight = 110,
  }) {
    return SkeletonLoader(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search bar
            searchBar(height: 40, radius: 10),
            const SizedBox(height: 20),

            // 2. Tiêu đề 1 + Lưới 1 (Trạng thái)
            const SkeletonBox(width: 140, height: 12, radius: 4),
            const SizedBox(height: 10),
            grid(
              crossAxisCount: statusGridCols,
              itemCount: statusGridCount,
              childAspectRatio: statusGridRatio,
            ),
            const SizedBox(height: 20),

            // 3. Tiêu đề 2 + Lưới 2 (Tiến độ nếu có)
            if (timingGridCount > 0) ...[
              const SkeletonBox(width: 140, height: 12, radius: 4),
              const SizedBox(height: 10),
              grid(
                crossAxisCount: timingGridCols,
                itemCount: timingGridCount,
                childAspectRatio: timingGridRatio,
              ),
              const SizedBox(height: 20),
            ],

            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 14),

            // 4. Danh sách các card
            listCards(count: cardCount, height: cardHeight),
          ],
        ),
      ),
    );
  }

  /// MÀN HÌNH TOÀN DIỆN MẪU: Dạng Trang cá nhân / Chi tiết hồ sơ (Profile / Form)
  static Widget profilePageLayout() {
    return const SkeletonLoader(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top card header
            SkeletonBox(width: double.infinity, height: 180, radius: 20),
            SizedBox(height: 14),
            // Tab bar
            SkeletonBox(width: double.infinity, height: 42, radius: 12),
            SizedBox(height: 14),
            // Form body card
            SkeletonBox(width: double.infinity, height: 260, radius: 18),
          ],
        ),
      ),
    );
  }
}





