import '../untils/app_colors.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart' hide User;

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

  // Biến lưu danh sách quyền CASL
  final RxList<Map<String, dynamic>> userAbilities = <Map<String, dynamic>>[].obs;

  String get currentOrganizationName {
    if (currentOrganizationId.value == null) return "Chưa chọn tổ chức";
    var orgsJson = _storage.read('availableOrganizations') as List?;
    if (orgsJson != null) {
      for (var json in orgsJson) {
         if (json['id'] == currentOrganizationId.value) {
            return json['name'].toString();
         }
      }
    }
    return "Tổ chức không xác định";
  }

  List<Organization> get availableOrganizationsList {
    var orgsJson = _storage.read('availableOrganizations') as List?;
    if (orgsJson != null) {
      return orgsJson.map((x) => Organization.fromJson(x as Map<String, dynamic>)).toList();
    }
    return [];
  }

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

    var savedAbilities = _storage.read('abilities');
    if (savedAbilities != null) {
      userAbilities.value = (savedAbilities as List).map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // Check Login (yêu cầu có cả Token và Tổ chức đã chọn)
    if (token != null && token.isNotEmpty && orgId != null) {
      isLoggedIn.value = true;

      // --- ONESIGNAL (Auto Login) ---
      String? userId = currentUser.value?.id.toString() ?? _storage.read('userId');

      if (userId != null && userId.isNotEmpty) {
        // Tạm ẩn OneSignal
        // OneSignal.login(userId);
        // log("🔔 [OneSignal] Auto-login với UserID: $userId");
      } else {
        // log("⚠️ [OneSignal] Auto-login nhưng không tìm thấy 'userId' đã lưu.");
      }
    } else {
      isLoggedIn.value = false;
    }
  }

    // 2. Hàm Đăng Nhập
  Future<LoginData?> login(String email, String password) async {
    try {
      isLoading.value = true;

      // Gọi API
      final response = await _authService.login(email, password);
      if (response != null) {
        final LoginData data = response.data;

        if (data.availableOrganizations.isEmpty) {
          Get.snackbar("Đăng nhập thất bại", "Tài khoản không thuộc bất kỳ tổ chức nào.", snackPosition: SnackPosition.BOTTOM);
          return null;
        }

        return data;
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
    return null;
  }

  // Gọi API chuyển đổi và xác thực tổ chức
      Future<bool> switchOrganizationAfterLogin(int orgId, LoginData loginData) async {
    try {
      // Lưu tạm thời token cũ để gửi request switch
      await _storage.write('accessToken', loginData.accessToken);

      final response = await _authService.switchOrganization(orgId);
      if (response != null && response.statusCode == 200) {
        final newData = response.data;
        
        // NẾU API switch trả về access_token rỗng, có nghĩa là API chỉ trả về user info / abilities chứ không cấp token mới
        // Trong trường hợp đó, ta PHẢI giữ lại token cũ.
        final String finalToken = (newData != null && newData.accessToken.isNotEmpty) 
            ? newData.accessToken 
            : loginData.accessToken;

        await _storage.write('accessToken', finalToken);
        await _storage.write('organizationId', orgId);
        currentOrganizationId.value = orgId;

        // Nếu API switch không trả về availableOrganizations (rỗng), thì giữ lại cái cũ
        final orgsList = (newData != null && newData.availableOrganizations.isNotEmpty) 
            ? newData.availableOrganizations 
            : loginData.availableOrganizations;
        final orgsJson = orgsList.map((x) => x.toJson()).toList();
        await _storage.write('availableOrganizations', orgsJson);

        final user = (newData != null && newData.user.id != 0) ? newData.user : loginData.user;
        currentUser.value = user;
        await _storage.write('userInfo', user.toJson());
        await _storage.write('userId', user.id.toString());

        final abilities = (newData != null && newData.abilities.isNotEmpty) ? newData.abilities : loginData.abilities;
        userAbilities.value = abilities; 
        await _storage.write('abilities', abilities);

        isLoggedIn.value = true;
        Get.offAllNamed('/home');
        return true;
      } else {
        Get.snackbar("Thất bại", "Bạn chọn sai tổ chức");
        await _storage.remove('accessToken');
        return false;
      }
    } catch (e) {
      Get.snackbar("Thất bại", "Lỗi chuyển đổi tổ chức: ${e.toString()}");
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
    // Tạm ẩn OneSignal
    // OneSignal.logout();
    // log("🔔 [OneSignal] Đã Logout");

    // Xóa dữ liệu Local
    await _storage.remove('accessToken');
    await _storage.remove('refreshToken');
    await _storage.remove('organizationId');
    await _storage.remove('userInfo');
    await _storage.remove('userId');
    await _storage.remove('abilities');

    // Reset State
    isLoggedIn.value = false;
    currentUser.value = null;
    currentOrganizationId.value = null;
    userAbilities.clear();

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
        
        // Làm mới TaskController (Làm mới danh sách, phòng ban và thống kê)
        if (Get.isRegistered<TaskController>()) {
          final taskCtrl = Get.find<TaskController>();
          taskCtrl.fetchDepartments();
          taskCtrl.fetchTasks();
          taskCtrl.fetchStats();
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

  /// Kiểm tra quyền theo chuẩn CASL
  bool can(String action, String subject) {
    return userAbilities.any((ability) => 
        ability['action'] == action && ability['subject'] == subject);
  }
}


