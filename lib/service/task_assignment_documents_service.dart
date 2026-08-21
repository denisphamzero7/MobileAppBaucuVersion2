import '../core/api_constants.dart';
import '../helper/dio_helper.dart';
import '../model/base_response.dart';
import '../model/task_assignment_document_model.dart';
import '../model/department_model.dart';

class TaskAssignmentDocumentsService {
  final DioHelper _http = DioHelper();

  Future<BaseResponse<List<DepartmentModel>>?> getAvailableDepartments() async {
    try {
      final response = await _http.get(
        url: ApiConstants.taskAssignmentPetitionsDepartments,
      );
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) {
            if (json is List) {
              return json.map((e) => DepartmentModel.fromJson(e as Map<String, dynamic>)).toList();
            }
            return [];
          },
        );
      }
    } catch (_) {}
    return null;
  }

  Future<BaseResponse<List<TaskAssignmentDocumentModel>>?> getDocuments({
    int page = 1,
    int perPage = 10,
    String? search,
    String? status,
    int? departmentId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final Map<String, dynamic> query = {
        'page': page,
        'per_page': perPage,
      };

      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        query['status'] = status;
      }
      if (departmentId != null) {
        query['department_id'] = departmentId;
      }
      if (fromDate != null && fromDate.isNotEmpty) {
        query['from_date'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        query['to_date'] = toDate;
      }

      final response = await _http.get(
        url: ApiConstants.taskAssignmentDocuments,
        queryParameters: query,
      );

      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) {
            if (json is List) {
              return json.map((e) => TaskAssignmentDocumentModel.fromJson(e as Map<String, dynamic>)).toList();
            }
            return [];
          },
        );
      }
    } catch (_) {}
    return null;
  }

  Future<BaseResponse<TaskAssignmentDocumentStatsModel>?> getStats({
    int? departmentId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final Map<String, dynamic> query = {};
      if (departmentId != null) query['department_id'] = departmentId;
      if (fromDate != null && fromDate.isNotEmpty) query['from_date'] = fromDate;
      if (toDate != null && toDate.isNotEmpty) query['to_date'] = toDate;

      final response = await _http.get(
        url: '${ApiConstants.taskAssignmentDocuments}/stats',
        queryParameters: query.isNotEmpty ? query : null,
      );

      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => TaskAssignmentDocumentStatsModel.fromJson(json as Map<String, dynamic>),
        );
      }
    } catch (_) {}
    return null;
  }

  Future<BaseResponse<TaskAssignmentDocumentModel>?> getDocumentDetail(int id) async {
    try {
      final response = await _http.get(
        url: '${ApiConstants.taskAssignmentDocuments}/$id',
      );
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => TaskAssignmentDocumentModel.fromJson(json as Map<String, dynamic>),
        );
      }
    } catch (_) {}
    return null;
  }

  Future<BaseResponse<TaskAssignmentDocumentModel>?> createDocument(Map<String, dynamic> data) async {
    try {
      final response = await _http.post(
        url: ApiConstants.taskAssignmentDocuments,
        data: data,
      );
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => TaskAssignmentDocumentModel.fromJson(json as Map<String, dynamic>),
        );
      }
    } catch (_) {}
    return null;
  }

  Future<BaseResponse<TaskAssignmentDocumentModel>?> updateDocument(int id, Map<String, dynamic> data) async {
    try {
      final response = await _http.put(
        url: '${ApiConstants.taskAssignmentDocuments}/$id',
        data: data,
      );
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => TaskAssignmentDocumentModel.fromJson(json as Map<String, dynamic>),
        );
      }
    } catch (_) {}
    return null;
  }

  Future<bool> deleteDocument(int id) async {
    try {
      final response = await _http.delete(
        url: '${ApiConstants.taskAssignmentDocuments}/$id',
      );
      return response != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> bulkDeleteDocuments(List<int> ids) async {
    try {
      final response = await _http.post(
        url: '${ApiConstants.taskAssignmentDocuments}/bulk-delete',
        data: {'ids': ids},
      );
      return response != null;
    } catch (_) {
      return false;
    }
  }
}