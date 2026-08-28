# 🏛️ TÀI LIỆU KIẾN TRÚC & HƯỚNG DẪN PHÁT TRIỂN HỆ THỐNG
> **Dự án:** App Bầu Cử & Quản Lý Công Việc, Đơn Thư (Mobile Application)  
> **Kiến trúc:** Layered Architecture + MVC + GetX State Management

---

## 📑 MỤC LỤC
1. [Tổng quan kiến trúc](#1-tổng-quan-kiến-trúc)
2. [Cấu trúc thư mục & Trách nhiệm các tầng](#2-cấu-trúc-thư-mục--trách-nhiệm-các-tầng)
3. [Quy trình 4 bước chuẩn để tạo mới một tính năng](#3-quy-trình-4-bước-chuẩn-để-tạo-mới-một-tính-năng)
4. [Các thành phần dùng chung quan trọng (Core & Shared Widgets)](#4-các-thành-phần-dùng-chung-quan-trọng)
5. [Cơ chế phân quyền người dùng (CASL Abilities)](#5-cơ-chế-phân-quyền-người-dùng-casl-abilities)
6. [Quy tắc vàng & Lưu ý quan trọng khi lập trình UI/Logic](#6-quy-tắc-vàng--lưu-ý-quan-trọng-khi-lập-trình)

---

## 1. TỔNG QUAN KIẾN TRÚC

Dự án áp dụng mô hình phân lớp rõ ràng (**Layered Architecture**), phân tách triệt để giữa:
- **Tầng Giao diện (View)**
- **Tầng Xử lý logic & Quản lý trạng thái (Controller / GetX)**
- **Tầng Giao tiếp API & Cơ sở dữ liệu (Service / Database)**
- **Tầng Dữ liệu định kiểu (Data Model)**

```
┌────────────────────────────────────────────────────────┐
│                      VIEW (UI)                         │
│  - Màn hình chính (Screen), Modal, Bottom Sheet, Cards │
│  - Lắng nghe biến phản ứng bằng Obx(() => ...)         │
└───────────────────────────▲────────────────────────────┘
                            │ (Gọi hàm / Lắng nghe State)
┌───────────────────────────▼────────────────────────────┐
│                  CONTROLLER (GetX)                     │
│  - Quản lý logic nghiệp vụ, các biến .obs              │
│  - Phân quyền (canCreate, canUpdate, canDelete)        │
│  - Gọi Service để tải và cập nhật dữ liệu              │
└───────────────────────────▲────────────────────────────┘
                            │ (Gọi API / Local DB)
┌───────────────────────────▼────────────────────────────┐
│                       SERVICE                          │
│  - Thực hiện HTTP requests (GET, POST, PUT, DELETE)    │
│  - Truy vấn SQLite (DatabaseHelper)                    │
│  - Xử lý mã lỗi HTTP, parse JSON sang Model            │
└───────────────────────────▲────────────────────────────┘
                            │ (Chuyển đổi dữ liệu)
┌───────────────────────────▼────────────────────────────┐
│                        MODEL                           │
│  - Định nghĩa thực thể: TaskModel, PetitionModel...    │
│  - Hàm fromJson() và toJson() an toàn null-safety      │
└────────────────────────────────────────────────────────┘
```

---

## 2. CẤU TRÚC THƯ MỤC & TRÁCH NHIỆM CÁC TẦNG

```
lib/
├── core/                        # Chứa hằng số API, enum và widget dùng chung toàn app
│   ├── api_constants.dart       # Base URL và tất cả endpoint API
│   ├── enums/                   # BẮT BUỘC: Quản lý trạng thái bằng Enum tập trung
│   │   ├── task_enums.dart
│   │   ├── petition_enums.dart
│   │   ├── task_document_enums.dart
│   │   └── log_activity_enums.dart
│   └── widgets/
│       ├── app_pagination_widget.dart   # Thanh phân trang chuẩn chung
│       ├── app_paged_list_wrapper.dart  # Bọc danh sách chuyển trang êm
│       ├── maintenance_screen.dart      # Màn hình bảo trì hệ thống
│       ├── import_excel_button.dart     # Nút nhập Excel
│       └── export_excel_button.dart     # Nút xuất Excel
├── model/                       # Định nghĩa dữ liệu (Data Models)
│   ├── task_model.dart
│   ├── task_assignment_document_model.dart
│   ├── user_model.dart
│   └── ...
├── service/                     # Giao tiếp HTTP / Database
│   ├── auth_service.dart
│   ├── task_service.dart
│   ├── petition_service.dart
│   ├── database_helper.dart
│   └── ...
├── controllers/                 # Quản lý State & Logic bằng GetX
│   ├── auth_controller.dart     # Đăng nhập, Token, Phân quyền CASL
│   ├── task_controller.dart     # Logic Công việc đang giao / được giao
│   ├── navigation.dart          # Điều hướng Bottom Navigation Bar
│   └── ...
├── untils/                      # Tiện ích giao diện, màu sắc
│   └── app_colors.dart          # Bảng màu thiết kế chuẩn
├── view/                        # Giao diện người dùng (UI Screens & Widgets)
│   ├── auth/                    # Đăng nhập, quên mật khẩu
│   ├── task/                    # Quản lý công việc
│   ├── document/                # Quản lý đơn thư, kiến nghị
│   ├── voter/                   # Quản lý cử tri
│   ├── user/                    # Quản lý tài khoản
│   ├── statistic/               # Báo cáo thống kê
│   └── widgets/                 # Các widget dùng chung trong view
└── main.dart                    # Điểm khởi chạy ứng dụng
```

---

## 3. QUY TRÌNH 4 BƯỚC CHUẨN ĐỂ TẠO MỚI MỘT TÍNH NĂNG

Mỗi khi muốn tạo một tính năng mới (Ví dụ: **Quản lý Cuộc họp - Meetings**), hãy thực hiện tuần tự theo 4 bước sau:

### 🔹 BƯỚC 1: Tạo Model (`lib/model/meeting_model.dart`)
```dart
class MeetingModel {
  final int id;
  final String title;
  final String status;
  final String? startAt;
  final String? endAt;

  MeetingModel({
    required this.id,
    required this.title,
    required this.status,
    this.startAt,
    this.endAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? 'pending',
      startAt: json['start_at'] ?? json['startAt'],
      endAt: json['end_at'] ?? json['endAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'status': status,
    'start_at': startAt,
    'end_at': endAt,
  };
}
```

---

### 🔹 BƯỚC 2: Tạo Service (`lib/service/meeting_service.dart`)
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_constants.dart';
import '../model/meeting_model.dart';

class MeetingService {
  Future<List<MeetingModel>> fetchMeetings({required String token}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/meetings');
      final res = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final list = (decoded['data'] ?? decoded) as List;
        return list.map((e) => MeetingModel.fromJson(e)).toList();
      }
    } catch (e) {
      // Log lỗi nếu cần
    }
    return [];
  }
}
```

---

### 🔹 BƯỚC 3: Tạo Controller (`lib/controllers/meeting_controller.dart`)
```dart
import 'package:get/get.dart';
import '../model/meeting_model.dart';
import '../service/meeting_service.dart';
import 'auth_controller.dart';

class MeetingController extends GetxController {
  final MeetingService _service = MeetingService();
  
  final RxList<MeetingModel> meetingsList = <MeetingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMeetings();
  }

  Future<void> loadMeetings() async {
    isLoading.value = true;
    try {
      final token = Get.find<AuthController>().token.value;
      final result = await _service.fetchMeetings(token: token);
      meetingsList.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }
}
```

---

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/meeting_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/widgets/app_pagination_widget.dart';
import '../../view/widgets/skeleton_loader.dart';
import '../../untils/app_colors.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MeetingController());
    final authCtrl = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Kiểm tra quyền
    final canCreate = authCtrl.can('create', 'Meetings');
    final canUpdate = authCtrl.can('update', 'Meetings');
    final canDelete = authCtrl.can('destroy', 'Meetings');

    final RxInt currentPage = 1.obs;
    const int itemsPerPage = 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý cuộc họp'),
        actions: [
          if (canCreate)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                // Mở màn hình tạo mới
              },
            ),
        ],
      ),
      body: Obx(() {
        // Lọc danh sách theo từ khóa
        final filteredList = controller.meetingsList.where((m) {
          return m.title.toLowerCase().contains(controller.searchText.value.toLowerCase());
        }).toList();

        // Tính toán phân trang
        final totalItems = filteredList.length;
        final totalPages = (totalItems / itemsPerPage).ceil().clamp(1, 9999);
        if (currentPage.value > totalPages) currentPage.value = totalPages;
        
        final startIndex = (currentPage.value - 1) * itemsPerPage;
        final pagedList = filteredList.skip(startIndex).take(itemsPerPage).toList();

        return RefreshIndicator(
          onRefresh: controller.loadMeetings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Loading Skeleton khi đang tải dữ liệu
                if (controller.isLoading.value && controller.meetingsList.isEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.0),
                      child: SkeletonLoader(
                        child: SkeletonBox(
                          width: double.infinity,
                          height: 90,
                          radius: 12,
                        ),
                      ),
                    ),
                  )
                // 2. Trạng thái rỗng
                else if (pagedList.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text('Không có cuộc họp nào'),
                    ),
                  )
                // 3. Danh sách item thực tế
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pagedList.length,
                    itemBuilder: (ctx, idx) {
                      final item = pagedList[idx];
                      return Card(
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text('Trạng thái: ${item.status}'),
                        ),
                      );
                    },
                  ),

                // 4. Thanh phân trang dùng chung
                if (totalItems > 0) ...[
                  const SizedBox(height: 12),
                  AppPaginationWidget(
                    currentPage: currentPage.value,
                    totalPages: totalPages,
                    totalItems: totalItems,
                    itemsPerPage: itemsPerPage,
                    isLoading: controller.isLoading.value,
                    onPageChanged: (newPage) => currentPage.value = newPage,
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
```

---

## 4. CÁC THÀNH PHẦN DÙNG CHUNG QUAN TRỌNG

### 💀 `SkeletonLoader` & `SkeletonBox` (`lib/view/widgets/skeleton_loader.dart`)
**QUY ĐỊNH BẮT BUỘC:** Toàn bộ trạng thái chờ tải dữ liệu (Loading State) của các danh sách, bảng thống kê hoặc thẻ card phải sử dụng Skeleton Shimmer Loader (tự động đổi màu Dark/Light theme).
```dart
// Mẫu sử dụng Skeleton Loader:
if (isLoading.value && itemsList.isEmpty)
  ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 4,
    itemBuilder: (_, __) => const Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: SkeletonLoader(
        child: SkeletonBox(
          width: double.infinity,
          height: 100, // Chiều cao tương đương card thật
          radius: 14,
        ),
      ),
    ),
  )
```

### 🏷️ `AppPaginationWidget` (`lib/core/widgets/app_pagination_widget.dart`)
Thanh phân trang chuẩn, đẹp mắt, tự động co giãn theo kích thước màn hình:
* **Các thuộc tính chính:**
  * `currentPage` (int): Trang hiện tại (1, 2, ...).
  * `totalPages` (int): Tổng số trang.
  * `totalItems` (int): Tổng số bản ghi.
  * `itemsPerPage` (int): Số bản ghi trên mỗi trang (mặc định: 10).
  * `onPageChanged` (ValueChanged<int>): Callback khi bấm nút hoặc chọn số trang.
  * `isLoading` (bool): Hiển thị vòng xoay tải dữ liệu nhỏ ở giữa.

### 📝 `AppStrings` (`lib/untils/app_strings.dart`)
Quản lý tập trung **toàn bộ câu chữ, nhãn nút bấm, tiêu đề** trong toàn bộ ứng dụng:
* Tránh hardcode chuỗi trực tiếp trong View.
* Khi cần thay đổi nội dung (ví dụ: tên đơn vị thiết kế, tên tab, câu thông báo...), chỉ cần sửa tại `lib/untils/app_strings.dart`.

### 📏 `AppDivider` (`lib/core/widgets/app_divider.dart`)
Widget đường kẻ phân cách tái sử dụng:
* `AppDivider.white(opacity: 0.2)`: Đường kẻ mờ bán trong suốt cho Card nền Gradient / Nền tối.
* `AppDivider.light()`: Đường kẻ mảnh cho Card nền sáng.
* `AppDivider.dashed()`: Đường kẻ nét đứt.

---

## 5. CƠ CHẾ PHÂN QUYỀN NGƯỜI DÙNG (CASL ABILITIES)

Hệ thống phân quyền được quản lý tập trung trong [`AuthController`](file:///c:/LTMB_Tools/class1/project01/app_baucu_version1/lib/controllers/auth_controller.dart):

```dart
final authCtrl = Get.find<AuthController>();

// 1. Quyền Tạo
final canCreate = authCtrl.can('create', 'SubjectName');

// 2. Quyền Xem / Xuất
final canRead = authCtrl.can('read', 'SubjectName');

// 3. Quyền Chỉnh sửa / Cập nhật
final canUpdate = authCtrl.can('update', 'SubjectName');

// 4. Quyền Xóa
final canDelete = authCtrl.can('destroy', 'SubjectName');
```

*Các Subjects phổ biến trong hệ thống:*
- `'TaskAssignmentItems'`: Công việc
- `'TaskAssignmentPetitions'`: Đơn thư / Kiến nghị
- `'TaskAssignmentDocuments'`: Văn bản hồ sơ
- `'Voters'`: Quản lý Cử tri
- `'Users'`: Quản lý Người dùng

---

## 6. QUY TẮC VÀNG & LƯU Ý QUAN TRỌNG KHI LẬP TRÌNH

1. **BẮT BUỘC LUÔN DÙNG SKELETON LOADER (KHÔNG DÙNG CIRCULAR SPINNER CHO MÀN HÌNH DANH SÁCH):**
   * Luôn dùng `SkeletonLoader(child: SkeletonBox(...))` để mô phỏng hình dáng của các Card khi đang fetch API lần đầu hoặc khi đổi bộ lọc. Trải nghiệm người dùng sẽ mượt mà, chuyên nghiệp và không bị chớp giật màn hình.

2. **Tránh lỗi tràn màn hình (RenderFlex Overflow) trên BottomSheet / Modal:**
   * Luôn đặt `constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85)` cho Container bao ngoài.
   * Phần thân nội dung luôn được bọc trong `Flexible(child: SingleChildScrollView(child: ...))` để phần mô tả dài có thể cuộn lướt mà không che mất nút hành động cố định ở đáy.

3. **Khoảng cách đệm dưới đáy màn hình (Bottom Spacing):**
   * Đặt `padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 20.0)` trong `SingleChildScrollView` để các nút và thanh phân trang nằm vừa vặn, không bị khoảng trống quá lớn phía trên thanh Bottom Navigation Bar.

4. **Quản lý danh sách đa Tab (Sent vs Received):**
   * Khi chia tab có lọc thống kê riêng (như *Công việc đang giao* vs *Công việc được giao*), luôn lưu trữ thành 2 `RxList` độc lập trong Controller (`sentTasksList`, `receivedTasksList`) để đảm bảo số liệu trên thẻ thống kê không bị nhảy sai khi chuyển tab.

5. **Luôn kiểm tra Null Safety:**
   * Khi gọi `json['field']`, luôn sử dụng toán tử `??` để gán giá trị mặc định, phòng ngừa lỗi dữ liệu `null` từ Backend.

---

## 7. MÔ HÌNH TẢI DỮ LIỆU CHUẨN: STALE-WHILE-REVALIDATE (SWR)

Để tối ưu hóa trải nghiệm người dùng đạt độ mượt mà cao nhất (không bị chớp giật, không làm người dùng phải chờ đợi vô ích), toàn bộ hệ thống áp dụng mô hình **Stale-While-Revalidate**:

```
                  ┌──────────────────────────────────────────────┐
                  │          NGƯỜI DÙNG MỞ MÀN HÌNH / TAB        │
                  └──────────────────────┬───────────────────────┘
                                         │
                        ┌────────────────┴────────────────┐
                        │ Đã có dữ liệu trong bộ nhớ chưa?│
                        └────────────────┬────────────────┘
                                         │
                  ┌──────────────────────┴──────────────────────┐
                  ▼ (CHƯA CÓ - Lần đầu mở)                      ▼ (ĐÃ CÓ - Các lần sau)
    ┌───────────────────────────────────────────┐ ┌───────────────────────────────────────────┐
    │  Hiện FULL SKELETON SHIMMER LOADER        │ │  HIỆN NGAY DỮ LIỆU CŨ (0ms delay)         │
    │  (Chờ API trả về thì đắp dữ liệu vào)    │ │  + Tải cập nhật ngầm (Background Sync)   │
    │  👉 Không bị đơ, biết app đang tải        │ │  👉 Cực mượt, không chớp giật màn hình   │
    └───────────────────────────────────────────┘ └───────────────────────────────────────────┘
```

### ⚡ Quy tắc triển khai trong Controller & View:
1. **Trong Controller (`fetchData`)**:
   ```dart
   Future<void> fetchItems({bool isRefresh = true}) async {
     // CHỈ BẬT cờ isLoading (hiện Skeleton) khi danh sách hiện tại đang TRỐNG
     if (itemsList.isEmpty) {
       isLoading.value = true;
     }
     if (isRefresh) {
       currentPage.value = 1;
       hasMore.value = true;
       // TUYỆT ĐỐI KHÔNG clear itemsList ở đây để tránh chớp màn hình
     }

     try {
       final response = await _service.getItems();
       if (response != null && response.statusCode == 200) {
         if (isRefresh) {
           itemsList.assignAll(response.data); // Cập nhật mượt mà tại chỗ
         } else {
           itemsList.addAll(response.data);
         }
       }
     } finally {
       isLoading.value = false;
     }
   }
   ```

2. **Trong View (UI)**:
   ```dart
   Obx(() {
     // Khi đang tải lần đầu và chưa có dữ liệu -> Hiện Skeleton toàn màn hình
     if (controller.isLoading.value && controller.itemsList.isEmpty) {
       return _buildFullSkeletonLoader(context);
     }
     
     // Khi đã có dữ liệu -> Vẽ UI bình thường, kéo tay xuống (Pull-to-refresh) để làm mới
     return RefreshIndicator(
       onRefresh: () => controller.fetchItems(isRefresh: true),
       child: ListView.builder(...),
     );
   })
   ```
