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
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      deadlineType: json['deadline_type'] as String? ?? 'no_deadline',
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
      processingStatus: json['processing_status'] as String? ?? 'todo',
      completionPercent: json['completion_percent'] as int? ?? 0,
      priority: json['priority'] as String? ?? 'medium',
      isOverdue: json['is_overdue'] as bool? ?? false,
      timingStatus: json['timing_status'] as String? ?? 'upcoming',
      createdAt: json['created_at'] as String? ?? '',
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
  };
}
