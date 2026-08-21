import 'package:intl/intl.dart';

/// Helper chuyên xử lý và định dạng ngày tháng cho toàn bộ ứng dụng
class DateHelper {
  DateHelper._();

  /// Format chuỗi ngày (ISO hoặc YYYY-MM-DD hoặc có kèm giờ) sang định dạng dd/MM/yyyy
  /// Ví dụ: "2026-08-21 14:30:00" -> "21/08/2026"
  static String formatDate(String? raw, {String fallback = ''}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final trimmed = raw.trim();
    try {
      if (trimmed.contains(' ')) {
        final parts = trimmed.split(' ');
        if (parts.isNotEmpty && parts[0].contains('-')) {
          final dateParts = parts[0].split('-');
          if (dateParts.length == 3) {
            if (dateParts[0].length == 4) {
              return '${dateParts[2].padLeft(2, '0')}/${dateParts[1].padLeft(2, '0')}/${dateParts[0]}';
            } else {
              return '${dateParts[0].padLeft(2, '0')}/${dateParts[1].padLeft(2, '0')}/${dateParts[2]}';
            }
          }
          return parts[0];
        }
      } else if (trimmed.contains('-')) {
        final dateParts = trimmed.split('-');
        if (dateParts.length == 3) {
          if (dateParts[0].length == 4) {
            return '${dateParts[2].padLeft(2, '0')}/${dateParts[1].padLeft(2, '0')}/${dateParts[0]}';
          } else {
            return '${dateParts[0].padLeft(2, '0')}/${dateParts[1].padLeft(2, '0')}/${dateParts[2]}';
          }
        }
      }
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return DateFormat('dd/MM/yyyy').format(parsed);
      }
    } catch (_) {}
    return trimmed;
  }

  /// Format DateTime hoặc String sang dd/MM/yyyy HH:mm
  static String formatDateTime(dynamic date, {String fallback = 'Chưa chọn'}) {
    if (date == null) return fallback;
    try {
      if (date is DateTime) {
        return DateFormat('dd/MM/yyyy HH:mm').format(date);
      }
      if (date is String) {
        if (date.trim().isEmpty) return fallback;
        final parsed = DateTime.tryParse(date.trim());
        if (parsed != null) {
          return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
        }
        final d = parseDateTime(date);
        if (d != null) {
          return DateFormat('dd/MM/yyyy HH:mm').format(d);
        }
      }
    } catch (_) {}
    return date.toString();
  }

  /// Format DateTime hoặc String sang dd/MM/yyyy HH:mm:ss
  static String formatDateTimeFull(dynamic date, {String fallback = ''}) {
    if (date == null) return fallback;
    try {
      if (date is DateTime) {
        return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
      }
      if (date is String) {
        if (date.trim().isEmpty) return fallback;
        final parsed = DateTime.tryParse(date.trim());
        if (parsed != null) {
          return DateFormat('dd/MM/yyyy HH:mm:ss').format(parsed);
        }
      }
    } catch (_) {}
    return date.toString();
  }

  /// Format chuỗi ngày ngắn chỉ lấy ngày/tháng (dd/MM)
  static String formatDayMonth(String? raw, {String fallback = 'N/A'}) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final trimmed = raw.trim();
    try {
      final spaceParts = trimmed.split(' ');
      String datePart = spaceParts.isNotEmpty ? spaceParts[0] : trimmed;
      if (spaceParts.length >= 2 && !spaceParts[0].contains('-') && !spaceParts[0].contains('/')) {
        datePart = spaceParts[1];
      }

      if (datePart.contains('/')) {
        final dateParts = datePart.split('/');
        if (dateParts.length >= 2) {
          return '${dateParts[0].padLeft(2, '0')}/${dateParts[1].padLeft(2, '0')}';
        }
      } else if (datePart.contains('-')) {
        final dateParts = datePart.split('-');
        if (dateParts.length >= 3) {
          if (dateParts[0].length == 4) {
            return '${dateParts[2].padLeft(2, '0')}/${dateParts[1].padLeft(2, '0')}';
          } else {
            return '${dateParts[0].padLeft(2, '0')}/${dateParts[1].padLeft(2, '0')}';
          }
        }
      }
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return DateFormat('dd/MM').format(parsed);
      }
    } catch (_) {}
    return trimmed;
  }

  /// Format ngày gửi lên API (mặc định: yyyy-MM-dd HH:mm:ss hoặc yyyy-MM-dd)
  static String formatForApi(DateTime? date, {bool includeTime = true}) {
    if (date == null) return '';
    final pattern = includeTime ? 'yyyy-MM-dd HH:mm:ss' : 'yyyy-MM-dd';
    return DateFormat(pattern).format(date);
  }

  /// Format timestamp cho tên file Excel (yyyyMMdd_HHmmss)
  static String getExcelTimestamp({DateTime? time}) {
    return DateFormat('yyyyMMdd_HHmmss').format(time ?? DateTime.now());
  }

  /// Parse chuỗi bất kỳ sang DateTime an toàn
  static DateTime? parseDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    try {
      final iso = DateTime.tryParse(trimmed);
      if (iso != null) return iso;

      if (trimmed.contains('-') && trimmed.contains(':')) {
        return DateFormat('yyyy-MM-dd HH:mm:ss').parse(trimmed);
      }
      if (trimmed.contains('/') && trimmed.contains(':')) {
        return DateFormat('dd/MM/yyyy HH:mm:ss').parse(trimmed);
      }
      if (trimmed.contains('/')) {
        return DateFormat('dd/MM/yyyy').parse(trimmed);
      }
      if (trimmed.contains('-')) {
        return DateFormat('yyyy-MM-dd').parse(trimmed);
      }
    } catch (_) {}
    return null;
  }
}
