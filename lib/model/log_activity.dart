import 'package:flutter/material.dart';
import '../core/enums/log_activity_enums.dart';

class LogActivity {
  final int id;
  final String description;
  final String method;
  final String ipAddress;
  final String createdAt;

  LogActivity({
    required this.id,
    required this.description,
    required this.method,
    required this.ipAddress,
    required this.createdAt,
  });

  LogActivityMethod get methodEnum => LogActivityMethod.fromKey(method);
  Color get methodColor => methodEnum.color;
  IconData get methodIcon => methodEnum.icon;
  String get methodLabel => methodEnum.label;

  factory LogActivity.fromJson(Map<String, dynamic> json) => LogActivity(
    id: json["id"] as int? ?? 0,
    description: json["description"]?.toString() ?? '',
    method: json["method"]?.toString() ?? 'GET',
    ipAddress: json["ip_address"]?.toString() ?? '',
    createdAt: json["created_at"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "method": method,
    "ip_address": ipAddress,
    "created_at": createdAt,
  };
}
