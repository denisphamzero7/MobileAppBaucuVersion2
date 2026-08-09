

import '../core/api_constants.dart';

import '../model/base_response.dart';
import '../helper/dio_helper.dart';
import '../model/profile.dart';

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
      return null;
    }
  }



}