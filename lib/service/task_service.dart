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
}
