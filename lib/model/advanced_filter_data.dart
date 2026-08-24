/// Class quản lý trạng thái và dữ liệu của Bộ lọc nâng cao (dùng chung cho Công việc và Đơn thư)
class AdvancedFilterData {
  final String priority; // 'all', 'urgent', 'high', 'medium', 'low'
  final String deadlineType; // 'all', 'has_deadline', 'no_deadline'
  final int? departmentId;
  final String? departmentName;
  final DateTime? fromDate;
  final DateTime? toDate;

  const AdvancedFilterData({
    this.priority = 'all',
    this.deadlineType = 'all',
    this.departmentId,
    this.departmentName,
    this.fromDate,
    this.toDate,
  });

  /// Kiểm tra xem có bất kỳ tiêu chí nào đang được kích hoạt khác mặc định không
  bool get isActive =>
      priority != 'all' ||
      deadlineType != 'all' ||
      departmentId != null ||
      fromDate != null ||
      toDate != null;

  /// Đếm số lượng tiêu chí lọc đang được kích hoạt
  int get activeCount {
    int count = 0;
    if (priority != 'all') count++;
    if (deadlineType != 'all') count++;
    if (departmentId != null) count++;
    if (fromDate != null || toDate != null) count++;
    return count;
  }

  AdvancedFilterData copyWith({
    String? priority,
    String? deadlineType,
    int? departmentId,
    String? departmentName,
    DateTime? fromDate,
    DateTime? toDate,
    bool clearDepartment = false,
    bool clearFromDate = false,
    bool clearToDate = false,
  }) {
    return AdvancedFilterData(
      priority: priority ?? this.priority,
      deadlineType: deadlineType ?? this.deadlineType,
      departmentId: clearDepartment ? null : (departmentId ?? this.departmentId),
      departmentName: clearDepartment ? null : (departmentName ?? this.departmentName),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
    );
  }

  /// Trả về trạng thái mặc định rỗng
  static const AdvancedFilterData initial = AdvancedFilterData();
}
