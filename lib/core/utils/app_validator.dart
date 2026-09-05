/// ============================================================================
/// 🛡️ [AppValidator] - TIỆN ÍCH KIỂM TRA HỢP LỆ FORM NHẬP LIỆU TOÀN ỨNG DỤNG
/// ============================================================================
class AppValidator {
  AppValidator._();

  /// Kiểm tra trường bắt buộc nhập
  static String? requiredField(
    String? value, {
    String fieldName = 'Trường này',
    String? customMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? '$fieldName không được để trống';
    }
    return null;
  }

  /// Kiểm tra Email hợp lệ
  static String? email(
    String? value, {
    String? customMessage,
    String? emptyMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return customMessage ?? 'Email không đúng định dạng';
    }
    return null;
  }

  /// Kiểm tra Số điện thoại Việt Nam (10 số, bắt đầu bằng 03/05/07/08/09)
  static String? phone(
    String? value, {
    bool isRequired = false,
    String? customMessage,
    String? emptyMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? (emptyMessage ?? 'Vui lòng nhập số điện thoại') : null;
    }
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return customMessage ?? 'Số điện thoại không hợp lệ (10 chữ số)';
    }
    return null;
  }

  /// Kiểm tra độ dài tối thiểu (ví dụ Mật khẩu)
  static String? minLength(
    String? value,
    int minLength, {
    String fieldName = 'Mật khẩu',
    String? customMessage,
    String? emptyMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Vui lòng nhập $fieldName';
    }
    if (value.length < minLength) {
      return customMessage ?? '$fieldName phải có ít nhất $minLength ký tự';
    }
    return null;
  }

  /// Kiểm tra 2 trường có khớp nhau không (ví dụ Nhập lại mật khẩu)
  static String? match(
    String? value,
    String? matchValue, {
    String errorMessage = 'Mật khẩu xác nhận không khớp',
    String? emptyMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Vui lòng xác nhận mật khẩu';
    }
    if (value != matchValue) {
      return errorMessage;
    }
    return null;
  }

  /// Kiểm tra Căn cước công dân (12 số) hoặc CMND (9 số) cho Bầu cử
  static String? citizenId(
    String? value, {
    bool isRequired = false,
    String? customMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'Vui lòng nhập số CCCD/CMND' : null;
    }
    final cleaned = value.trim();
    if (cleaned.length != 9 && cleaned.length != 12) {
      return customMessage ?? 'CCCD (12 số) hoặc CMND (9 số) không hợp lệ';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return customMessage ?? 'CCCD chỉ được chứa các chữ số';
    }
    return null;
  }
}
