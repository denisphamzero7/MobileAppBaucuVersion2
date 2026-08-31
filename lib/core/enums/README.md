# 🎯 Core Enums Registry

Thư mục này chứa toàn bộ các Bộ Enum quản lý trạng thái, danh mục, quyền hạn, định dạng tệp và phân loại cho toàn bộ các phân hệ trong ứng dụng.

## 📋 Danh sách Enum hiện có:

1. **`task_enums.dart`**:
   - `TaskProcessingStatus`: Trạng thái xử lý công việc (Chưa thực hiện, Đang thực hiện, Hoàn thành, Chờ duyệt, Tạm dừng, Đã hủy).
   - `TaskTimingStatus`: Tiến độ thời hạn công việc (Chưa đến hạn, Sớm hạn, Đúng hạn, Trễ hạn, Quá hạn, Đã hủy).
   - `TaskPriorityLevel`: Mức độ ưu tiên công việc (Khẩn cấp, Cao, Trung bình, Thấp).

2. **`petition_enums.dart`**:
   - `PetitionProcessingStatus`: Trạng thái xử lý đơn thư & kiến nghị (Mới tiếp nhận, Đang xử lý, Đã hoàn thành, Tạm dừng, Đã hủy).

3. **`task_document_enums.dart`**:
   - `TaskDocumentStatus`: Trạng thái văn bản giao việc (Bản nháp, Đã ban hành).

4. **`notification_enums.dart`**:
   - `NotificationType`: Phân loại thông báo (Bầu cử thành công, Cảnh báo bầu cử, Hệ thống, Cập nhật cử tri, Nhiệm vụ, Văn bản, Chung).
   - `NotificationReadFilter`: Bộ lọc trạng thái đọc (Tất cả, Chưa đọc, Đã đọc).

5. **`file_enums.dart`**:
   - `FileAttachmentType`: Tự động nhận diện định dạng tệp đính kèm (PDF, Excel, Word, PowerPoint, Hình ảnh, ZIP, Video, Âm thanh, Link, Khác) qua `FileAttachmentType.fromFileName(...)`.

6. **`voter_enums.dart`**:
   - `VoterStatus`: Trạng thái cử tri (Tất cả, Chưa bỏ phiếu, Đã bỏ phiếu, Vắng mặt).
   - `VoterScanResult`: Kết quả quét mã QR / CCCD cử tri (Hợp lệ, Đã bỏ phiếu trước đó, Không hợp lệ, Không tìm thấy, Lỗi).

7. **`user_enums.dart`**:
   - `UserRole`: Vai trò người dùng & phân quyền (SuperAdmin, Admin, Manager, Specialist, User, Voter).
   - `Gender`: Giới tính người dùng (Nam, Nữ, Khác).

8. **`common_enums.dart`**:
   - `TimeRangeFilter`: Bộ lọc khoảng thời gian (Hôm nay, Tuần này, Tháng này, Quý này, Năm nay, Tùy chọn).
   - `SortOrder`: Tiêu chí sắp xếp danh sách (Mới nhất, Cũ nhất, Sắp hết hạn trước, Ưu tiên cao nhất, Tên A-Z).
   - `AppThemeMode`: Chế độ giao diện (Sáng, Tối, Hệ thống).
   - `AppNavigationTab`: Các tab thanh điều hướng chính (Trang chủ, Công việc, Văn bản, Thống kê, Cá nhân).

9. **`log_activity_enums.dart`**:
   - `LogActivityMethod`: Phương thức HTTP nhật ký hoạt động (GET, POST, PUT, PATCH, DELETE).
   - `LogActivityTab`: Phân loại tab nhật ký (Tổng quan, Thông tin cá nhân, Cài đặt bảo mật).

---

## ⚠️ Quy tắc kiến trúc bắt buộc:
1. Mọi Enum đều phải có `fromKey(String? key, {fallback})` với tra cứu bảng băm $O(1)$.
2. Không dùng chuỗi hardcode rải rác trong UI.
3. Khi hiển thị Dropdown Form thêm/sửa, luôn dùng `formOptions` (tự động loại bỏ mục `"Tất cả"`).
