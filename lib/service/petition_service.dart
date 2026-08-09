import '../core/api_constants.dart';
import '../helper/dio_helper.dart';
import '../model/base_response.dart';

class DepartmentModel {
  final int id;
  final String name;

  DepartmentModel({required this.id, required this.name});

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class PetitionService {
  final DioHelper _http = DioHelper();

  Future<BaseResponse<List<DepartmentModel>>?> getAvailableDepartments() async {
    try {
      final response = await _http.get(
        url: ApiConstants.taskAssignmentPetitionsDepartments,
      );
      print("in kết quả departments: $response");
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
            return listData
                .map((item) => DepartmentModel.fromJson(item as Map<String, dynamic>))
                .toList();
          },
        );
      }
      return null;
    } catch (e) {
      print("Error in PetitionService getAvailableDepartments: $e");
      return null;
    }
  }
}
