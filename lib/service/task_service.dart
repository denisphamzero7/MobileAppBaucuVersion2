import '../core/api_constants.dart';
import '../helper/dio_helper.dart';
import '../model/base_response.dart';
import '../model/task_model.dart';
import '../model/user_model.dart';
import 'petition_service.dart';

class TaskService {
  final DioHelper _http = DioHelper();



  Future<BaseResponse<List<TaskModel>>?> getTasks({
    String? type,
    int? userId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'sort_by': 'id',
        'sort_order': 'desc',
      };
      if (type == 'received' && userId != null) {
        queryParams['assignee_id'] = userId;
      } else if (type == 'sent' && userId != null) {
        queryParams['assigner_id'] = userId;
      } else if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await _http.get(
        url: ApiConstants.taskAssignmentItems,
        queryParameters: queryParams,
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
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('unauthorized') || errorStr.contains('403')) {
        return BaseResponse<List<TaskModel>>(
          statusCode: 200,
          message: 'Không có quyền truy cập',
          data: [],
        );
      }
      print("Error in repository getTasks: $e");
      return null;
    }
  }

  Future<dynamic> exportTasks({String? type, int? userId, String? keyword, String? status, String? timingStatus}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (type == 'received' && userId != null) queryParams['assignee_id'] = userId;
      else if (type == 'sent' && userId != null) queryParams['assigner_id'] = userId;
      else if (type != null && type.isNotEmpty) queryParams['type'] = type;
      
      if (keyword != null && keyword.isNotEmpty) queryParams['search'] = keyword;
      if (status != null && status != 'all') queryParams['processing_status'] = status;
      if (timingStatus != null && timingStatus != 'all') queryParams['timing_status'] = timingStatus;

      final response = await _http.get(
        url: '${ApiConstants.taskAssignmentItems}/export',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return response;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('unauthorized') && !errorStr.contains('403')) {
        print("Error in exportTasks: $e");
      }
      return null;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      final response = await _http.delete(
        url: '${ApiConstants.taskAssignmentItems}/$id',
      );
      return response != null;
    } catch (e) {
      print("Error in repository deleteTask: $e");
      return false;
    }
  }

  Future<bool> bulkDeleteTasks(List<int> ids) async {
    try {
      final response = await _http.delete(
        url: '${ApiConstants.taskAssignmentItems}/bulk-delete',
        data: {'ids': ids},
      );
      return response != null;
    } catch (e) {
      print("Error in repository bulkDeleteTasks: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTaskStats({
    String? startDate,
    String? endDate,
    int? departmentId,
    String? type,
    int? userId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['start_date'] = startDate;
        queryParams['from_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['end_date'] = endDate;
        queryParams['to_date'] = endDate;
      }
      if (departmentId != null) queryParams['department_id'] = departmentId;
      if (type == 'received' && userId != null) queryParams['assignee_id'] = userId;
      else if (type == 'sent' && userId != null) queryParams['assigner_id'] = userId;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;

      final response = await _http.get(
        url: '${ApiConstants.taskAssignmentItems}/stats',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('unauthorized') && !errorStr.contains('403')) {
        print("Error in repository getTaskStats: $e");
      }
      return null;
    }
  }

  Future<dynamic> getStatsByDepartment({String? startDate, String? endDate}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['from_date'] = startDate;
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['to_date'] = endDate;
        queryParams['end_date'] = endDate;
      }

      final response = await _http.get(
        url: '${ApiConstants.taskAssignmentItems}/stats-by-department',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return response;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('unauthorized') && !errorStr.contains('403')) {
        print("Error in repository getStatsByDepartment: $e");
      }
      return null;
    }
  }

  Future<dynamic> getStatsByItemType({String? startDate, String? endDate}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['from_date'] = startDate;
        queryParams['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['to_date'] = endDate;
        queryParams['end_date'] = endDate;
      }

      final response = await _http.get(
        url: '${ApiConstants.taskAssignmentItems}/stats-by-item-type',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return response;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('unauthorized') && !errorStr.contains('403')) {
        print("Error in repository getStatsByItemType: $e");
      }
      return null;
    }
  }


  Future<BaseResponse<TaskModel>?> createTask(Map<String, dynamic> data) async {
    try {
      print("🚀 Payload gửi lên tạo task: $data");
      final response = await _http.post(
        url: ApiConstants.taskAssignmentItems,
        data: data,
      );
      print("✅ in kết quả tạo task: $response");

      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => TaskModel.fromJson(json is Map<String, dynamic> ? json : {}),
        );
      }
      return null;
    } catch (e) {
      print("Error in repository createTask: $e");
      rethrow;
    }
  }

  Future<BaseResponse<TaskModel>?> updateTask(int id, Map<String, dynamic> data) async {
    try {
      final response = await _http.put(
        url: '${ApiConstants.taskAssignmentItems}/$id',
        data: data,
      );
      print("in kết quả cập nhật task: $response");
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => TaskModel.fromJson(json is Map<String, dynamic> ? json : {}),
        );
      }
      return null;
    } catch (e) {
      print("Error in repository updateTask: $e");
      rethrow;
    }
  }

  Future<BaseResponse<List<TaskItemType>>?> getTaskItemTypes() async {
    try {
      final response = await _http.get(
        url: 'task-assignment-item-types',
      );
      print("in kết quả item types: $response");
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
            return list.map((item) => TaskItemType.fromJson(item as Map<String, dynamic>)).toList();
          },
        );
      }
      return null;
    } catch (e) {
      print("Error in repository getTaskItemTypes: $e");
      return null;
    }
  }

  Future<BaseResponse<List<TaskAssignmentDocument>>?> getTaskAssignmentDocuments() async {
    try {
      final response = await _http.get(
        url: 'task-assignment-documents',
      );
      print("in kết quả task-assignment-documents: $response");
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
            return list.map((item) => TaskAssignmentDocument.fromJson(item as Map<String, dynamic>)).toList();
          },
        );
      }
      return null;
    } catch (e) {
      print("Error in repository getTaskAssignmentDocuments: $e");
      return null;
    }
  }

  Future<BaseResponse<List<DepartmentModel>>?> getTaskDepartments() async {
    try {
      final response = await _http.get(
        url: 'task-assignment-departments',
      );
      print("in kết quả task-assignment-departments: $response");
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
            return list.map((item) => DepartmentModel.fromJson(item as Map<String, dynamic>)).toList();
          },
        );
      }
      return null;
    } catch (e) {
      print("Error in repository getTaskDepartments: $e");
      return null;
    }
  }

  Future<BaseResponse<List<User>>?> getDepartmentUsers(int departmentId) async {
    try {
      final response = await _http.get(
        url: 'task-assignment-departments/$departmentId/users',
      );
      print("in kết quả users phòng ban $departmentId: $response");
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
            return list.map((item) {
              final map = item is Map<String, dynamic> ? item : <String, dynamic>{};
              final userMap = map['user'] is Map<String, dynamic> ? map['user'] as Map<String, dynamic> : map;
              final user = User.fromJson(userMap);
              return User(
                id: user.id != 0 ? user.id : (map['user_id'] as int? ?? map['id'] as int? ?? 0),
                name: user.name.isNotEmpty ? user.name : (map['name']?.toString() ?? 'Nhân viên #${map['user_id'] ?? map['id']}'),
                email: user.email,
                userName: user.userName,
                avatar: user.avatar,
                departmentId: departmentId,
                departmentRole: map['department_role']?.toString() ?? 'main',
                assignmentRole: map['assignment_role']?.toString() ?? 'main',
                rawJson: map,
              );
            }).toList();
          },
        );
      }
      return null;
    } catch (e) {
      print("Error in repository getDepartmentUsers: $e");
      return null;
    }
  }
}


