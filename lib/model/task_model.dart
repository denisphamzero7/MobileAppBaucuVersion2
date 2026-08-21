export 'task_assignment_document_model.dart';

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

class TaskProgressReport {
  final int percent;
  final String date;
  final String? note;

  TaskProgressReport({
    required this.percent,
    required this.date,
    this.note,
  });

  factory TaskProgressReport.fromJson(Map<String, dynamic> json) {
    return TaskProgressReport(
      percent: (json['percent'] ?? json['completion_percent'] ?? json['progress'] ?? 0) as int,
      date: (json['date'] ?? json['created_at'] ?? json['submission_date'] ?? '').toString(),
      note: json['note']?.toString() ?? json['content']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'percent': percent,
    'date': date,
    'note': note,
  };
}

class TaskAttachment {
  final int? id;
  final String name;
  final String? url;
  final String? path;
  final String? size;

  TaskAttachment({
    this.id,
    required this.name,
    this.url,
    this.path,
    this.size,
  });

  factory TaskAttachment.fromJson(dynamic json) {
    if (json is String) {
      return TaskAttachment(name: json);
    }
    if (json is Map) {
      return TaskAttachment(
        id: json['id'] as int?,
        name: (json['name'] ?? json['file_name'] ?? json['title'] ?? '1.pdf').toString(),
        url: json['url']?.toString() ?? json['file_url']?.toString() ?? json['download_url']?.toString(),
        path: json['path']?.toString() ?? json['file_path']?.toString(),
        size: json['size']?.toString(),
      );
    }
    return TaskAttachment(name: json.toString());
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'path': path,
    'size': size,
  };
}

class TaskReminder {
  final String title;
  final String? detailTime;

  TaskReminder({
    required this.title,
    this.detailTime,
  });

  factory TaskReminder.fromJson(dynamic json) {
    if (json is String) {
      return TaskReminder(title: json);
    }
    if (json is Map) {
      return TaskReminder(
        title: (json['title'] ?? json['name'] ?? json['type'] ?? 'Tức thì').toString(),
        detailTime: json['detail_time']?.toString() ?? json['time']?.toString() ?? json['remind_at']?.toString(),
      );
    }
    return TaskReminder(title: json.toString());
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'detail_time': detailTime,
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
  final String? documentName;
  final String? itemTypeName;
  final String? assignerName;
  final String? assigneeName;
  final String? reminder;
  final List<dynamic>? attachments;
  final List<TaskAttachment>? attachmentList;
  final List<TaskReminder>? reminderList;
  final List<TaskProgressReport>? progressReports;
  final Map<String, dynamic>? rawJson;

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
    this.documentName,
    this.itemTypeName,
    this.assignerName,
    this.assigneeName,
    this.reminder,
    this.attachments,
    this.attachmentList,
    this.reminderList,
    this.progressReports,
    this.rawJson,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    List<int>? assignees;
    if (json['assignee_ids'] is List) {
      assignees = (json['assignee_ids'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();
    } else if (json['assignees'] is List) {
      assignees = (json['assignees'] as List).map((e) => e is Map ? (e['id'] as int? ?? 0) : (int.tryParse(e.toString()) ?? 0)).toList();
    }

    String? docName;
    if (json['document'] is Map) {
      docName = json['document']['name'] ?? json['document']['title'] ?? json['document']['document_number'];
    } else if (json['task_assignment_document'] is Map) {
      docName = json['task_assignment_document']['name'] ?? json['task_assignment_document']['title'];
    } else if (json['document_name'] != null) {
      docName = json['document_name']?.toString();
    }

    String? typeName;
    if (json['type'] is Map) {
      typeName = json['type']['name'] ?? json['type']['title'];
    } else if (json['task_assignment_item_type'] is Map) {
      typeName = json['task_assignment_item_type']['name'] ?? json['task_assignment_item_type']['title'];
    } else if (json['item_type_name'] != null) {
      typeName = json['item_type_name']?.toString();
    }

    String? assigner;
    if (json['assigner'] is Map) {
      assigner = json['assigner']['name'] ?? json['assigner']['user_name'] ?? json['assigner']['full_name'];
    } else if (json['assigned_by_user'] is Map) {
      assigner = json['assigned_by_user']['name'];
    } else if (json['assigner_name'] != null) {
      assigner = json['assigner_name']?.toString();
    }

    String? assignee;
    if (json['assignees'] is List && (json['assignees'] as List).isNotEmpty) {
      final names = (json['assignees'] as List).map((e) => e is Map ? (e['name'] ?? e['user_name'] ?? '').toString() : '').where((s) => s.isNotEmpty).toList();
      if (names.isNotEmpty) {
        assignee = names.join(', ');
      }
    } else if (json['assignee'] is Map) {
      assignee = json['assignee']['name'] ?? json['assignee']['user_name'];
    } else if (json['users'] is List && (json['users'] as List).isNotEmpty) {
      final names = (json['users'] as List).map((e) => e is Map ? (e['user'] is Map ? e['user']['name'] : e['name'])?.toString() ?? '' : '').where((s) => s.isNotEmpty).toList();
      if (names.isNotEmpty) {
        assignee = names.join(', ');
      }
    } else if (json['assignee_name'] != null) {
      assignee = json['assignee_name']?.toString();
    }

    // Trích xuất danh sách tệp đính kèm (từ item hoặc document gốc)
    List<dynamic>? attachs;
    if (json['attachments'] is List) {
      attachs = json['attachments'] as List;
    } else if (json['files'] is List) {
      attachs = json['files'] as List;
    } else if (json['document'] is Map && json['document']['attachments'] is List) {
      attachs = json['document']['attachments'] as List;
    } else if (json['task_assignment_document'] is Map && json['task_assignment_document']['attachments'] is List) {
      attachs = json['task_assignment_document']['attachments'] as List;
    }

    List<TaskAttachment> parsedAttachments = [];
    if (attachs != null && attachs.isNotEmpty) {
      parsedAttachments = attachs.map((e) => TaskAttachment.fromJson(e)).toList();
    }

    // Trích xuất danh sách nhắc lịch
    List<TaskReminder> parsedReminders = [];
    if (json['reminders'] is List) {
      parsedReminders = (json['reminders'] as List).map((e) => TaskReminder.fromJson(e)).toList();
    } else if (json['reminder_list'] is List) {
      parsedReminders = (json['reminder_list'] as List).map((e) => TaskReminder.fromJson(e)).toList();
    } else if (json['reminder'] != null && json['reminder'].toString().isNotEmpty) {
      parsedReminders = [TaskReminder(title: json['reminder'].toString())];
    }

    List<TaskProgressReport>? reports;
    if (json['progress_reports'] is List) {
      reports = (json['progress_reports'] as List).map((e) => TaskProgressReport.fromJson(e as Map<String, dynamic>)).toList();
    } else if (json['reports'] is List) {
      reports = (json['reports'] as List).map((e) => TaskProgressReport.fromJson(e as Map<String, dynamic>)).toList();
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
      documentName: docName,
      itemTypeName: typeName,
      assignerName: assigner,
      assigneeName: assignee,
      reminder: json['reminder']?.toString(),
      attachments: attachs,
      attachmentList: parsedAttachments,
      reminderList: parsedReminders,
      progressReports: reports,
      rawJson: json,
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
    "document_name": documentName,
    "item_type_name": itemTypeName,
    "assigner_name": assignerName,
    "assignee_name": assigneeName,
    "reminder": reminder,
  };
}
