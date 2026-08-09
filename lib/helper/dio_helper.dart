import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart'; // Để dùng Get.offAllNamed khi logout
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/api_constants.dart'; // Để in log đẹp hơn print

class DioHelper {
  // 1. Singleton: Đảm bảo chỉ có 1 instance duy nhất trong app
  static final DioHelper _instance = DioHelper._internal();
  factory DioHelper() => _instance;

  late Dio _dio;
  final _box = GetStorage(); // Khởi tạo box để đọc token

  // Cấu hình Base URL và Timeout
  // (Bạn nên lấy từ file api_constants.dart như đã bàn trước đó)
  static const String _baseUrl = ApiConstants.baseUrl;

  DioHelper._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15), // 15s timeout kết nối
        receiveTimeout: const Duration(seconds: 30), // 30s timeout nhận dữ liệu
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
      ),
    );

    _initializeInterceptors();
  }

  // Getter để truy cập trực tiếp Dio nếu cần
  Dio get dio => _dio;

  // 2. Cấu hình Interceptor (Người gác cổng)
  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        // a. Trước khi gửi Request
        onRequest: (options, handler) {
          // Không gửi token đối với các API public như đăng nhập/đăng ký để tránh bị server redirect về HTML khi token cũ hết hạn
          if (!options.path.contains('auth/login') && !options.path.contains('auth/register')) {
            final token = _box.read('accessToken');
            if (token != null && token.toString().isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }
          }

          // Thêm ID tổ chức vào Header nếu có
          final orgId = _box.read('organizationId');
          if (orgId != null) {
            options.headers["X-Organization-Id"] = orgId.toString();
          }

          return handler.next(options);
        },

        // b. Khi nhận Response thành công
        onResponse: (response, handler) {
          log("✅ [RES] << ${response.statusCode} ${response.requestOptions.path}");
          return handler.next(response);
        },

        // c. Khi gặp Lỗi (Mạng, 401, 500...)
        onError: (DioException e, handler) {
          log("❌ [ERR] << ${e.response?.statusCode} ${e.requestOptions.path} | ${e.message}");

          // Xử lý đặc biệt: Nếu lỗi 401 (Unauthorized) -> Token hết hạn hoặc sai
          if (e.response?.statusCode == 401) {
            _handleUnauthorized();
          }

          return handler.next(e);
        },
      ),
    );
  }

  // Xử lý khi token hết hạn
  void _handleUnauthorized() {
    // 1. Xóa token cũ
    _box.remove('accessToken');
    _box.remove('refreshToken');

    // 2. Có thể hiện thông báo hoặc chuyển thẳng về trang login
    // Kiểm tra xem có đang ở trang login không để tránh loop
    if (Get.currentRoute != '/login') {
      Get.snackbar("Phiên đăng nhập hết hạn", "Vui lòng đăng nhập lại");
      Get.offAllNamed('/login'); // Yêu cầu bạn đã setup GetPage cho '/login'
    }
  }
  // Hàm kiểm tra kết nối mạng
  Future<void> _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    // Kiểm tra nếu không có kết nối Internet (chỉ có bluetooth/none)
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // Ném lỗi để được catch trong các hàm get/post/etc.
      // ⚠️ ĐÃ XÓA TỪ KHÓA 'const'
      throw DioException(
        requestOptions: RequestOptions(path: 'connectivity check'),
        type: DioExceptionType.connectionError,
        error: "Không có kết nối mạng.",
      );
    }
  }
  // --- CÁC HÀM WRAPPER (GỌI API) ---

  // 3. GET
  Future<dynamic> get({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await _checkConnectivity();
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<dynamic> post({
    required String url,
    Object? data, // Chỉ cần 1 biến này là đủ (nhận cả Map, List, FormData)
  }) async {
    try {
      await _checkConnectivity();
      // Dio tự động nhận biết data là Map hay FormData để xử lý
      final response = await _dio.post(url, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e); // Hàm xử lý lỗi bạn đã viết
    }
  }

  // 5. PUT
  Future<dynamic> put({
    required String url,
    Object? data,
  }) async {
    try {
      await _checkConnectivity();
      final response = await _dio.put(url, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // 6. PATCH
  Future<dynamic> patch({
    required String url,
    Object? data,
  }) async {
    try {
      await _checkConnectivity();
      final response = await _dio.patch(url, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // 7. DELETE
  Future<dynamic> delete({
    required String url,
  }) async {
    try {
      await _checkConnectivity();
      final response = await _dio.delete(url);
      return response.data;
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // --- HÀM XỬ LÝ LỖI CHUNG ---
  // Mục đích: Lấy message sạch từ backend gửi về để hiện lên UI
  Exception _parseError(DioException e) {
    String msg = "Có lỗi xảy ra, vui lòng thử lại.";

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      msg = "Kết nối quá hạn. Vui lòng kiểm tra internet.";
    } else if (e.type == DioExceptionType.connectionError) {
      msg = "Không có kết nối mạng.";
    } else if (e.response != null) {
      // Server có phản hồi (ví dụ 400, 404, 500)
      final data = e.response?.data;

      // Kiểm tra cấu trúc JSON trả về từ Server của bạn
      // Ví dụ: { "message": "Email đã tồn tại", "statusCode": 400 }
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        msg = data['message'];
      } else if (data is String) {
        msg = data; // Trường hợp server trả về string thô
      } else {
        msg = "Lỗi máy chủ (${e.response?.statusCode})";
      }
    }

    // Trả về Exception sạch để Controller catch
    return Exception(msg);
  }
}