import '../helper/dio_helper.dart';
import '../model/base_response.dart';
import '../model/log_activity.dart';

class LogActivityService {
  final DioHelper _http = DioHelper();

  Future<BaseResponse<List<LogActivity>>?> getLogs() async {
    try {
      final response = await _http.get(
        url: 'log-activities/me',
      );
      print("in kết quả logs: $response");
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) {
            List listData = [];
            if (json is List) {
              listData = json;
            } else if (json is Map<String, dynamic> && json['data'] is List) {
              listData = json['data'] as List;
            }
            return listData.map((item) => LogActivity.fromJson(item as Map<String, dynamic>)).toList();
          }
        );
      }
      return null;
    } catch (e) {
      print("Error in repository getLogs: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTimelineStats() async {
    try {
      final response = await _http.get(
        url: 'log-activities/me/stats/timeline',
      );
      print("in kết quả timeline stats: $response");
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      print("Error in repository getTimelineStats: $e");
      return null;
    }
  }
}
