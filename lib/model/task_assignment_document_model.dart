import 'package:flutter/material.dart';
import '../core/enums/task_document_enums.dart';

class TaskAssignmentDocumentModel {
  final int id;
  final String title;
  final String? code;
  final String? documentNumber;
  final String? typeName;
  final String status; // 'published' (Đã ban hành) or 'draft' (Bản nháp)
  final String? documentDate;
  final int taskCount;
  final int completionPercent;
  final String? description;
  final int? departmentId;
  final String? departmentName;
  final List<dynamic>? attachments;

  TaskAssignmentDocumentModel({
    required this.id,
    required this.title,
    this.code,
    this.documentNumber,
    this.typeName,
    this.status = 'published',
    this.documentDate,
    this.taskCount = 0,
    this.completionPercent = 0,
    this.description,
    this.departmentId,
    this.departmentName,
    this.attachments,
  });

  TaskDocumentStatus get documentStatus =>
      TaskDocumentStatus.fromKey(status, fallback: TaskDocumentStatus.published);

  String get statusLabel => documentStatus.label;
  Color get statusColor => documentStatus.color;
  IconData get statusIcon => documentStatus.icon;

  bool get isPublished => documentStatus.isPublished;
  bool get isDraft => documentStatus.isDraft;
  String get name => title;

  factory TaskAssignmentDocumentModel.fromJson(Map<String, dynamic> json) {
    final titleStr = json['title'] ?? json['name'] ?? json['subject'] ?? json['document_number'] ?? 'Văn bản #${json['id']}';
    
    // Status resolution via Enum
    final resolvedEnum = TaskDocumentStatus.fromKey(
      json['status']?.toString() ?? json['processing_status']?.toString() ?? json['state']?.toString(),
      fallback: TaskDocumentStatus.published,
    );
    final rawStatus = resolvedEnum.key;

    // Task count resolution
    int tCount = 0;
    if (json['task_count'] != null) {
      tCount = (json['task_count'] as num).toInt();
    } else if (json['tasks_count'] != null) {
      tCount = (json['tasks_count'] as num).toInt();
    } else if (json['items_count'] != null) {
      tCount = (json['items_count'] as num).toInt();
    } else if (json['tasks'] is List) {
      tCount = (json['tasks'] as List).length;
    } else if (json['items'] is List) {
      tCount = (json['items'] as List).length;
    }

    // Completion percent resolution
    int percent = 0;
    if (json['completion_percent'] != null) {
      percent = (json['completion_percent'] as num).toInt();
    } else if (json['progress'] != null) {
      percent = (json['progress'] as num).toInt();
    } else if (json['progress_percent'] != null) {
      percent = (json['progress_percent'] as num).toInt();
    }

    // Type resolution
    String? type = json['type_name']?.toString() ?? json['document_type_name']?.toString() ?? json['category_name']?.toString();
    if (type == null || type.isEmpty) {
      if (json['document_type'] is Map) {
        type = json['document_type']['name']?.toString();
      } else if (json['category'] is Map) {
        type = json['category']['name']?.toString();
      }
    }

    // Date resolution
    String? dateStr = json['document_date']?.toString() ?? json['issued_date']?.toString() ?? json['signing_date']?.toString() ?? json['created_at']?.toString() ?? json['date']?.toString();

    // Department resolution
    String? dept;
    if (json['department_name'] != null) {
      dept = json['department_name']?.toString();
    } else if (json['department'] is Map) {
      dept = json['department']['name']?.toString();
    }

    return TaskAssignmentDocumentModel(
      id: (json['id'] ?? 0) as int,
      title: titleStr.toString(),
      code: json['code']?.toString(),
      documentNumber: json['document_number']?.toString(),
      typeName: type ?? 'Văn bản',
      status: rawStatus,
      documentDate: dateStr,
      taskCount: tCount,
      completionPercent: percent,
      description: (json['description'] ?? json['content'] ?? json['excerpt'] ?? '').toString(),
      departmentId: json['department_id'] as int?,
      departmentName: dept,
      attachments: json['attachments'] is List ? json['attachments'] as List : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "code": code,
    "document_number": documentNumber,
    "type_name": typeName,
    "status": status,
    "document_date": documentDate,
    "task_count": taskCount,
    "completion_percent": completionPercent,
    "description": description,
    "department_id": departmentId,
    "department_name": departmentName,
  };
}

class TaskAssignmentDocumentStatsModel {
  final int total;
  final int published;
  final int draft;

  TaskAssignmentDocumentStatsModel({
    this.total = 0,
    this.published = 0,
    this.draft = 0,
  });

  factory TaskAssignmentDocumentStatsModel.fromJson(Map<String, dynamic> json) {
    return TaskAssignmentDocumentStatsModel(
      total: ((json['total'] ?? json['total_count'] ?? 0) as num).toInt(),
      published: ((json['published'] ?? json['issued'] ?? json['active'] ?? json['published_count'] ?? 0) as num).toInt(),
      draft: ((json['draft'] ?? json['draft_count'] ?? json['pending'] ?? 0) as num).toInt(),
    );
  }
}

typedef TaskAssignmentDocument = TaskAssignmentDocumentModel;
