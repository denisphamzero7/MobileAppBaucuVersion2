import '../core/enums/user_enums.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String userName;
  final String avatar;
  final String lastLoginAt;
  final int? departmentId;
  final String? departmentRole;
  final String? assignmentRole;
  final Map<String, dynamic>? rawJson;

  User({
    required this.id,
    required this.name,
    this.email = '',
    this.userName = '',
    this.avatar = '',
    this.lastLoginAt = '',
    this.departmentId,
    this.departmentRole,
    this.assignmentRole,
    this.rawJson,
  });

  UserRole get roleEnum => UserRole.fromKey(departmentRole ?? assignmentRole);

  factory User.fromJson(Map<String, dynamic> json) {
    int? deptId = json["department_id"] as int?;
    if (deptId == null && json["department"] is Map) {
      deptId = json["department"]["id"] as int?;
    }
    if (deptId == null && json["departments"] is List && (json["departments"] as List).isNotEmpty) {
      final firstDept = (json["departments"] as List).first;
      if (firstDept is Map) {
        deptId = firstDept["id"] as int?;
      }
    }

    String? deptRole = json["department_role"]?.toString() ?? json["pivot"]?["department_role"]?.toString() ?? json["role"]?.toString();
    String? assignRole = json["assignment_role"]?.toString() ?? json["pivot"]?["assignment_role"]?.toString();

    return User(
      id: json["id"] as int? ?? 0,
      name: json["name"]?.toString() ?? '',
      email: json["email"]?.toString() ?? '',
      userName: json["user_name"]?.toString() ?? '',
      avatar: json["avatar"]?.toString() ?? '',
      lastLoginAt: json["last_login_at"]?.toString() ?? '',
      departmentId: deptId,
      departmentRole: deptRole,
      assignmentRole: assignRole,
      rawJson: json,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "user_name": userName,
    "avatar": avatar,
    "last_login_at": lastLoginAt,
    if (departmentId != null) "department_id": departmentId,
    if (departmentRole != null) "department_role": departmentRole,
    if (assignmentRole != null) "assignment_role": assignmentRole,
  };
}

