import '../core/api_constants.dart';
import '../helper/dio_helper.dart';
import '../model/base_response.dart';

class DepartmentModel {
  final int id;
  final String name;

  DepartmentModel({required this.id, required this.name});

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '').toString(),
    );
  }
}

class PetitionItemModel {
  final int id;
  final int? departmentId;
  final String departmentName;
  final String title;
  final String senderName;
  final String? senderAddress;
  final String? senderCccd;
  final String? senderPhone;
  final String? senderEmail;
  final String content;
  final String processingStatus; // 'new', 'processing', 'completed', 'paused', 'cancelled'
  final String submissionDate;
  final String deadlineDate;
  final String? completedAt;
  final String? documentNumber;
  final String? documentExcerpt;
  final String? responseContent;
  final List<dynamic>? attachments;
  final int completionPercent;
  final String timingStatus;
  final bool isOverdue;

  PetitionItemModel({
    required this.id,
    this.departmentId,
    required this.departmentName,
    required this.title,
    required this.senderName,
    this.senderAddress,
    this.senderCccd,
    this.senderPhone,
    this.senderEmail,
    required this.content,
    required this.processingStatus,
    required this.submissionDate,
    required this.deadlineDate,
    this.completedAt,
    this.documentNumber,
    this.documentExcerpt,
    this.responseContent,
    this.attachments,
    this.completionPercent = 0,
    this.timingStatus = 'upcoming',
    this.isOverdue = false,
  });

  factory PetitionItemModel.fromJson(Map<String, dynamic> json) {
    String deptName = '';
    if (json['department'] is Map) {
      deptName = json['department']['name']?.toString() ?? '';
    } else if (json['department_name'] != null) {
      deptName = json['department_name'].toString();
    }

    final pStatus = (json['processing_status'] ?? json['status'] ?? 'new').toString();
    final dDate = (json['deadline_date'] ?? json['deadline'] ?? json['end_at'] ?? '').toString();
    final cAt = json['completed_at']?.toString();

    int progress = json['completion_percent'] as int? ?? 0;
    if (progress == 0) {
      if (pStatus == 'completed' || pStatus == 'done') {
        progress = 100;
      } else if (pStatus == 'processing' || pStatus == 'in_progress') {
        progress = 50;
      } else if (pStatus == 'paused') {
        progress = 30;
      }
    }

    bool isOver = json['is_overdue'] as bool? ?? false;
    String timing = json['timing_status']?.toString() ?? 'upcoming';

    if (dDate.isNotEmpty) {
      try {
        final parsedDeadline = DateTime.tryParse(dDate);
        if (parsedDeadline != null) {
          final now = DateTime.now();
          if (pStatus == 'completed' || pStatus == 'done') {
            if (cAt != null && cAt.isNotEmpty) {
              final parsedCompleted = DateTime.tryParse(cAt);
              if (parsedCompleted != null) {
                if (parsedCompleted.isBefore(parsedDeadline)) {
                  timing = 'early';
                } else if (parsedCompleted.isAfter(parsedDeadline)) {
                  timing = 'late';
                } else {
                  timing = 'on_time';
                }
              } else {
                timing = 'on_time';
              }
            } else {
              timing = 'on_time';
            }
          } else {
            if (now.isAfter(parsedDeadline)) {
              isOver = true;
              timing = 'overdue';
            } else {
              timing = 'upcoming';
            }
          }
        }
      } catch (_) {}
    }

    return PetitionItemModel(
      id: (json['id'] ?? 0) as int,
      departmentId: json['department_id'] as int?,
      departmentName: deptName.isNotEmpty ? deptName : 'Chưa phân công',
      title: (json['title'] ?? json['subject'] ?? json['name'] ?? 'Đơn thư & Kiến nghị').toString(),
      senderName: (json['sender_name'] ?? json['petitioner'] ?? json['name'] ?? 'Công dân').toString(),
      senderAddress: json['sender_address']?.toString(),
      senderCccd: json['sender_cccd']?.toString(),
      senderPhone: json['sender_phone']?.toString(),
      senderEmail: json['sender_email']?.toString(),
      content: (json['content'] ?? json['description'] ?? json['body'] ?? '').toString(),
      processingStatus: pStatus,
      submissionDate: (json['submission_date'] ?? json['created_at'] ?? '').toString(),
      deadlineDate: dDate,
      completedAt: cAt,
      documentNumber: json['document_number']?.toString(),
      documentExcerpt: json['document_excerpt']?.toString(),
      responseContent: json['response_content']?.toString(),
      attachments: json['attachments'] is List ? json['attachments'] as List : null,
      completionPercent: progress,
      timingStatus: timing,
      isOverdue: isOver,
    );
  }
}

