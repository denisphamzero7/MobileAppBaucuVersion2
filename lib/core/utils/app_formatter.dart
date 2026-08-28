import 'package:intl/intl.dart';

class AppFormatter {
  AppFormatter._();

  /// Định dạng số nguyên với dấu phân cách hàng nghìn (ví dụ: 1,234,567)
  static String number(num? value) {
    if (value == null) return '0';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(value);
  }

  /// Định dạng tiền tệ VNĐ (ví dụ: 1.500.000 ₫)
  static String currency(num? amount) {
    if (amount == null) return '0 ₫';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  /// Định dạng phần trăm (ví dụ: 85.5% hoặc 100%)
  static String percent(num? value, {int decimalDigits = 0}) {
    if (value == null) return '0%';
    if (decimalDigits == 0 || value % 1 == 0) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(decimalDigits)}%';
  }

  /// Rút gọn số đếm lớn (ví dụ: 1.2K, 3.5M)
  static String compactNumber(num? value) {
    if (value == null) return '0';
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}
