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
