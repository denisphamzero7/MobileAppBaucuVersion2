import 'dart:developer' as developer;
import '../core/api_constants.dart';
import '../helper/dio_helper.dart';
import '../model/base_response.dart';
import '../model/department_model.dart';
import '../model/task_model.dart';
import '../model/user_model.dart';

class TaskService {
  final DioHelper _http = DioHelper();

  Future<BaseResponse<List<TaskModel>>?> getTasks({
    String? type,
    int? userId,
    int? documentId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'sort_by': 'id',
        'sort_order': 'desc',
      };
      
      if (documentId != null && documentId > 0) {
        queryParams['task_assignment_document_id'] = documentId;
      }
      if (type == 'sent' && userId != null && userId > 0) {
        queryParams['assigner_id'] = userId;
      } else if (type == 'received' && userId != null && userId > 0) {
        queryParams['assignee_id'] = userId;
      }

      final response = await _http.get(
        url: ApiConstants.taskAssignmentItems,
        queryParameters: queryParams,
      );
      developer.log("Get tasks ($type) response: $response", name: "TaskService");
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
          },
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
      developer.log("Error in repository getTasks: $e", name: "TaskService");
      return null;
    }
  }

  Future<BaseResponse<TaskModel>?> getTaskDetails(int id) async {
    try {
      final response = await _http.get(
        url: '${ApiConstants.taskAssignmentItems}/$id',
      );
      developer.log("Get task details response: $response", name: "TaskService");
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => TaskModel.fromJson(json is Map<String, dynamic> ? json : {}),
        );
      }
      return null;
    } catch (e) {
      developer.log("Error in repository getTaskDetails: $e", name: "TaskService");
      return null;
    }
  }

  Future<bool> updateTaskProgress(int id, {required int completionPercent, String? processingStatus, String? note}) async {
    try {
      final status = processingStatus ?? (completionPercent >= 100 ? 'done' : 'in_progress');
      final Map<String, dynamic> data = {
        'completion_percent': completionPercent,
        'processing_status': status,
      };
      if (note != null && note.isNotEmpty) {
        data['note'] = note;
      }

      final response = await _http.patch(
        url: '${ApiConstants.taskAssignmentItems}/$id/progress',
        data: data,
      );
      developer.log("Update task progress response: $response", name: "TaskService");
      return response != null;
    } catch (e) {
      developer.log("Error in repository updateTaskProgress: $e", name: "TaskService");
      return false;
    }
  }

  /// Tạo báo cáo tiến độ mới (lưu vào bảng task_assignment_item_reports)
  Future<bool> createTaskReport(int taskId, {required int completionPercent, String? note, int? assigneeUserId}) async {
    try {
      final Map<String, dynamic> data = {
        'task_assignment_item_id': taskId,
        'completion_percent': completionPercent,
      };
      if (note != null && note.isNotEmpty) {
        data['report_document_content'] = note;
        data['report_document_excerpt'] = note;
      }
      if (assigneeUserId != null && assigneeUserId > 0) {
        data['assignee_user_id'] = assigneeUserId;
      }
      if (completionPercent >= 100) {
        data['completed_at'] = DateTime.now().toIso8601String().split('T').first;
      }

      final response = await _http.post(
        url: ApiConstants.taskAssignmentItemReports,
        data: data,
      );
      developer.log("Create task report response: $response", name: "TaskService");
      return response != null;
    } catch (e) {
      developer.log("Error in repository createTaskReport: $e", name: "TaskService");
      return false;
    }
  }

  /// Lấy danh sách lịch sử báo cáo công việc từ endpoint task-assignment-item-reports
  Future<List<TaskProgressReport>> getTaskItemReports(int taskId) async {
    try {
      final response = await _http.get(
        url: ApiConstants.taskAssignmentItemReports,
        queryParameters: {
          'task_assignment_item_id': taskId,
          'limit': 50,
          'sort_by': 'created_at',
          'sort_order': 'asc',
        },
      );
      developer.log("Get task reports response for #$taskId: $response", name: "TaskService");

      List list = [];
      if (response != null) {
        if (response['data'] is List) {
          list = response['data'] as List;
        } else if (response['data'] is Map && response['data']['data'] is List) {
          list = response['data']['data'] as List;
        }
      }

      final List<TaskProgressReport> reports = [];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final rawPercent = item['completion_percent'] ?? item['progress'] ?? item['percent'];
          int parsedPercent = 0;
          if (rawPercent is num) {
            parsedPercent = rawPercent.toInt();
          } else if (rawPercent != null) {
            parsedPercent = int.tryParse(rawPercent.toString()) ?? 0;
          }

          final date = item['created_at'] ?? item['completed_at'] ?? item['date'] ?? item['timestamp'] ?? '';
          final note = item['report_document_content'] ?? item['report_document_excerpt'] ?? item['content'] ?? item['note'];
          final reporter = item['user'] is Map ? item['user']['name'] : (item['assignee_user'] is Map ? item['assignee_user']['name'] : null);

          reports.add(TaskProgressReport(
            percent: parsedPercent,
            date: date.toString(),
            note: note?.toString(),
            reporterName: reporter?.toString(),
          ));
        }
      }
      return reports;
    } catch (e) {
      developer.log("Error in repository getTaskItemReports: $e", name: "TaskService");
      return [];
    }
  }

  Future<({List<TaskProgressReport> reports, List<TaskDiscussionNote> discussions})> getTaskTimelineData(int id) async {
    try {
      // 1. Gọi song song cả API task-assignment-item-reports và API timeline
      final itemReportsFuture = getTaskItemReports(id);
      final timelineFuture = _http.get(
        url: '${ApiConstants.taskAssignmentItems}/$id/timeline',
        queryParameters: {'limit': 50},
      );

      final results = await Future.wait([itemReportsFuture, timelineFuture]);
      final List<TaskProgressReport> reports = List<TaskProgressReport>.from(results[0] as List<TaskProgressReport>);
      final response = results[1];

      developer.log("Get task timeline response: $response", name: "TaskService");

      List list = [];
      if (response != null) {
        if (response['data'] is List) {
          list = response['data'] as List;
        } else if (response['data'] is Map && response['data']['data'] is List) {
          list = response['data']['data'] as List;
        } else if (response['timeline'] is List) {
          list = response['timeline'] as List;
        }
      }

      final List<TaskDiscussionNote> discussions = [];

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final type = item['type']?.toString().toLowerCase() ?? '';
          final data = item['data'] is Map<String, dynamic> ? item['data'] as Map<String, dynamic> : null;

          // Phân loại tin nhắn trao đổi (type: "note", "comment", "discussion")
          if (type == 'note' || type == 'comment' || type == 'discussion') {
            discussions.add(TaskDiscussionNote.fromJson(item));
          }

          // Phân loại báo cáo tiến độ phụ trợ nếu endpoint itemReports chưa có
          final rawPercent = data?['percent'] ?? 
              data?['completion_percent'] ?? 
              data?['progress'] ?? 
              data?['new_percent'] ?? 
              item['percent'] ?? 
              item['completion_percent'];

          if (rawPercent != null || type.contains('progress') || type == 'report') {
            int parsedPercent = 0;
            if (rawPercent is num) {
              parsedPercent = rawPercent.toInt();
            } else if (rawPercent != null) {
              parsedPercent = int.tryParse(rawPercent.toString()) ?? 0;
            }

            final date = item['timestamp'] ?? item['created_at'] ?? item['date'] ?? data?['date'] ?? '';
            final note = data?['note'] ?? data?['content'] ?? data?['report_note'] ?? data?['comment'] ?? item['note'] ?? item['content'];
            final reporter = item['actor'] is Map ? item['actor']['name'] : (item['user'] is Map ? item['user']['name'] : item['actor']);

            if (parsedPercent > 0 || (note != null && type.contains('progress'))) {
              final exists = reports.any((r) => r.percent == parsedPercent && r.date == date.toString());
              if (!exists) {
                reports.add(TaskProgressReport(
                  percent: parsedPercent,
                  date: date.toString(),
                  note: note?.toString(),
                  reporterName: reporter?.toString(),
                ));
              }
            }
          }
        }
      }
      return (reports: reports, discussions: discussions);
    } catch (e) {
      developer.log("Error in repository getTaskTimelineData: $e", name: "TaskService");
    }
    return (reports: <TaskProgressReport>[], discussions: <TaskDiscussionNote>[]);
  }

  Future<dynamic> exportTasks({String? type, int? userId, String? keyword, String? status, String? timingStatus}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (type == 'received' && userId != null) {
        queryParams['assignee_id'] = userId;
        queryParams['user_id'] = userId;
      } else if (type == 'sent' && userId != null) {
        queryParams['assigner_id'] = userId;
        queryParams['created_by'] = userId;
      }
      
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['search'] = keyword;
      }
      if (status != null && status != 'all') {
        queryParams['processing_status'] = status;
      }
      if (timingStatus != null && timingStatus != 'all') {
        queryParams['timing_status'] = timingStatus;
      }

      final response = await _http.get(
        url: ApiConstants.taskExport,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return response;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('unauthorized') && !errorStr.contains('403')) {
        developer.log("Error in exportTasks: $e", name: "TaskService");
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
      developer.log("Error in repository deleteTask: $e", name: "TaskService");
      return false;
    }
  }

  Future<bool> bulkDeleteTasks(List<int> ids) async {
    try {
      final response = await _http.delete(
        url: ApiConstants.taskBulkDelete,
        data: {'ids': ids},
      );
      return response != null;
    } catch (e) {
      developer.log("Error in repository bulkDeleteTasks: $e", name: "TaskService");
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
      if (departmentId != null) {
        queryParams['department_id'] = departmentId;
      }
      if (type == 'received' && userId != null) {
        queryParams['assignee_id'] = userId;
      } else if (type == 'sent' && userId != null) {
        queryParams['assigner_id'] = userId;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await _http.get(
        url: ApiConstants.taskStats,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('unauthorized') && !errorStr.contains('403')) {
        developer.log("Error in repository getTaskStats: $e", name: "TaskService");
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
        url: ApiConstants.taskStatsByDepartment,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return response;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('unauthorized') && !errorStr.contains('403')) {
        developer.log("Error in repository getStatsByDepartment: $e", name: "TaskService");
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
        url: ApiConstants.taskStatsByItemType,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return response;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('unauthorized') && !errorStr.contains('403')) {
        developer.log("Error in repository getStatsByItemType: $e", name: "TaskService");
      }
      return null;
    }
  }

  Future<BaseResponse<TaskModel>?> createTask(Map<String, dynamic> data) async {
    try {
      developer.log("Payload create task: $data", name: "TaskService");
      final response = await _http.post(
        url: ApiConstants.taskAssignmentItems,
        data: data,
      );
      developer.log("Create task response: $response", name: "TaskService");

      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => TaskModel.fromJson(json is Map<String, dynamic> ? json : {}),
        );
      }
      return null;
    } catch (e) {
      developer.log("Error in repository createTask: $e", name: "TaskService");
      rethrow;
    }
  }

  Future<BaseResponse<TaskModel>?> updateTask(int id, Map<String, dynamic> data) async {
    try {
      final response = await _http.put(
        url: '${ApiConstants.taskAssignmentItems}/$id',
        data: data,
      );
      developer.log("Update task response: $response", name: "TaskService");
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => TaskModel.fromJson(json is Map<String, dynamic> ? json : {}),
        );
      }
      return null;
    } catch (e) {
      developer.log("Error in repository updateTask: $e", name: "TaskService");
      rethrow;
    }
  }

  Future<BaseResponse<List<TaskItemType>>?> getTaskItemTypes() async {
    try {
      final response = await _http.get(
        url: ApiConstants.taskAssignmentItemTypes,
      );
      developer.log("Get item types response: $response", name: "TaskService");
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
      developer.log("Error in repository getTaskItemTypes: $e", name: "TaskService");
      return null;
    }
  }

  Future<BaseResponse<List<TaskAssignmentDocument>>?> getTaskAssignmentDocuments() async {
    try {
      final response = await _http.get(
        url: ApiConstants.taskAssignmentDocuments,
      );
      developer.log("Get task assignment documents response: $response", name: "TaskService");
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
      developer.log("Error in repository getTaskAssignmentDocuments: $e", name: "TaskService");
      return null;
    }
  }

  Future<BaseResponse<List<DepartmentModel>>?> getTaskDepartments() async {
    try {
      final response = await _http.get(
        url: ApiConstants.taskAssignmentDepartments,
      );
      developer.log("Get task departments response: $response", name: "TaskService");
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
      developer.log("Error in repository getTaskDepartments: $e", name: "TaskService");
      return null;
    }
  }

  Future<BaseResponse<List<User>>?> getDepartmentUsers(int departmentId) async {
    try {
      final response = await _http.get(
        url: '${ApiConstants.taskAssignmentDepartments}/$departmentId/users',
      );
      developer.log("Get department $departmentId users response: $response", name: "TaskService");
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
      developer.log("Error in repository getDepartmentUsers: $e", name: "TaskService");
      return null;
    }
  }
}



