class ProfileData {
  final String id;
  final String name;
  final String email;
  final Role? role;
  final List<String> permissions;

  ProfileData({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    required this.permissions,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    var userJson = json['user'] as Map<String, dynamic>? ?? {};
    var rolesList = json['roles'] as List? ?? [];
    var permsList = json['permissions'] as List? ?? [];

    return ProfileData(
      id: (userJson['id'] ?? '').toString(),
      name: userJson['name'] as String? ?? 'Chưa cập nhật tên',
      email: userJson['email'] as String? ?? 'N/A',
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
}