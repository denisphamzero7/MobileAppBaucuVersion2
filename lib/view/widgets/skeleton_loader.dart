import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// 🎨 [AppSkeleton] & [SkeletonLoader] - HỆ THỐNG THIẾT KẾ KHUNG XƯƠNG (DESIGN SYSTEM)
/// ============================================================================
/// 
/// 📌 NGUYÊN TẮC THIẾT KẾ KHUNG XƯƠNG (SKELETON DESIGN RULES):
/// 1. **Mô phỏng 1-1 với Widget Thật (Pixel Match)**:
///    - Chiều cao (`height`), độ bo góc (`radius`), khoảng cách (`padding`, `margin`) của Skeleton
///      phải trùng khớp chính xác với kích thước thực tế của thẻ dữ liệu thật.
///    - Ví dụ: Thẻ Thật cao 92px thì `SkeletonBox(height: 92)` -> Đảm bảo khi dữ liệu tải xong,
///      giao diện chuyển đổi êm ái (Seamless Transition), không bị nhảy giật hay phình to kích thước.
/// 2. **Tự động thích ứng Chế độ Sáng/Tối (Light/Dark Theme)**:
///    - Sáng: Quét dải màu xám nhạt `grey[300]` <-> `grey[100]`.
///    - Tối: Quét dải màu xám đậm `grey[800]` <-> `grey[700]`.
/// 3. **Lấp đầy tầm nhìn (Fill the Viewport)**:
///    - Danh sách thẻ luôn để mặc định 4-5 thẻ để vừa khít chiều dài màn hình điện thoại.

/// ============================================================================
/// 1. WIDGET SHIMMER CỐT LÕI (Hiệu ứng quét sáng lượn sóng)
/// ============================================================================
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

/// ============================================================================
/// 2. CÁC KHỐI HÌNH HỌC CƠ BẢN (Primitives)
/// ============================================================================

/// Khối hộp chữ nhật bo góc mẫu
class SkeletonBox extends StatelessWidget {
  /// Chiều rộng: Dùng [double.infinity] để tràn viền, hoặc số pixel cụ thể (VD: 140 cho tiêu đề chữ).
  final double width;
  /// Chiều cao: Đo chính xác theo widget thật (VD: 40 cho search bar, 92 cho card list).
  final double height;
  /// Độ bo góc (Mặc định bo 8px).
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

/// Khối tròn mẫu (Dùng cho Avatar, Icon tròn, Huy hiệu trạng thái)
class SkeletonCircle extends StatelessWidget {
  /// Đường kính hình tròn (pixel).
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

/// ============================================================================
/// 3. BỘ SƯU TẬP KHUNG XƯƠNG MẪU CHO CÁC LOẠI MÀN HÌNH (Layout Templates)
/// ============================================================================
class AppSkeleton {
  /// 🔍 Khung xương Thanh tìm kiếm (Search Bar)
  static Widget searchBar({double height = 40, double radius = 10}) {
    return SkeletonBox(
      width: double.infinity,
      height: height,
      radius: radius,
    );
  }

  /// 🔲 Khung xương Lưới ô số liệu (Grid ô Trạng thái xử lý / Tiến độ)
  static Widget grid({
    required int crossAxisCount,
    required int itemCount,
    double childAspectRatio = 1.4,
    double crossAxisSpacing = 6.0,
    double mainAxisSpacing = 6.0,
    double height = 44,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => SkeletonBox(
        width: double.infinity,
        height: height,
        radius: 10,
      ),
    );
  }

