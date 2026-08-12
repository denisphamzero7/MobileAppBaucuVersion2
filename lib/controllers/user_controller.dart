import 'package:get/get.dart';
import 'dart:developer';

import '../model/profile.dart';
import '../service/user_service.dart';
import 'auth_controller.dart'; // ⚠️ Cần import AuthController

class UserController extends GetxController {
  final UserService _userService = UserService();

  // ⚠️ Lấy instance của AuthController
  final AuthController _authController = Get.find<AuthController>();

  // Biến Observable để lưu trữ dữ liệu hồ sơ người dùng
  final Rx<ProfileData?> userProfile = Rx<ProfileData?>(null);

  // Biến Observable để theo dõi trạng thái tải dữ liệu
  final RxBool isLoading = false.obs;

  // Biến Observable để lưu trữ thông báo lỗi
  final RxString errorMessage = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

  }

  // Hàm tải dữ liệu hồ sơ từ API
  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _userService.getProfile();

      if (response != null && response.statusCode == 200) {
        // Cập nhật dữ liệu thành công
        userProfile.value = response.data;
        log("✅ Tải hồ sơ thành công cho User: ${response.data.name}");
      } else {
        // Xử lý lỗi (ví dụ: status code không phải 200)
        final msg = response?.message ?? 'Không thể tải dữ liệu hồ sơ.';
        errorMessage.value = msg;
        log("❌ Lỗi tải hồ sơ ($response.statusCode): $msg");
        Get.snackbar("Lỗi", msg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      // Xử lý lỗi ngoại lệ (mất mạng, lỗi parsing,...)
      final errorMsg = e.toString().replaceAll("Exception: ", "");
      errorMessage.value = 'Lỗi không xác định: $errorMsg';
      log("❌ Ngoại lệ khi tải hồ sơ: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm làm mới dữ liệu (Refresh)
  Future<void> refreshProfile() async {
    await fetchProfile();
  }

  // ⚠️ HÀM LOGOUT MỚI
  Future<void> logout() async {
    // Hiển thị loading để tránh việc nháy giao diện "Không có dữ liệu"
    isLoading.value = true;
    
    // Thêm delay 1s để người dùng nhìn thấy Skeleton Loading và thông báo Đăng xuất
    await Future.delayed(const Duration(seconds: 1));
    
    // Gọi hàm logout từ AuthController và đợi nó hoàn thành (chuyển trang)
    await _authController.logout();

    // Reset trạng thái của Profile Controller
    userProfile.value = null;
    isLoading.value = false;
    errorMessage.value = '';

    log("🚪 User đã gọi logout.");
  }
}