class PetitionStatsModel {
  final int total;
  final int todo; // new
  final int inProgress; // processing
  final int done; // completed
  final int paused;
  final int cancelled;

  PetitionStatsModel({
    this.total = 0,
    this.todo = 0,
    this.inProgress = 0,
    this.done = 0,
    this.paused = 0,
    this.cancelled = 0,
  });

  factory PetitionStatsModel.fromJson(Map<String, dynamic> json) {
    return PetitionStatsModel(
      total: ((json['total'] ?? json['total_count'] ?? 0) as num).toInt(),
      todo: ((json['new'] ?? json['todo'] ?? json['new_count'] ?? 0) as num).toInt(),
      inProgress: ((json['processing'] ?? json['in_progress'] ?? json['processing_count'] ?? 0) as num).toInt(),
      done: ((json['completed'] ?? json['done'] ?? json['completed_count'] ?? 0) as num).toInt(),
      paused: ((json['paused'] ?? json['paused_count'] ?? 0) as num).toInt(),
      cancelled: ((json['cancelled'] ?? json['cancelled_count'] ?? 0) as num).toInt(),
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
      return null;
    }
  }

  Future<BaseResponse<List<PetitionItemModel>>?> getPetitions({
    String? search,
    String? processingStatus,
    int? departmentId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
        'sort_by': 'submission_date',
        'sort_order': 'desc',
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (processingStatus != null && processingStatus != 'all') {
        queryParams['processing_status'] = processingStatus;
      }
      if (departmentId != null) queryParams['department_id'] = departmentId;

      final response = await _http.get(
        url: ApiConstants.taskAssignmentPetitions,
        queryParameters: queryParams,
      );
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
                .map((item) => PetitionItemModel.fromJson(item as Map<String, dynamic>))
                .toList();
          },
        );
      }
      return null;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('unauthorized') || errorStr.contains('403')) {
        return BaseResponse<List<PetitionItemModel>>(
          statusCode: 200,
          message: 'Không có quyền truy cập',
          data: [],
        );
      }
      return null;
    }
  }

  Future<PetitionStatsModel?> getPetitionStats() async {
    try {
      final response = await _http.get(
        url: ApiConstants.taskAssignmentPetitionsStats,
      );
      if (response != null && response is Map<String, dynamic>) {
        final data = response['data'] ?? response;
        if (data is Map<String, dynamic>) {
          return PetitionStatsModel.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<BaseResponse<PetitionItemModel>?> createPetition(Map<String, dynamic> data) async {
    try {
      final response = await _http.post(
        url: ApiConstants.taskAssignmentPetitions,
        data: data,
      );
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => PetitionItemModel.fromJson(json is Map<String, dynamic> ? json : {}),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponse<PetitionItemModel>?> updatePetition(int id, Map<String, dynamic> data) async {
    try {
      final response = await _http.put(
        url: '${ApiConstants.taskAssignmentPetitions}/$id',
        data: data,
      );
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) => PetitionItemModel.fromJson(json is Map<String, dynamic> ? json : {}),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePetition(int id) async {
    try {
      final response = await _http.delete(
        url: '${ApiConstants.taskAssignmentPetitions}/$id',
      );
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> bulkDeletePetitions(List<int> ids) async {
    try {
      final response = await _http.post(
        url: '${ApiConstants.taskAssignmentPetitions}/bulk-delete',
        data: {'ids': ids},
      );
      return response != null;
    } catch (e) {
      for (final id in ids) {
        await deletePetition(id);
      }
      return true;
    }
  }
}


