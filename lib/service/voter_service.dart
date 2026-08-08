

import '../core/api_constants.dart';
import '../helper/scan_voter_request.dart';
import '../model/auth_model.dart';
import '../model/base_response.dart';
import '../helper/dio_helper.dart';

class VoterService {
  final DioHelper _http = DioHelper();
  Future<BaseResponse<dynamic>?> scanVoter(ScanVoterRequest request) async {
    try {
      final response = await _http.post(
          url: ApiConstants.votersScan,
          data: request.toJson(),// Chỉ cần gọi tên biến, không sợ gõ sai
      );
      if (response != null) {

        return BaseResponse.fromJson(
          response ,
              (json) => json, // Giữ nguyên data ở dạng thô

        );
      }
      return null;
    } catch (e) {
      print("Error in repository login: $e");
      return null;
    }
  }
}