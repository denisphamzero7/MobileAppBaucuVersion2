/// ============================================================================
/// 📌 [AppStrings] - QUẢN LÝ TẬP TRUNG TOÀN BỘ CHUỖI VĂN BẢN (STRINGS) HỆ THỐNG
/// ============================================================================
/// Tất cả nhãn hiển thị, tiêu đề màn hình, thông báo, nút bấm... được quản lý tại đây.
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
  static const String resetFilter = 'Đặt lại';
  static const String applyFilter = 'Áp dụng';
  static const String all = 'Tất cả';
  static const String share = 'Chia sẻ';
  static const String openFile = 'Mở tệp';
  static const String download = 'Tải về';
  static const String exportExcel = 'Xuất Excel';
  static const String importExcel = 'Nhập Excel';
  static const String emptyData = 'Không có dữ liệu';
  static const String noAttachment = 'Chưa có tệp đính kèm';
  static const String attachmentTitle = 'TỆP ĐÍNH KÈM';

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
  // 3. QUẢN LÝ CÔNG VIỆC (TASK MANAGEMENT)
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
  static const String confirmDeleteTask = 'Bạn có chắc chắn muốn xóa công việc này?';
  static const String confirmDeleteSelectedTasks = 'Bạn có chắc chắn muốn xóa các công việc đã chọn?';

  // Tiêu đề các khối trong trang Task
  static const String processingStatusSection = 'TRẠNG THÁI XỬ LÝ';
  static const String timingStatusSection = 'TIẾN ĐỘ CÔNG VIỆC';

  // Trạng thái xử lý (Processing Status)
  static const String statusAll = 'Tổng';
  static const String statusTodo = 'Chưa thực hiện';
  static const String statusInProgress = 'Đang thực hiện';
  static const String statusPendingApproval = 'Chờ duyệt';
  static const String statusDone = 'Hoàn thành';
  static const String statusPaused = 'Tạm dừng';
  static const String statusCancelled = 'Đã hủy';

  // Tiến độ công việc (Timing Status)
  static const String timingUpcoming = 'Chưa đến hạn';
  static const String timingEarly = 'Sớm hạn';
  static const String timingOnTime = 'Đúng hạn';
  static const String timingLate = 'Trễ hạn';
  static const String timingOverdue = 'Quá hạn';
  static const String timingCancelled = 'Đã hủy';

  // Chữ in hoa dùng cho Badge tiến độ
  static const String timingUpcomingUpper = 'CHƯA ĐẾN HẠN';
  static const String timingEarlyUpper = 'SỚM HẠN';
  static const String timingOnTimeUpper = 'ĐÚNG HẠN';
  static const String timingLateUpper = 'TRỄ HẠN';
  static const String timingOverdueUpper = 'QUÁ HẠN';

  // Tabs chi tiết công việc
  static const String taskTabInfo = 'Thông tin';
  static const String taskTabReport = 'Báo cáo';
  static const String taskTabDiscussion = 'Trao đổi';
  static const String taskTabDocument = 'Văn bản';

  // Quick Action Menu & Nút bấm
  static const String createTaskAction = 'Tạo việc mới';
  static const String createTaskSubtitle = 'Thêm & phân công';
  static const String importExcelAction = 'Nhập Excel';
  static const String importExcelSubtitle = 'Tải danh sách việc';
  static const String exportExcelAction = 'Xuất Excel';
  static const String exportExcelSubtitle = 'Tải danh sách ra máy';
  static const String deleteSelectedAction = 'Xóa đã chọn';
  static const String deleteSelectedSubtitle = 'Xóa nhiều việc cùng lúc';
  static const String selectAllAction = 'Chọn tất cả';
  static const String deselectAllAction = 'Bỏ chọn';
  static const String cancelSelectMode = 'Hủy';

  // ===========================================================================
  // 4. QUẢN LÝ ĐƠN THƯ & KIẾN NGHỊ (PETITIONS & DOCUMENTS)
  // ===========================================================================
  static const String petitionScreenTitle = 'Quản lý đơn thư';
  static const String petitionList = 'Danh sách đơn thư';
  static const String petitionDetails = 'Chi tiết đơn thư';
  static const String searchPetitionHint = 'Tìm kiếm đơn thư, người gửi...';
  static const String noPetitionsFound = 'Không có đơn thư nào';
  static const String petitionTabInfo = 'Thông tin đơn';
  static const String petitionTabResult = 'Kết quả xử lý';
  static const String petitionSender = 'Người gửi / Nguồn đơn';
  static const String petitionPhone = 'Số điện thoại';
  static const String petitionAddress = 'Địa chỉ';
  static const String petitionReceivedDate = 'Ngày tiếp nhận';
  static const String petitionContent = 'Nội dung đơn thư';
  static const String petitionProcessingResult = 'Kết quả giải quyết';

  // ===========================================================================
  // 5. QUẢN LÝ VĂN BẢN GIAO VIỆC (TASK ASSIGNMENT DOCUMENTS)
  // ===========================================================================
  static const String taskDocumentScreenTitle = 'Văn bản giao việc';
  static const String searchTaskDocumentHint = 'Tìm kiếm văn bản theo số hiệu, trích yếu...';
  static const String noTaskDocumentsFound = 'Không tìm thấy văn bản giao việc nào';
  static const String taskDocumentFilterTitle = 'Bộ lọc văn bản';
  static const String taskDocumentStatusTitle = 'Trạng thái văn bản';
  static const String taskDocumentDepartmentTitle = 'Phòng ban';
  static const String allDepartments = 'Tất cả phòng ban';
  static const String documentCode = 'Số / Mã hiệu văn bản';
  static const String documentDate = 'Ngày ban hành';
  static const String documentAssignedTasks = 'Công việc thuộc văn bản';
  static const String documentStatusPublished = 'Đã ban hành';
  static const String documentStatusDraft = 'Bản nháp';

  // ===========================================================================
  // 6. BÁO CÁO THỐNG KÊ (STATISTICS & REPORTS)
  // ===========================================================================
  static const String statisticScreenTitle = 'Thống kê công việc';
  static const String statisticOverview = 'Tổng quan số liệu';
  static const String statisticDistribution = 'Phân bố công việc';
  static const String statisticByStatus = 'Theo trạng thái';
  static const String statisticByTiming = 'Theo tiến độ';
  static const String statisticByDepartment = 'Theo phòng ban';
  static const String statisticCompletionRate = 'Tỷ lệ hoàn thành';
  static const String statisticPeriodFilter = 'Thời gian thống kê';
  static const String filterThisWeek = 'Tuần này';
  static const String filterThisMonth = 'Tháng này';
  static const String filterThisQuarter = 'Quý này';
  static const String filterThisYear = 'Năm nay';

  // ===========================================================================
  // 7. THANH PHÂN TRANG (PAGINATION)
  // ===========================================================================
  static const String prevPage = 'Trước';
  static const String nextPage = 'Sau';
  static const String page = 'Trang';
  static const String total = 'Tổng số';
  static const String records = 'bản ghi';
  static const String selectPage = 'Chọn trang chuyển đến';
}
