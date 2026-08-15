class TaskItemType {
  final int id;
  final String name;
  final String? code;

  TaskItemType({
    required this.id,
    required this.name,
    this.code,
  });

  factory TaskItemType.fromJson(Map<String, dynamic> json) {
    return TaskItemType(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      code: json['code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
  };
}

class TaskAssignmentDocument {
  final int id;
  final String name;
  final String? code;
  final String? documentNumber;

  TaskAssignmentDocument({
    required this.id,
    required this.name,
    this.code,
    this.documentNumber,
  });

  factory TaskAssignmentDocument.fromJson(Map<String, dynamic> json) {
    final title = json['name'] ?? json['title'] ?? json['document_number'] ?? json['subject'];
    return TaskAssignmentDocument(
      id: json['id'] as int? ?? 0,
      name: title?.toString() ?? 'Văn bản #${json['id']}',
      code: json['code']?.toString(),
      documentNumber: json['document_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "document_number": documentNumber,
  };
}

class TaskModel {
  final int id;
  final String name;
  final String description;
  final String deadlineType;
  final String? startAt;
  final String? endAt;
  final String processingStatus;
  final int completionPercent;
  final String priority;
  final bool isOverdue;
  final String timingStatus;
  final String createdAt;
  final int? taskAssignmentDocumentId;
  final int? taskAssignmentItemTypeId;
  final List<int>? assigneeIds;

  TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.deadlineType,
    this.startAt,
    this.endAt,
    required this.processingStatus,
    required this.completionPercent,
    required this.priority,
    required this.isOverdue,
    required this.timingStatus,
    required this.createdAt,
    this.taskAssignmentDocumentId,
    this.taskAssignmentItemTypeId,
    this.assigneeIds,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    List<int>? assignees;
    if (json['assignee_ids'] is List) {
      assignees = (json['assignee_ids'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();
    } else if (json['assignees'] is List) {
      assignees = (json['assignees'] as List).map((e) => e is Map ? (e['id'] as int? ?? 0) : (int.tryParse(e.toString()) ?? 0)).toList();
    }

    return TaskModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String? ?? json['content'] as String? ?? '',
      deadlineType: json['deadline_type'] as String? ?? 'no_deadline',
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
      processingStatus: json['processing_status'] as String? ?? 'todo',
      completionPercent: json['completion_percent'] as int? ?? 0,
      priority: json['priority'] as String? ?? 'medium',
      isOverdue: json['is_overdue'] as bool? ?? false,
      timingStatus: json['timing_status'] as String? ?? 'upcoming',
      createdAt: json['created_at'] as String? ?? '',
      taskAssignmentDocumentId: json['task_assignment_document_id'] as int? ?? json['document_id'] as int?,
      taskAssignmentItemTypeId: json['task_assignment_item_type_id'] as int? ?? json['type_id'] as int?,
      assigneeIds: assignees,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "deadline_type": deadlineType,
    "start_at": startAt,
    "end_at": endAt,
    "processing_status": processingStatus,
    "completion_percent": completionPercent,
    "priority": priority,
    "is_overdue": isOverdue,
    "timing_status": timingStatus,
    "created_at": createdAt,
    "task_assignment_document_id": taskAssignmentDocumentId,
    "task_assignment_item_type_id": taskAssignmentItemTypeId,
    "assignee_ids": assigneeIds,
  };
}

