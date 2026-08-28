class AppValidator {
  AppValidator._();

  /// Kiểm tra chuỗi rỗng
  static String? requiredField(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  /// Kiểm tra Email hợp lệ
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  /// Kiểm tra Số điện thoại Việt Nam (10 số, bắt đầu bằng 0)
  static String? phone(String? value, {bool isRequired = false}) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'Vui lòng nhập số điện thoại' : null;
    }
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ (10 chữ số)';
    }
    return null;
  }

  /// Kiểm tra Căn cước công dân (12 số) hoặc CMND (9 số)
  static String? citizenId(String? value, {bool isRequired = false}) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'Vui lòng nhập số CCCD/CMND' : null;
    }
    final cleaned = value.trim();
    if (cleaned.length != 9 && cleaned.length != 12) {
      return 'CCCD (12 số) hoặc CMND (9 số) không hợp lệ';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'CCCD chỉ được chứa các chữ số';
    }
    return null;
  }
}
