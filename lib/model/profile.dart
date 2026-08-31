import '../core/enums/user_enums.dart';

class ProfileData {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final Role? role;
  final List<String> permissions;

  ProfileData({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role,
    required this.permissions,
  });

  UserRole get userRole => UserRole.fromKey(role?.name);

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    var userJson = json['user'] as Map<String, dynamic>? ?? {};
    var rolesList = json['roles'] as List? ?? [];
    var permsList = json['permissions'] as List? ?? [];

    return ProfileData(
      id: (userJson['id'] ?? '').toString(),
      name: userJson['name'] as String? ?? 'Chưa cập nhật tên',
      email: userJson['email'] as String? ?? 'N/A',
      avatar: userJson['avatar'] as String?,
      role: rolesList.isNotEmpty ? Role(name: rolesList.first.toString()) : null,
      permissions: permsList.map((item) => item.toString()).toList(),
    );
  }
}

class Role {
  final String name;

  Role({
    required this.name,
  });

  UserRole get roleEnum => UserRole.fromKey(name);
}