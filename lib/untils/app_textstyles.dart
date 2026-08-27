import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  AppTextStyle._();

  // Headings
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  // Body text
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // Card / Item List Styles (Đồng bộ thẻ Công việc, Văn bản, Đơn thư)
  static TextStyle cardTitle = GoogleFonts.poppins(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static TextStyle cardSubtitle = GoogleFonts.poppins(
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
  );

  // Chips & Meta Tags (Ngày tháng, người nhận, tên phòng ban, loại)
  static TextStyle chipText = GoogleFonts.poppins(
    fontSize: 9.5,
    fontWeight: FontWeight.w500,
  );

  // Badges (Trạng thái: Hoàn thành, Đang xử lý, Quá hạn)
  static TextStyle badgeText = GoogleFonts.poppins(
    fontSize: 9.0,
    fontWeight: FontWeight.w600,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
  );

  // Button text
  static TextStyle buttonLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static TextStyle buttonMedium = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static TextStyle buttonSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // Label text
  static TextStyle labelMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelSmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Helper functions for variations
  static TextStyle withColor(TextStyle style, Color color) => style.copyWith(color: color);
  static TextStyle withWeight(TextStyle style, FontWeight weight) => style.copyWith(fontWeight: weight);
  static TextStyle withSize(TextStyle style, double size) => style.copyWith(fontSize: size);
}