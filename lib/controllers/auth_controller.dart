import 'dart:developer'; // Để in log
import 'package:app_baucu_version1/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'; // Import OneSignal

// Sửa lại đường dẫn import cho phù hợp với dự án của bạn
import '../model/auth_model.dart';
import '../service/auth_service.dart';
import '../view/home/home_screen.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final _storage = GetStorage();

  // --- State Management ---
  final RxBool isLoading = false.obs;
  final RxBool isFirstTime = true.obs;
  final RxBool isLoggedIn = false.obs;

  // Biến để lưu thông tin User hiện tại
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadInitialState();
  }

  // 1. Load trạng thái khi mở App (Auto Login)
  void _loadInitialState() {
    // Check First Time
    isFirstTime.value = _storage.read('isFirstTime') ?? true;

    // Lấy Token
    String? token = _storage.read('accessToken');

    // SỬA: Lấy thông tin User đã lưu để khôi phục lại State
    var savedUser = _storage.read('userInfo');
    if (savedUser != null) {
      try {
        // Convert từ JSON Map sang Object User
        // Giả sử savedUser là Map<String, dynamic>
        currentUser.value = User.fromJson(savedUser as Map<String, dynamic>);
      } catch (e) {
        log("Lỗi parse user info từ storage: $e");
      }
    }

    // Check Login
    if (token != null && token.isNotEmpty) {
      isLoggedIn.value = true;

      // --- ONESIGNAL (Bước 3/4: Auto Login) ---
      // Lấy UserID từ storage hoặc từ currentUser vừa khôi phục
      // Ưu tiên lấy từ currentUser nếu nó đã được khôi phục thành công
      String? userId = currentUser.value?.id ?? _storage.read('userId');

      if (userId != null && userId.isNotEmpty) {
        OneSignal.login(userId);
        log("🔔 [OneSignal] Auto-login với UserID: $userId");
      } else {
        log("⚠️ [OneSignal] Auto-login nhưng không tìm thấy 'userId' đã lưu.");
      }
      // --- KẾT THÚC ONESIGNAL ---
    } else {
      isLoggedIn.value = false;
    }
  }

  // 2. Hàm Đăng Nhập
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      // Gọi API
      final response = await _authService.login(email, password);
      if (response != null && response.data != null) {
        final LoginData data = response.data!;
        await _storage.write('accessToken', data.accessToken);
        await _storage.write('refreshToken', data.refreshToken);
        currentUser.value = data.user;
        await _storage.write('userInfo', data.user.toJson());
        if (data.user?.id != null && data.user!.id.isNotEmpty) {
          String userId = data.user!.id;
          await _storage.write('userId', userId);
          OneSignal.login(userId);
        } else {
          log("⚠️ [OneSignal] User ID bị null/rỗng, không thể login OneSignal");
        }
        // --- KẾT THÚC ONESIGNAL ---

        // --- D. Cập nhật trạng thái chung ---
        isLoggedIn.value = true;

        Get.snackbar("Thành công", "Đăng nhập thành công!");
        // Chuyển hướng
        Get.offAllNamed('/home');
      }
    } catch (e) {
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      if (errorMsg.contains("no connect internet")) {
        errorMsg = "Vui lòng kiểm tra lại kết nối mạng của bạn.";
      }
      Get.snackbar("Đăng nhập thất bại", errorMsg, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // 2.1. Hàm Đăng Ký
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      if (response != null) {
        Get.snackbar("Thành công", "Đăng ký tài khoản thành công!");
        return true;
      }
      return false;
    } catch (e) {
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      Get.snackbar("Đăng ký thất bại", errorMsg, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 3. Hàm Đăng Xuất
  Future<void> logout() async {
    // a. Gọi API Logout (Best effort)
    try {
      await _authService.logout(); // Giả định service của bạn có hàm này
      log("API Logout thành công (hoặc bỏ qua)");
    } catch (e) {
      log("Logout API lỗi: $e");
    }

    // b. --- ONESIGNAL LOGOUT (Bước 5) ---
    OneSignal.logout();
    log("🔔 [OneSignal] Đã Logout");

    // c. Xóa dữ liệu Local
    await _storage.remove('accessToken');
    await _storage.remove('refreshToken');
    await _storage.remove('userInfo'); // Xóa thông tin user lưu trữ

    // --- ONESIGNAL (Bước 6: Xóa userId đã lưu) ---
    await _storage.remove('userId');

    // d. Reset State
    isLoggedIn.value = false;
    currentUser.value = null; // Reset user về null

    // e. Về trang Login
    Get.offAllNamed('/login');
  }

  void setFirstTimeDone() {
    isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }
}