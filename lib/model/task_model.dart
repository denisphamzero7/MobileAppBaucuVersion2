export 'task_assignment_document_model.dart';
import 'user_model.dart';

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
  final String? reporterName;

  TaskProgressReport({
    required this.percent,
    required this.date,
    this.note,
    this.reporterName,
  });

  factory TaskProgressReport.fromJson(Map<String, dynamic> json) {
    int parsedPercent = 0;
    final rawPercent = json['percent'] ?? json['completion_percent'] ?? json['progress'];
    if (rawPercent is num) {
      parsedPercent = rawPercent.toInt();
    } else if (rawPercent != null) {
      parsedPercent = int.tryParse(rawPercent.toString()) ?? 0;
    }

    return TaskProgressReport(
      percent: parsedPercent,
      date: (json['date'] ?? json['created_at'] ?? json['submission_date'] ?? json['report_date'] ?? '').toString(),
      note: json['note']?.toString() ?? json['content']?.toString() ?? json['report_note']?.toString() ?? json['description']?.toString(),
      reporterName: json['user']?['name']?.toString() ?? json['reporter']?['name']?.toString() ?? json['user_name']?.toString() ?? json['reporter_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'percent': percent,
    'date': date,
    'note': note,
    'reporter_name': reporterName,
  };
}

class TaskDiscussionNote {
  final int id;
  final String authorName;
  final String? authorAvatar;
  final String? authorRole;
  final String content;
  final String createdAt;

  TaskDiscussionNote({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    this.authorRole,
    required this.content,
    required this.createdAt,
  });

  factory TaskDiscussionNote.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final author = data['author'] is Map ? data['author'] : (json['actor'] is Map ? json['actor'] : null);
    return TaskDiscussionNote(
      id: json['id'] as int? ?? data['id'] as int? ?? 0,
      authorName: author?['name']?.toString() ?? json['actor']?['name']?.toString() ?? 'Người dùng',
      authorAvatar: author?['avatar']?.toString() ?? json['actor']?['avatar']?.toString(),
      authorRole: data['author_role']?.toString() ?? json['author_role']?.toString(),
      content: data['content']?.toString() ?? json['content']?.toString() ?? '',
      createdAt: data['created_at']?.toString() ?? json['timestamp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author_name': authorName,
    'author_avatar': authorAvatar,
    'author_role': authorRole,
    'content': content,
    'created_at': createdAt,
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
  final List<TaskDiscussionNote>? discussions;
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
    this.discussions,
    this.rawJson,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    List<int> assignees = [];
    if (json['assignee_ids'] is List) {
      assignees = (json['assignee_ids'] as List)
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((id) => id > 0)
          .toList();
    } else if (json['assignees'] is List) {
      assignees = (json['assignees'] as List)
          .map((e) => e is Map
              ? (int.tryParse((e['id'] ?? e['user_id'])?.toString() ?? '0') ?? 0)
              : (int.tryParse(e.toString()) ?? 0))
          .where((id) => id > 0)
          .toList();
    } else if (json['users'] is List) {
      assignees = (json['users'] as List)
          .map((e) => e is Map
              ? (int.tryParse((e['id'] ?? e['user_id'] ?? (e['user'] is Map ? e['user']['id'] : null))?.toString() ?? '0') ?? 0)
              : (int.tryParse(e.toString()) ?? 0))
          .where((id) => id > 0)
          .toList();
    }
    if (json['assignee_id'] != null) {
      final aId = int.tryParse(json['assignee_id'].toString());
      if (aId != null && aId > 0 && !assignees.contains(aId)) assignees.add(aId);
    }
    if (json['assignee'] is Map && json['assignee']['id'] != null) {
      final aId = int.tryParse(json['assignee']['id'].toString());
      if (aId != null && aId > 0 && !assignees.contains(aId)) assignees.add(aId);
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
    } else if (json['item_type'] is Map) {
      typeName = json['item_type']['name'] ?? json['item_type']['title'];
    } else if (json['task_assignment_item_type'] is Map) {
      typeName = json['task_assignment_item_type']['name'] ?? json['task_assignment_item_type']['title'];
    } else if (json['item_type_name'] != null) {
      typeName = json['item_type_name']?.toString();
    }

    String? assigner;
    if (json['assigner'] is Map) {
      assigner = json['assigner']['name'] ?? json['assigner']['user_name'] ?? json['assigner']['full_name'];
    } else if (json['assigned_by_user'] is Map) {
      assigner = json['assigned_by_user']['name'] ?? json['assigned_by_user']['user_name'];
    } else if (json['creator'] is Map) {
      assigner = json['creator']['name'] ?? json['creator']['user_name'];
    } else if (json['user'] is Map) {
      assigner = json['user']['name'] ?? json['user']['user_name'];
    } else if (json['created_by_user'] is Map) {
      assigner = json['created_by_user']['name'];
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
    final dynamic rawReports = json['progress_reports'] ?? 
        json['reports'] ?? 
        json['task_progress_reports'] ?? 
        json['task_reports'] ?? 
        json['progress_report_list'] ?? 
        json['histories'] ?? 
        json['task_histories'];
    if (rawReports is List) {
      reports = rawReports
          .whereType<Map<String, dynamic>>()
          .map((e) => TaskProgressReport.fromJson(e))
          .toList();
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

  TaskModel copyWith({
    int? id,
    String? name,
    String? description,
    String? deadlineType,
    String? startAt,
    String? endAt,
    String? processingStatus,
    int? completionPercent,
    String? priority,
    bool? isOverdue,
    String? timingStatus,
    String? createdAt,
    int? taskAssignmentDocumentId,
    int? taskAssignmentItemTypeId,
    List<int>? assigneeIds,
    String? documentName,
    String? itemTypeName,
    String? assignerName,
    String? assigneeName,
    String? reminder,
    List<dynamic>? attachments,
    List<TaskAttachment>? attachmentList,
    List<TaskReminder>? reminderList,
    List<TaskProgressReport>? progressReports,
    List<TaskDiscussionNote>? discussions,
    Map<String, dynamic>? rawJson,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      deadlineType: deadlineType ?? this.deadlineType,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      processingStatus: processingStatus ?? this.processingStatus,
      completionPercent: completionPercent ?? this.completionPercent,
      priority: priority ?? this.priority,
      isOverdue: isOverdue ?? this.isOverdue,
      timingStatus: timingStatus ?? this.timingStatus,
      createdAt: createdAt ?? this.createdAt,
      taskAssignmentDocumentId: taskAssignmentDocumentId ?? this.taskAssignmentDocumentId,
      taskAssignmentItemTypeId: taskAssignmentItemTypeId ?? this.taskAssignmentItemTypeId,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      documentName: documentName ?? this.documentName,
      itemTypeName: itemTypeName ?? this.itemTypeName,
      assignerName: assignerName ?? this.assignerName,
      assigneeName: assigneeName ?? this.assigneeName,
      reminder: reminder ?? this.reminder,
      attachments: attachments ?? this.attachments,
      attachmentList: attachmentList ?? this.attachmentList,
      reminderList: reminderList ?? this.reminderList,
      progressReports: progressReports ?? this.progressReports,
      discussions: discussions ?? this.discussions,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  /// 🔍 Kiểm tra xem [user] có phải là NGƯỜI GIAO VIỆC (Đang giao) hay không
  bool isAssignedByMe(User? user) {
    if (user == null) return false;

    final raw = rawJson ?? {};
    final uId = user.id.toString();
    final uName = user.name.trim().toLowerCase();
    final uUserName = user.userName.trim().toLowerCase();
    final uEmail = user.email.trim().toLowerCase();

    // 1. Kiểm tra theo ID người tạo / người giao
    if (user.id > 0) {
      final assignerId = raw['assigner_id'] ?? raw['created_by'] ?? raw['assigned_by'] ?? raw['user_id'];
      if (assignerId != null && assignerId.toString() == uId) return true;
      if (raw['assigner'] is Map && (raw['assigner']['id'] ?? raw['assigner']['user_id'])?.toString() == uId) return true;
      if (raw['creator'] is Map && (raw['creator']['id'] ?? raw['creator']['user_id'])?.toString() == uId) return true;
      if (raw['user'] is Map && (raw['user']['id'] ?? raw['user']['user_id'])?.toString() == uId) return true;
      if (raw['assigned_by_user'] is Map && (raw['assigned_by_user']['id'] ?? raw['assigned_by_user']['user_id'])?.toString() == uId) return true;
    }

    // 2. Kiểm tra theo Tên / Username / Email của người giao
    if (assignerName != null && assignerName!.trim().isNotEmpty) {
      final aName = assignerName!.trim().toLowerCase();
      if (uName.isNotEmpty && (aName.contains(uName) || uName.contains(aName))) return true;
      if (uUserName.isNotEmpty && (aName.contains(uUserName) || uUserName.contains(aName))) return true;
    }
    if (raw['assigner'] is Map) {
      final a = raw['assigner'];
      final name = (a['name'] ?? a['user_name'] ?? a['full_name'] ?? '').toString().trim().toLowerCase();
      if (uName.isNotEmpty && name.isNotEmpty && (name.contains(uName) || uName.contains(name))) return true;
      if (uUserName.isNotEmpty && name.isNotEmpty && (name.contains(uUserName) || uUserName.contains(name))) return true;
      final email = (a['email'] ?? '').toString().trim().toLowerCase();
      if (uEmail.isNotEmpty && email.isNotEmpty && email == uEmail) return true;
    }
    if (raw['creator'] is Map) {
      final c = raw['creator'];
      final name = (c['name'] ?? c['user_name'] ?? c['full_name'] ?? '').toString().trim().toLowerCase();
      if (uName.isNotEmpty && name.isNotEmpty && (name.contains(uName) || uName.contains(name))) return true;
      final email = (c['email'] ?? '').toString().trim().toLowerCase();
      if (uEmail.isNotEmpty && email.isNotEmpty && email == uEmail) return true;
    }

    return false;
  }

  /// 🔍 Kiểm tra xem [user] có phải là NGƯỜI ĐƯỢC GIAO VIỆC (Được giao) hay không
  bool isAssignedToMe(User? user) {
    if (user == null) return false;

    final raw = rawJson ?? {};
    final uId = user.id.toString();
    final uName = user.name.trim().toLowerCase();
    final uUserName = user.userName.trim().toLowerCase();
    final uEmail = user.email.trim().toLowerCase();

    // 1. Kiểm tra theo ID người nhận
    if (user.id > 0) {
      if (assigneeIds != null && assigneeIds!.contains(user.id)) return true;
      if (raw['assignee_id'] != null && raw['assignee_id'].toString() == uId) return true;
      if (raw['assignee'] is Map && (raw['assignee']['id'] ?? raw['assignee']['user_id'])?.toString() == uId) return true;
      if (raw['users'] is List) {
        final hasUser = (raw['users'] as List).any((u) {
          if (u is Map) {
            final id = (u['id'] ?? u['user_id'] ?? (u['user'] is Map ? u['user']['id'] : null))?.toString();
            return id != null && id == uId;
          }
          return u.toString() == uId;
        });
        if (hasUser) return true;
      }
      if (raw['assignees'] is List) {
        final hasAssignee = (raw['assignees'] as List).any((u) {
          if (u is Map) {
            final id = (u['id'] ?? u['user_id'] ?? (u['user'] is Map ? u['user']['id'] : null))?.toString();
            return id != null && id == uId;
          }
          return u.toString() == uId;
        });
        if (hasAssignee) return true;
      }
    }

    // 2. Kiểm tra theo Tên / Username / Email của người nhận
    if (assigneeName != null && assigneeName!.trim().isNotEmpty) {
      final aName = assigneeName!.trim().toLowerCase();
      if (uName.isNotEmpty && (aName.contains(uName) || uName.contains(aName))) return true;
      if (uUserName.isNotEmpty && (aName.contains(uUserName) || uUserName.contains(aName))) return true;
    }
    if (raw['assignee'] is Map) {
      final a = raw['assignee'];
      final name = (a['name'] ?? a['user_name'] ?? '').toString().trim().toLowerCase();
      if (uName.isNotEmpty && name.isNotEmpty && (name.contains(uName) || uName.contains(name))) return true;
      final email = (a['email'] ?? '').toString().trim().toLowerCase();
      if (uEmail.isNotEmpty && email.isNotEmpty && email == uEmail) return true;
    }
    if (raw['users'] is List) {
      final hasNameOrEmail = (raw['users'] as List).any((u) {
        if (u is Map) {
          final name = (u['name'] ?? u['user_name'] ?? (u['user'] is Map ? u['user']['name'] : null) ?? '').toString().trim().toLowerCase();
          if (uName.isNotEmpty && name.isNotEmpty && (name.contains(uName) || uName.contains(name))) return true;
          final email = (u['email'] ?? (u['user'] is Map ? u['user']['email'] : null) ?? '').toString().trim().toLowerCase();
          if (uEmail.isNotEmpty && email.isNotEmpty && email == uEmail) return true;
        }
        return false;
      });
      if (hasNameOrEmail) return true;
    }

    return false;
  }
}