  /// 📄 Danh sách các thẻ Card xếp dọc (Task Card, Document Card, Lịch sử...)
  /// [count]: Số lượng thẻ (mặc định 5 thẻ để lấp đầy màn hình).
  /// [height]: Chiều cao từng thẻ (chuẩn 68px khớp chính xác 1-1 với thẻ thật).
  static Widget listCards({
    int count = 5,
    double height = 68,
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

  /// 👤 Danh sách các dòng ListTile (Avatar tròn + Tiêu đề + Dòng mô tả)
  /// Dùng cho: Màn hình Thông báo, Danh bạ người dùng, Nhật ký hoạt động...
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

  /// 📋 MÀN HÌNH MẪU: Quản lý Danh sách (TaskScreen, DocumentScreen...)
  /// Bao gồm từ trên xuống dưới:
  /// 1. Thanh tìm kiếm (Search Bar)
  /// 2. Lưới Trạng thái xử lý (6-7 ô)
  /// 3. Lưới Tiến độ công việc (nếu có)
  /// 4. Danh sách 5 Thẻ công việc/đơn thư (cao 68px khớp chính xác 1-1)
  static Widget fullPageLayout({
    int statusGridCount = 7,
    int statusGridCols = 4,
    double statusGridRatio = 1.4,
    int timingGridCount = 6,
    int timingGridCols = 3,
    double timingGridRatio = 2.1,
    int cardCount = 5,
    double cardHeight = 68,
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
            const SizedBox(height: 16),

            // 2. Tiêu đề 1 + Lưới 1 (Trạng thái)
            const SkeletonBox(width: 140, height: 12, radius: 4),
            const SizedBox(height: 8),
            grid(
              crossAxisCount: statusGridCols,
              itemCount: statusGridCount,
              childAspectRatio: statusGridRatio,
            ),
            const SizedBox(height: 16),

            // 3. Tiêu đề 2 + Lưới 2 (Tiến độ - nếu có)
            if (timingGridCount > 0) ...[
              const SkeletonBox(width: 130, height: 12, radius: 4),
              const SizedBox(height: 8),
              grid(
                crossAxisCount: timingGridCols,
                itemCount: timingGridCount,
                childAspectRatio: timingGridRatio,
              ),
              const SizedBox(height: 16),
            ],

            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 10),

            // 4. Danh sách các card (chuẩn 68px)
            listCards(count: cardCount, height: cardHeight),
          ],
        ),
      ),
    );
  }

  /// 👤 MÀN HÌNH MẪU: Trang cá nhân / Chi tiết hồ sơ (UserScreen, Profile / Form)
  /// Bao gồm: Header Avatar lớn + Thanh Tab Bar + Form nhập liệu
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

  /// 📊 MÀN HÌNH MẪU: Thống kê & Báo cáo biểu đồ (StatisticScreen)
  /// Bao gồm:
  /// 1. Card Bộ lọc thời gian & phòng ban
  /// 2. Lưới 7 ô Trạng thái xử lý
  /// 3. Lưới 6 ô Tiến độ công việc
  /// 4. Hai Card Biểu đồ tròn Donut song song
  /// 5. Card Phân bổ chi tiết phòng ban
  static Widget statisticPageLayout() {
    return SkeletonLoader(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Filter card (Ngày + Phòng ban)
            const SkeletonBox(width: double.infinity, height: 95, radius: 14),
            const SizedBox(height: 14),

            // 2. Tiêu đề + Lưới TRẠNG THÁI XỬ LÝ (7 ô)
            const SkeletonBox(width: 140, height: 12, radius: 4),
            const SizedBox(height: 10),
            grid(crossAxisCount: 3, itemCount: 3, childAspectRatio: 2.1, height: 44),
            const SizedBox(height: 6),
            grid(crossAxisCount: 4, itemCount: 4, childAspectRatio: 1.4, height: 44),
            const SizedBox(height: 16),

            // 3. Tiêu đề + Lưới TIẾN ĐỘ CÔNG VIỆC (6 ô)
            const SkeletonBox(width: 130, height: 12, radius: 4),
            const SizedBox(height: 10),
            grid(crossAxisCount: 3, itemCount: 6, childAspectRatio: 2.1, height: 44),
            const SizedBox(height: 16),

            // 4. Hai Card BIỂU ĐỒ TRÒN song song
            const Row(
              children: [
                Expanded(
                  child: SkeletonBox(width: double.infinity, height: 170, radius: 18),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SkeletonBox(width: double.infinity, height: 170, radius: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. Card PHÂN BỐ CHI TIẾT
            const SkeletonBox(width: double.infinity, height: 160, radius: 18),
          ],
        ),
      ),
    );
  }
}
