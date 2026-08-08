import 'dart:convert';

// BƯỚC 1: LoginData
class LoginData {
  String accessToken;
  String refreshToken;
  User user;


  LoginData({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
    user: User.fromJson(json["user"]),
  );

  // --- THÊM HÀM NÀY ---
  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "refresh_token": refreshToken,
    "user": user.toJson(), // Gọi hàm toJson của User
  };
}

// BƯỚC 2: Role
class Role {
  String id;
  String name;

  Role({
    required this.id,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json["_id"], // Server trả về _id
    name: json["name"],
  );

  // --- THÊM HÀM NÀY ---
  Map<String, dynamic> toJson() => {
    "_id": id, // Khi lưu lại cũng giữ key là _id để đồng bộ
    "name": name,
  };
}

// BƯỚC 3: User
class User {
  String id;
  String email;
  Role? role;
  String name;
  String? status;

  User({
    required this.id,
    required this.email,
    this.role,
    required this.name,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"] ?? '',
    email: json["email"] ?? '',
    role: json["role"] != null ? Role.fromJson(json["role"] as Map<String, dynamic>) : null,
    name: json["name"] ?? '',
    status: json["status"],
  );

  // --- THÊM HÀM NÀY ---
  // Đây là hàm giúp sửa lỗi "The method 'toJson' isn't defined"
  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "role": role?.toJson(), // Gọi để biến Role thành Map
    "name": name,
    "status": status,
  };
}