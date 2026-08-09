import 'package:flutter/material.dart';

class AppColors {
  // --- TÔNG MÀU CHỦ ĐẠO / THƯƠNG HIỆU ---
  static const Color primary = Color(0xFF2563EB); // Xanh dương chủ đạo
  static const Color darkBlue = Color(0xFF1E3A8A); // Xanh navy đậm
  static const Color deepBlue = Color(0xFF0F172A); // Xanh tối

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
  static const Color lightBg = Color(0xFFF3F4F6); // Nền sáng
  static const Color darkBg = Color(0xFF121212); // Nền tối
  static const Color cardLight = Colors.white; // Thẻ sáng
  static const Color cardDark = Color(0xFF1E1E1E); // Thẻ tối
  static const Color cardItemDark = Color(0xFF2D2D2D); // Thẻ con tối

  // --- NHÃN VÀ VIỀN PHỤ TRỢ (BADGES & BORDERS) ---
  static const Color badgeBlueBg = Color(0xFFEFF6FF); // Nền badge xanh lam
  static const Color badgeGreenBg = Color(0xFFECFDF5); // Nền badge xanh lá
  static const Color badgeRedBg = Color(0xFFFEE2E2); // Nền badge đỏ
}
