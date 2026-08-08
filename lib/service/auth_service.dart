

import '../core/api_constants.dart';
import '../model/auth_model.dart';
import '../model/base_response.dart';
import '../helper/dio_helper.dart';

class AuthService {
  final DioHelper _http = DioHelper();
  Future<BaseResponse<LoginData>?> login(String email, String password) async {
    try {
      final response = await _http.post(
          url: ApiConstants.login,
          data: { "username": email, "password": password }
      );
      print("in kết quả: $response");
      if (response != null) {

        return BaseResponse.fromJson(
            response,
                (json) =>
                LoginData.fromJson(json)
        );
      }
      return null;
    } catch (e) {
      print("Error in repository login: $e");
      return null;
    }
  }

  Future<BaseResponse?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await _http.post(
        url: ApiConstants.register,
        data: {
          "email": email,
          "password": password,
          "name": name,
          "phone": phone,
          "age": 20,
          "gender": "other",
          "address": "Vietnam",
        }
      );
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => null
        );
      }
      return null;
    } catch (e) {
      print("Error in repository register: $e");
      return null;
    }
  }

  Future<BaseResponse?> logout() async {
    try {
      final response = await _http.post(
          url: ApiConstants.logout,
      );
      if (response != null) {
        // Sử dụng BaseResponse không có generic type để xử lý phản hồi đơn giản
        // Nếu API trả về 201 Created, BaseResponse sẽ được tạo thành công
        return BaseResponse.fromJson(
            response,
                (json) => null // Không cần phân tích data nếu data là 'true'
        );
      }
    }catch(e){
      print("Error in repository logout: $e");
      // Nếu có lỗi 401 (Unauthorized) thì DioHelper sẽ ném DioException
      // Hàm này sẽ bắt lỗi và trả về null.
      return null;
    }
    return null;
  }
}