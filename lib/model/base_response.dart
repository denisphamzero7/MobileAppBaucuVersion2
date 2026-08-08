import 'dart:convert';

/// Lớp "vỏ" chung cho TẤT CẢ các phản hồi từ API
/// <T> là kiểu dữ liệu của trường "data" (ví dụ: RegisteredUserData, LoginData, List<Post>...)
class BaseResponse<T> {
  final int statusCode;
  final String message;
  final T data; // 'T' là kiểu dữ liệu của data (có thể là bất cứ gì)

  BaseResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  /// Factory constructor này nhận vào JSON và một hàm 'fromJsonT'
  /// Hàm 'fromJsonT' biết cách chuyển đổi JSON của "data" thành đối tượng <T>
  factory BaseResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJsonT, // Hàm để parse 'T'
      ) {
    return BaseResponse<T>(
      statusCode: json["statusCode"],
      message: json["message"],
      data: fromJsonT(json["data"]), // Dùng hàm fromJsonT để parse data
    );
  }
}
