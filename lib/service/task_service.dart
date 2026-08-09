import '../core/api_constants.dart';
import '../helper/dio_helper.dart';
import '../model/base_response.dart';
import '../model/task_model.dart';

class TaskService {
  final DioHelper _http = DioHelper();

  Future<BaseResponse<List<TaskModel>>?> getTasks() async {
    try {
      final response = await _http.get(
        url: ApiConstants.taskAssignmentItems,
      );
      print("in kết quả tasks: $response");
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
            return listData.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
          }
        );
      }
      return null;
    } catch (e) {
      print("Error in repository getTasks: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTaskStats({String? startDate, String? endDate, int? departmentId}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (startDate != null && startDate.isNotEmpty) queryParams['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty) queryParams['end_date'] = endDate;
      if (departmentId != null) queryParams['department_id'] = departmentId;

      final response = await _http.get(
        url: '${ApiConstants.taskAssignmentItems}/stats',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      print("in kết quả task stats: $response");
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      print("Error in repository getTaskStats: $e");
      return null;
    }
  }
}
