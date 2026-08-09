import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart' hide User;

import '../model/auth_model.dart';
import '../service/auth_service.dart';
import 'task_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final _storage = GetStorage();

  // --- State Management ---
  final RxBool isLoading = false.obs;
  final RxBool isFirstTime = true.obs;
  final RxBool isLoggedIn = false.obs;
  final RxnInt currentOrganizationId = RxnInt(null);

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

    // Lấy Token và ID tổ chức
    String? token = _storage.read('accessToken');
    var orgId = _storage.read('organizationId');
    if (orgId != null) {
      currentOrganizationId.value = int.tryParse(orgId.toString());
    }

    // Lấy thông tin User đã lưu để khôi phục lại State
    var savedUser = _storage.read('userInfo');
    if (savedUser != null) {
      try {
        currentUser.value = User.fromJson(savedUser as Map<String, dynamic>);
      } catch (e) {
        log("Lỗi parse user info từ storage: $e");
      }
    }

    // Check Login (yêu cầu có cả Token và Tổ chức đã chọn)
    if (token != null && token.isNotEmpty && orgId != null) {
      isLoggedIn.value = true;

      // --- ONESIGNAL (Auto Login) ---
      String? userId = currentUser.value?.id.toString() ?? _storage.read('userId');

      if (userId != null && userId.isNotEmpty) {
        OneSignal.login(userId);
        log("🔔 [OneSignal] Auto-login với UserID: $userId");
      } else {
        log("⚠️ [OneSignal] Auto-login nhưng không tìm thấy 'userId' đã lưu.");
      }
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

        if (data.availableOrganizations.isEmpty) {
          Get.snackbar("Đăng nhập thất bại", "Tài khoản không thuộc bất kỳ tổ chức nào.", snackPosition: SnackPosition.BOTTOM);
          return;
        }

        // Hiện popup chọn tổ chức
        _showOrganizationSelectionDialog(data);
      } else {
        Get.snackbar("Đăng nhập thất bại", "Không thể lấy thông tin đăng nhập từ hệ thống.", snackPosition: SnackPosition.BOTTOM);
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

  // Popup hiển thị danh sách tổ chức để chọn
  void _showOrganizationSelectionDialog(LoginData data) {
    Get.dialog(
      PopScope(
        canPop: false, // Không cho phép đóng popup bằng nút Back của thiết bị để bắt buộc chọn
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _storage.remove('accessToken');
            Get.snackbar("Đăng nhập thất bại", "Bạn chưa chọn tổ chức");
          }
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Chọn tổ chức làm việc",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Vui lòng chọn tổ chức dưới đây để tiếp tục:",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.availableOrganizations.length,
                    itemBuilder: (context, index) {
                      final org = data.availableOrganizations[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            org.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            // Gọi API switch organization
                            final success = await _switchOrganization(org.id, data);
                            if (success) {
                              Get.back(); // Đóng popup chọn tổ chức
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    _storage.remove('accessToken');
                    Get.back(); // Đóng popup
                    Get.snackbar("Đăng nhập thất bại", "Bạn chưa chọn tổ chức");
                  },
                  child: const Text("Hủy bỏ", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false, // Bắt buộc tương tác qua popup
    );
  }

  // Gọi API chuyển đổi và xác thực tổ chức
  Future<bool> _switchOrganization(int orgId, LoginData loginData) async {
    try {
      // Lưu tạm thời token để DioHelper gửi kèm trong API switchOrganization
      await _storage.write('accessToken', loginData.accessToken);

      final response = await _authService.switchOrganization(orgId);
      if (response != null && response.statusCode == 200) {
        // Lưu cấu hình chính thức
        await _storage.write('accessToken', loginData.accessToken);
        await _storage.write('organizationId', orgId);
        currentOrganizationId.value = orgId;

        // Lưu danh sách tổ chức để chuyển đổi linh hoạt
        final orgsJson = loginData.availableOrganizations.map((x) => x.toJson()).toList();
        await _storage.write('availableOrganizations', orgsJson);

        // Lưu thông tin User
        currentUser.value = loginData.user;
        await _storage.write('userInfo', loginData.user.toJson());
        await _storage.write('userId', loginData.user.id.toString());

        // --- ONESIGNAL LOGIN ---
        OneSignal.login(loginData.user.id.toString());

        // Cập nhật trạng thái chung
        isLoggedIn.value = true;

        Get.snackbar("Thành công", "Đăng nhập thành công!");
        Get.offAllNamed('/home');
        return true;
      } else {
        Get.snackbar("Thất bại", "Bạn chọn sai tổ chức");
        await _storage.remove('accessToken');
        return false;
      }
    } catch (e) {
      log("Lỗi switchOrganization: $e");
      Get.snackbar("Thất bại", "Bạn chọn sai tổ chức");
      await _storage.remove('accessToken');
      return false;
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
    try {
      await _authService.logout();
      log("API Logout thành công (hoặc bỏ qua)");
    } catch (e) {
      log("Logout API lỗi: $e");
    }

    // ONESIGNAL LOGOUT
    OneSignal.logout();
    log("🔔 [OneSignal] Đã Logout");

    // Xóa dữ liệu Local
    await _storage.remove('accessToken');
    await _storage.remove('refreshToken');
    await _storage.remove('organizationId');
    await _storage.remove('userInfo');
    await _storage.remove('userId');

    // Reset State
    isLoggedIn.value = false;
    currentUser.value = null;
    currentOrganizationId.value = null;

    // Về trang Login
    Get.offAllNamed('/login');
  }

  void setFirstTimeDone() {
    isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  List<Organization> getAvailableOrganizations() {
    final list = _storage.read('availableOrganizations') as List? ?? [];
    return list.map((x) => Organization.fromJson(x as Map<String, dynamic>)).toList();
  }

  Future<void> changeOrganization(int orgId) async {
    isLoading.value = true;
    try {
      final response = await _authService.switchOrganization(orgId);
      if (response != null && response.statusCode == 200) {
        await _storage.write('organizationId', orgId);
        currentOrganizationId.value = orgId;
        
        // Làm mới TaskController
        if (Get.isRegistered<TaskController>()) {
          Get.find<TaskController>().fetchTasks();
        }
        
        Get.snackbar("Thành công", "Đã chuyển đổi tổ chức thành công!");
      } else {
        Get.snackbar("Thất bại", "Không thể chuyển sang tổ chức này.");
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Lỗi khi chuyển đổi tổ chức: $e");
    } finally {
      isLoading.value = false;
    }
  }
}