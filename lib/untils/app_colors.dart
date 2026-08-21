import 'package:flutter/material.dart';

class AppColors {
  // --- TÔNG MÀU CHỦ ĐẠO / THƯƠNG HIỆU ---
  static const Color primary = Color(0xFF2563EB); // Xanh dương chủ đạo
  static const Color darkBlue = Color(0xFF1E3A8A); // Xanh navy đậm
  static const Color deepBlue = Color(0xFF0F172A); // Xanh tối
  static const Color themePrimary = Color(0xFF007FFF); // Xanh dương chủ đạo của Theme
  static const Color snackbarBlue = Color(0xFF0052CC); // Xanh đậm cho Snackbar

  // --- HỆ THỐNG MÀU TRẠNG THÁI XỬ LÝ (STATUS COLORS) ---
  static const Color todo = Color(0xFF8B5CF6); // Chưa làm (Tím)
  static const Color inProgress = Color(0xFF0EA5E9); // Đang làm (Xanh da trời)
  static const Color pendingApproval = Color(0xFFD946EF); // Chờ duyệt (Hồng cánh sen)
  static const Color done = Color(0xFF10B981); // Hoàn thành (Xanh lá)
  static const Color paused = Color(0xFFF59E0B); // Tạm dừng (Cam)
  static const Color cancelled = Color(0xFF6B7280); // Đã hủy (Xám)

  // --- HỆ THỐNG MÀU TIẾN ĐỘ THỜI GIAN (TIMING/SCHEDULE COLORS) ---
  static const Color upcoming = Color(0xFF0EA5E9); // Chưa đến hạn (Xanh da trời)
  static const Color early = Color(0xFF10B981); // Sớm hạn (Xanh lá)
  static const Color onTime = Color(0xFF4F46E5); // Đúng hạn (Xanh chàm/Indigo)
  static const Color late = Color(0xFFEC4899); // Trễ hạn (Hồng nhạt)
  static const Color overdue = Color(0xFFEF4444); // Quá hạn (Đỏ)
  static const Color timingCancelled = Color(0xFF6B7280); // Đã hủy (Xám)

  // --- MÀU GIAO DIỆN & NỀN THẺ (UI & BACKGROUNDS) ---
  static const Color lightBg = Color(0xFFF3F4F6); // Nền sáng mặc định
  static const Color pageBg = Color(0xFFF8FAFC); // Nền trang Slate nhạt
  static const Color darkBg = Color(0xFF121212); // Nền tối
  static const Color cardLight = Colors.white; // Thẻ sáng
  static const Color cardDark = Color(0xFF1E1E1E); // Thẻ tối
  static const Color cardItemDark = Color(0xFF2D2D2D); // Thẻ con tối

  // --- NHÃN VÀ VIỀN PHỤ TRỢ (BADGES & BORDERS) ---
  static const Color badgeBlueBg = Color(0xFFEFF6FF); // Nền badge xanh lam
  static const Color badgeGreenBg = Color(0xFFECFDF5); // Nền badge xanh lá
  static const Color badgeRedBg = Color(0xFFFEE2E2); // Nền badge đỏ
  static const Color borderLight = Color(0xFFF1F5F9); // Nền / viền nhạt
  static const Color borderGrey = Color(0xFFE2E8F0); // Viền xám chuẩn
  static const Color borderGreen = Color(0xFFA7F3D0); // Viền xanh lá
  static const Color borderBlue = Color(0xFFBFDBFE); // Viền xanh dương
  static const Color borderAmber = Color(0xFFFDE68A); // Viền vàng hổ phách

  // --- CẢNH BÁO & KHÓA (WARNING & BANNER COLORS) ---
  static const Color warningBg = Color(0xFFFFFBEB); // Nền banner cảnh báo
  static const Color warningBorder = Color(0xFFFDE68A); // Viền banner cảnh báo
  static const Color warningText = Color(0xFF92400E); // Chữ banner cảnh báo
  static const Color warningOrange = Color(0xFFD97706); // Cam nút cảnh báo / Mở khóa

