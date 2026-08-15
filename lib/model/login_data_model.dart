import 'user_model.dart';
import 'organization_model.dart';

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
      accessToken: (json["access_token"] ?? json["token"])?.toString() ?? '',
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
