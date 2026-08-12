// BƯỚC 1: Organization
class Organization {
  final int id;
  final String name;

  Organization({
    required this.id,
    required this.name,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    id: json["id"] as int? ?? 0,
    name: json["name"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

// BƯỚC 2: User
class User {
  final int id;
  final String name;
  final String email;
  final String userName;
  final String avatar;
  final String lastLoginAt;

  User({
    required this.id,
    required this.name,
    this.email = '',
    this.userName = '',
    this.avatar = '',
    this.lastLoginAt = '',
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] as int? ?? 0,
    name: json["name"]?.toString() ?? '',
    email: json["email"]?.toString() ?? '',
    userName: json["user_name"]?.toString() ?? '',
    avatar: json["avatar"]?.toString() ?? '',
    lastLoginAt: json["last_login_at"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "user_name": userName,
    "avatar": avatar,
    "last_login_at": lastLoginAt,
  };
}

// BƯỚC 3: LoginData
class LoginData {
  final String accessToken;
  final String tokenType;
  final User user;
  final List<Organization> availableOrganizations;
  final int? currentOrganizationId;
  final List<String> roles;
  final List<String> permissions;
  final List<Map<String, dynamic>> abilities;

  LoginData({
    required this.accessToken,
    required this.tokenType,
    required this.user,
    required this.availableOrganizations,
    this.currentOrganizationId,
    required this.roles,
    required this.permissions,
    required this.abilities,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    var orgsList = json["available_organizations"] as List? ?? [];
    var rolesList = json["roles"] as List? ?? [];
    var permsList = json["permissions"] as List? ?? [];

    return LoginData(
      accessToken: json["access_token"]?.toString() ?? '',
      tokenType: json["token_type"]?.toString() ?? 'Bearer',
      user: User.fromJson(json["user"] as Map<String, dynamic>? ?? {}),
      availableOrganizations: orgsList.map((x) => Organization.fromJson(x as Map<String, dynamic>)).toList(),
      currentOrganizationId: json["current_organization_id"] as int?,
      roles: rolesList.map((x) => x.toString()).toList(),
      permissions: permsList.map((x) => x.toString()).toList(),
      abilities: json["abilities"] != null ? List<Map<String, dynamic>>.from(json["abilities"]) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "token_type": tokenType,
    "user": user.toJson(),
    "available_organizations": availableOrganizations.map((x) => x.toJson()).toList(),
    "current_organization_id": currentOrganizationId,
    "roles": roles,
    "permissions": permissions,
    "abilities": abilities,
  };
}