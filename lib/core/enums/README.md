# 🎯 Core Enums Registry

Thư mục này chứa toàn bộ các Bộ Enum quản lý trạng thái, danh mục, quyền hạn và phân loại cho toàn bộ các phân hệ trong ứng dụng.

## 📋 Danh sách Enum hiện có:
1. `task_enums.dart`: `TaskProcessingStatus`, `TaskTimingStatus`, `TaskPriorityLevel`
2. `petition_enums.dart`: `PetitionProcessingStatus`
3. `task_document_enums.dart`: `TaskDocumentStatus`
4. `log_activity_enums.dart`: `LogActivityMethod`, `LogActivityTab`

## ⚠️ Quy tắc phát triển:
Mọi module mới khi được thêm vào hệ sinh thái ứng dụng **bắt buộc** phải khai báo file Enum tại thư mục này trước khi viết Controller và Widget.
