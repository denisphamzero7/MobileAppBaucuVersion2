import 'package:flutter/material.dart';
import '../core/enums/notification_enums.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  NotificationType get typeEnum => NotificationType.fromKey(type);
  String get typeLabel => typeEnum.label;
  IconData get typeIcon => typeEnum.icon;
  Color get typeColor => typeEnum.color;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Thích ứng linh hoạt giữa NestJS (camelCase) và Laravel (snake_case)
    return NotificationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? json['isRead'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now()),
    );
  }
}