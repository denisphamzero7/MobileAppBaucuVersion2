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
          data: { "email": email, "password": password }
      );
      print("in kết quả: $response");
      print('Switch org response: $response');
      if (response != null) {
        return BaseResponse.fromJson(
            response,
            (json) => LoginData.fromJson(json as Map<String, dynamic>)
        );
      }
      return null;
    } catch (e) {
      print("Error in repository login: $e");
      rethrow; // Ném lỗi để AuthController bắt được thông điệp lỗi cụ thể
    }
  }

  Future<BaseResponse<LoginData>?> switchOrganization(int organizationId) async {
    print('Calling switchOrganization');
    try {
      final response = await _http.post(
        url: ApiConstants.switchOrganization,
        data: {
          "organization_id": organizationId,
        },
      );
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => LoginData.fromJson(json as Map<String, dynamic>),
        );
      }
      return null;
    } catch (e) {
      print("Error in repository switchOrganization: $e");
      rethrow;
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
      rethrow;
    }
  }

  Future<BaseResponse?> logout() async {
    try {
      final response = await _http.post(
          url: ApiConstants.logout,
      );
      if (response != null) {
        return BaseResponse.fromJson(
            response,
            (json) => null
        );
      }
    } catch (e) {
      print("Error in repository logout: $e");
      rethrow;
    }
    return null;
  }
}