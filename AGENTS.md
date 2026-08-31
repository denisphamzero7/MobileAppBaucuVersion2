# 🏛️ QUY TẮC KIẾN TRÚC DỰ ÁN (PROJECT ARCHITECTURAL RULES)

Dự án tuân thủ nghiêm ngặt chuẩn **Clean Architecture**, **GetX State Management**, và **Domain-Driven Design (DDD)**.

---

## 📌 QUY TẮC BẮT BUỘC: QUẢN LÝ TRẠNG THÁI BẰNG ENUM (MANDATORY ENUM RULE)

> ⚠️ **QUY TẮC CỐT LÕI (RULE #1):**
> **Mỗi khi tạo một Module mới trong dự án, BẮT BUỘC phải tạo file Enum tương ứng trong thư mục `lib/core/enums/` để quản lý toàn bộ trạng thái, phân loại, nhãn tiếng Việt, icon và màu sắc.**
> **TUYỆT ĐỐI KHÔNG dùng Hardcoded Strings (chuỗi cứng như `'todo'`, `'published'`, `'done'`) rải rác trong các file UI.**

---

### 🗂️ 1. Cấu trúc thư mục Enums chuẩn (`lib/core/enums/`):
```text
lib/core/enums/
├── task_enums.dart          // Quản lý trạng thái & tiến độ Công việc
├── petition_enums.dart      // Quản lý trạng thái Đơn thư & Kiến nghị
├── task_document_enums.dart // Quản lý trạng thái Văn bản giao việc
├── log_activity_enums.dart  // Quản lý phương thức & tab Nhật ký hoạt động
└── [module_name]_enums.dart // BẮT BUỘC TẠO CHO BẤT KỲ MODULE MỚI NÀO
```

---

### 📝 2. Mẫu định nghĩa Enum chuẩn (Template):
Mỗi Enum đại diện cho trạng thái cần chứa đầy đủ các thuộc tính:
- `key`: Khóa API đồng bộ với Backend (`String`)
- `label`: Tên nhãn hiển thị tiếng Việt (`String`)
- `icon`: Biểu tượng hiển thị (`IconData`)
- `color`: Màu sắc đại diện (`Color`)
- `aliases`: Danh sách từ đồng nghĩa / giá trị API tương đương (`List<String>`)
- Hàm helper `fromKey(String? key, {fallback})` để parse an toàn từ API response với tra cứu $O(1)$.
- Hàm helper `fromFilterKey(String? key)` để parse cho bộ lọc (fallback về `all`).

```dart
import 'package:flutter/material.dart';
import '../../untils/app_colors.dart';

enum MyNewModuleStatus {
  all(
    key: 'all',
    label: 'Tất cả',
    icon: Icons.filter_list,
    color: AppColors.primary,
    aliases: ['tat_ca', 'tatca'],
  ),
  active(
    key: 'active',
    label: 'Đang hoạt động',
    icon: Icons.check_circle_outline,
    color: AppColors.done,
    aliases: ['1', 'running', 'dang_hoat_dong'],
  ),
  inactive(
    key: 'inactive',
    label: 'Ngừng hoạt động',
    icon: Icons.pause_circle_outline,
    color: AppColors.paused,
    aliases: ['0', 'stopped', 'ngung_hoat_dong'],
  );

  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> aliases;

  const MyNewModuleStatus({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    this.aliases = const [],
  });

  static final Map<String, MyNewModuleStatus> _lookupMap = () {
    final map = <String, MyNewModuleStatus>{};
    for (final s in MyNewModuleStatus.values) {
      map[s.key.toLowerCase()] = s;
      for (final alias in s.aliases) {
        map[alias.toLowerCase()] = s;
      }
    }
    return map;
  }();

  /// Parse cho Entity (mặc định fallback về trạng thái an toàn: active/todo)
  static MyNewModuleStatus fromKey(
    String? key, {
    MyNewModuleStatus fallback = MyNewModuleStatus.active,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toLowerCase().trim()] ?? fallback;
  }

  /// Parse cho Filter (mặc định fallback về 'all')
  static MyNewModuleStatus fromFilterKey(String? key) {
    return fromKey(key, fallback: MyNewModuleStatus.all);
  }

  static List<MyNewModuleStatus> get filterOptions => MyNewModuleStatus.values;
  static List<MyNewModuleStatus> get formOptions =>
      MyNewModuleStatus.values.where((e) => e != MyNewModuleStatus.all).toList();
}
```

---

### 🖥️ 3. Quy tắc viết Giao diện (UI) từ Enum:
* Các Grid thống kê số liệu, Dropdown chọn bộ lọc, hoặc Badge trạng thái **phải tự động lặp qua `Enum.values.map(...)`**, không copy-paste widget thủ công.
* Khi Backend bổ sung hoặc đổi trạng thái, chỉ cần chỉnh sửa 1 dòng trong file Enum, toàn bộ hệ thống sẽ tự động đồng bộ.
