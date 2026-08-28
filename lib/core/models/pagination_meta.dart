/// ============================================================================
/// 📦 [PaginationMeta] & [PaginationLinks] - THÔNG TIN PHÂN TRANG CHUẨN API
/// ============================================================================
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from,
    this.to,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: 10,
        total: 0,
      );
    }
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? json['currentPage'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? json['lastPage'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? json['perPage'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      from: json['from'] as int?,
      to: json['to'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'from': from,
    'to': to,
  };

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPrevPage => currentPage > 1;
}

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({this.first, this.last, this.prev, this.next});

  factory PaginationLinks.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PaginationLinks();
    return PaginationLinks(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'first': first,
    'last': last,
    'prev': prev,
    'next': next,
  };
}
