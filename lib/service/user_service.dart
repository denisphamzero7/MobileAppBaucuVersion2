

import '../core/api_constants.dart';

import '../model/base_response.dart';
import '../helper/dio_helper.dart';
import '../model/profile.dart';

import '../model/user_model.dart';

class UserService {
  final DioHelper _http = DioHelper();
  Future<BaseResponse<ProfileData>?> getProfile() async {
    try {
      final response = await _http.get(
          url: ApiConstants.profile
      );
      print("in kết quả: $response");
      if (response != null) {

        return BaseResponse.fromJson(
            response, (json) => ProfileData.fromJson(json as Map<String, dynamic>)
        );

      }
      return null;
    } catch (e) {
      print("Error in repository getProfile: $e");
      rethrow;
    }
  }

  Future<BaseResponse<List<User>>?> getUsers() async {
    try {
      final response = await _http.get(url: ApiConstants.users);
      print("in kết quả users: $response");
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) {
            List list = [];
            if (json is List) {
              list = json;
            } else if (json is Map<String, dynamic> && json['data'] is List) {
              list = json['data'] as List;
            }
            return list.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
          },
        );
      }
      return null;
    } catch (e) {
      print("Error in repository getUsers: $e");
      return null;
    }
  }

  Future<bool> changePassword(String newPassword, String confirmPassword) async {
    try {
      final response = await _http.put(
        url: 'users/me',
        data: {
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );
      print("in kết quả đổi mật khẩu: $response");
      return true;
    } catch (e) {
      print("Error in changePassword: $e");
      rethrow;
    }
  }
}