  // --- NGUY HIỂM / NÚT XÓA (DANGER COLORS) ---
  static const Color dangerBg = Color(0xFFFEF2F2); // Nền nút xóa / nguy hiểm
  static const Color dangerText = Color(0xFFDC2626); // Chữ đỏ nút xóa
  static const Color dangerBorder = Color(0xFFFECACA); // Viền đỏ

  // --- MÀU CHỮ SLATE CHUẨN (TYPOGRAPHY COLORS) ---
  static const Color textHeading = Color(0xFF0F172A); // Chữ tiêu đề tối
  static const Color textMain = Color(0xFF1E293B); // Chữ nội dung chính
  static const Color textMuted = Color(0xFF64748B); // Chữ phụ / nhãn
  static const Color textSub = Color(0xFF94A3B8); // Chữ gợi ý / mờ
  static const Color textGreen = Color(0xFF059669); // Chữ xanh lá đậm
  static const Color textGrayDark = Color(0xFF4B5563); // Xám đậm
  static const Color textTeal = Color(0xFF0D9488); // Xanh ngọc
  static const Color textGreenDark = Color(0xFF047857); // Xanh lá đậm
  static const Color textBlueDark = Color(0xFF1D4ED8); // Xanh dương đậm
  static const Color textRedDark = Color(0xFFBE123C); // Đỏ thẫm
  static const Color textRedVeryDark = Color(0xFF991B1B); // Đỏ rất đậm
  static const Color textOrangeAlert = Color(0xFFFBBF24); // Cam cảnh báo

  // --- MÀU BACKGROUND TRONG GRID (GRID BACKGROUND COLORS) ---
  static const Color bgPurpleLight = Color(0xFFF5F3FF); // Nền tím nhạt
  static const Color bgGrayLight = Color(0xFFF9FAFB); // Nền xám nhạt
  static const Color bgBlueLight = Color(0xFFF0F9FF); // Nền xanh da trời nhạt
  static const Color bgPurpleVeryLight = Color(0xFFFDF4FF); // Nền tím rất nhạt
  static const Color bgYellowLight = Color(0xFFFFFBEB); // Nền vàng nhạt
  static const Color bgTealLight = Color(0xFFF0FDFA); // Nền xanh ngọc nhạt
  static const Color bgRedVeryLight = Color(0xFFFFF1F2); // Nền đỏ rất nhạt
  static const Color bgRedLight = Color(0xFFFEF2F2); // Nền đỏ nhạt

  // --- MÀU KHÁC & ĐỘ TRONG SUỐT ---
  static const Color transparentWhite = Color(0x80FFFFFF); // Trắng 50%
  static const Color transparentw = Color(0x4DF3F4F6); // Xám nhạt trong suốt

  // --- MÀU CƠ BẢN (BASIC COLORS) ---
  static const Color black = Colors.black;
  static const Color black12 = Colors.black12;
  static const Color black26 = Colors.black26;
  static const Color black54 = Colors.black54;
  static const Color black87 = Colors.black87;
  static const Color white = Colors.white;
  static const Color white10 = Colors.white10;
  static const Color white24 = Colors.white24;
  static const Color white30 = Colors.white30;
  static const Color white70 = Colors.white70;
  static const MaterialColor grey = Colors.grey;
  static const MaterialColor red = Colors.red;
  static const Color transparent = Colors.transparent;
  static const MaterialColor blue = Colors.blue;
  static const MaterialColor green = Colors.green;
  static const MaterialColor orange = Colors.orange;
  static const MaterialColor purple = Colors.purple;
  static const MaterialColor teal = Colors.teal;
  static const Color redAccent = Colors.redAccent;
  static const MaterialColor blueGrey = Colors.blueGrey;
}
