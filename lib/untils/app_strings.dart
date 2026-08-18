/// [AppStrings] - Quản lý tập trung toàn bộ chuỗi văn bản (Strings) trong ứng dụng
/// Khi cần thay đổi câu chữ, nhãn nút bấm, tiêu đề... chỉ cần sửa tại file này.
class AppStrings {
  // Private constructor để tránh khởi tạo instance
  AppStrings._();

  // ===========================================================================
  // 1. THÔNG TIN CHUNG & BẢN QUYỀN (COMMON & BRANDING)
  // ===========================================================================
  static const String appName = 'Bầu Cử & Quản Lý Công Việc';
  static const String copyrightYear = '2026';
  static const String designedBy = 'Thiết kế bởi';
  static const String developerName = 'Danatec';
  static const String defaultOrgName = 'UBND PHƯỜNG HÒA CƯỜNG';
  static const String notificationTitle = 'Thông báo';

  // Nút hành động chung
  static const String cancel = 'Hủy';
  static const String confirm = 'Xác nhận';
  static const String save = 'Lưu';
  static const String close = 'Đóng';
  static const String back = 'Quay lại';
  static const String change = 'Đổi';
  static const String create = 'Tạo mới';
  static const String update = 'Cập nhật';
  static const String delete = 'Xóa';
  static const String detail = 'Chi tiết';
  static const String refresh = 'Làm mới';
  static const String search = 'Tìm kiếm';
  static const String filter = 'Bộ lọc';
  static const String all = 'Tất cả';

  // ===========================================================================
  // 2. MÀN HÌNH TRANG CÁ NHÂN / NGƯỜI DÙNG (PROFILE & USER SCREEN)
  // ===========================================================================
  static const String userOverviewTitle = 'Tổng quan người dùng';
  
  // Tên các Tab
  static const String tabOverview = 'Tổng Quan';
  static const String tabPersonalInfo = 'Thông Tin Cá Nhân';
  static const String tabSecurity = 'Cài Đặt Bảo Mật';

  // Thẻ thông tin đầu trang
  static const String currentOrganization = 'Tổ chức hiện tại:';
  static const String changeOrganization = 'Chuyển tổ chức làm việc';
  static const String lastLogin = 'Đăng nhập lần cuối:';
  static const String defaultRole = 'Trưởng phòng';

  // Tab 0: Tổng quan (Overview Tab)
  static const String activityTrend = 'XU HƯỚNG HOẠT ĐỘNG';
  static const String recentNotifications = 'THÔNG BÁO GẦN ĐÂY';
  static const String recentActivities = 'HOẠT ĐỘNG GẦN ĐÂY';
  static const String markAllAsRead = 'Đã đọc tất cả';
  static const String noNotifications = 'Không có thông báo nào';
  static const String noActivities = 'Không có hoạt động nào';
  static const String markAllReadSuccess = 'Đã đánh dấu đọc tất cả thông báo';

  // Tab 1: Thông tin cá nhân
  static const String personalInfoSection = 'THÔNG TIN CÁ NHÂN';
  static const String email = 'Email';
  static const String userId = 'ID Người dùng';
  static const String role = 'Chức vụ / Vai trò';

  // Tab 2: Cài đặt bảo mật
  static const String securitySection = 'CÀI ĐẶT BẢO MẬT';
  static const String changePassword = 'Đổi mật khẩu';
  static const String newPassword = 'Mật khẩu mới';
  static const String confirmPassword = 'Xác nhận mật khẩu';
  static const String themeMode = 'Chế độ giao diện';
  static const String themeDark = 'Giao diện tối';
  static const String themeLight = 'Giao diện sáng';
  static const String logout = 'Đăng xuất';
  static const String loggingOut = 'Đang thực hiện đăng xuất...';

  // ===========================================================================
  // 3. QUẢN LÝ CÔNG VIỆC (TASK ASSIGNMENT)
  // ===========================================================================
  static const String taskSent = 'Công việc đang giao';
  static const String taskReceived = 'Công việc được giao';
  static const String searchTaskHint = 'Tìm kiếm công việc theo tên, mã...';
  static const String taskDetails = 'Chi tiết công việc';
  static const String taskProgress = 'Tiến độ thực hiện';
  static const String taskStatus = 'Trạng thái';
  static const String taskPriority = 'Mức độ ưu tiên';
  static const String taskDeadline = 'Hạn xử lý';
  static const String taskDescription = 'Mô tả chi tiết';
  static const String updateTask = 'Cập nhật công việc';
  static const String deleteTask = 'Xóa công việc';
  static const String noTasksFound = 'Không tìm thấy công việc nào';

  // ===========================================================================
  // 4. QUẢN LÝ ĐƠN THƯ & KIẾN NGHỊ (PETITIONS & DOCUMENTS)
  // ===========================================================================
  static const String petitionList = 'Danh sách đơn thư';
  static const String petitionDetails = 'Chi tiết đơn thư';
  static const String searchPetitionHint = 'Tìm kiếm đơn thư, người gửi...';
  static const String noPetitionsFound = 'Không có đơn thư nào';

  // ===========================================================================
  // 5. THANH PHÂN TRANG (PAGINATION)
  // ===========================================================================
  static const String prevPage = 'Trước';
  static const String nextPage = 'Sau';
  static const String page = 'Trang';
  static const String total = 'Tổng số';
  static const String records = 'bản ghi';
  static const String selectPage = 'Chọn trang chuyển đến';
}
