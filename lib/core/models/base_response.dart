import 'pagination_meta.dart';

/// ============================================================================
/// 🏛️ [BaseResponse<T>] - KHUNG PHẢN HỒI API CHUẨN TOÀN HỆ THỐNG
/// ============================================================================
/// <T> là kiểu dữ liệu của trường "data" (ví dụ: RegisteredUserData, LoginData, List<Post>...)
class BaseResponse<T> {
  final int statusCode;
  final String message;
  final T data;
  final PaginationMeta? meta;
  final PaginationLinks? links;
  final bool success;

  BaseResponse({
    required this.statusCode,
    required this.message,
    required this.data,
    this.meta,
    this.links,
    this.success = true,
  });

  /// Factory constructor nhận vào JSON và một hàm `fromJsonT` để parse trường `data`
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final status = json['statusCode'] as int? ?? (json['success'] == true ? 200 : 400);
    final isSuccess = json['success'] as bool? ?? (status >= 200 && status < 300);

    return BaseResponse<T>(
      statusCode: status,
      message: json['message'] as String? ?? '',
      success: isSuccess,
      data: fromJsonT(json['data']),
      meta: json['meta'] != null ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>) : null,
      links: json['links'] != null ? PaginationLinks.fromJson(json['links'] as Map<String, dynamic>) : null,
    );
  }
}
