import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/advanced_filter_data.dart';
import '../../model/department_model.dart';
import '../../untils/app_colors.dart';
import '../../untils/app_textstyles.dart';
import 'app_priority_indicator.dart';

/// ============================================================================
/// 🎯 [AppAdvancedFilterBottomSheet] - BỘ LỌC NÂNG CAO TÁI SỬ DỤNG
/// ============================================================================
/// Dùng chung cho:
/// 1. Công việc đang giao (Task Sent)
/// 2. Công việc được giao (Task Received)
/// 3. Quản lý đơn thư (Petition Management)
class AppAdvancedFilterBottomSheet extends StatefulWidget {
  final AdvancedFilterData initialData;
  final List<DepartmentModel> departments;
  final bool showPriority;
  final bool showDeadlineType;
  final bool showDepartment;
  final bool showDateRange;
  final ValueChanged<AdvancedFilterData> onApply;
  final VoidCallback? onReset;

  const AppAdvancedFilterBottomSheet({
    super.key,
    required this.initialData,
    this.departments = const [],
    this.showPriority = true,
    this.showDeadlineType = true,
    this.showDepartment = true,
    this.showDateRange = true,
    required this.onApply,
    this.onReset,
  });

  /// Hàm tiện ích mở BottomSheet
  static Future<AdvancedFilterData?> show(
    BuildContext context, {
    required AdvancedFilterData initialData,
    List<DepartmentModel> departments = const [],
    bool showPriority = true,
    bool showDeadlineType = true,
    bool showDepartment = true,
    bool showDateRange = true,
    required ValueChanged<AdvancedFilterData> onApply,
    VoidCallback? onReset,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showModalBottomSheet<AdvancedFilterData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppAdvancedFilterBottomSheet(
        initialData: initialData,
        departments: departments,
        showPriority: showPriority,
        showDeadlineType: showDeadlineType,
        showDepartment: showDepartment,
        showDateRange: showDateRange,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  @override
  State<AppAdvancedFilterBottomSheet> createState() =>
      _AppAdvancedFilterBottomSheetState();
}

class _AppAdvancedFilterBottomSheetState
    extends State<AppAdvancedFilterBottomSheet> {
  late String _selectedPriority;
  late String _selectedDeadlineType;
  int? _selectedDepartmentId;
  String? _selectedDepartmentName;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.initialData.priority;
    _selectedDeadlineType = widget.initialData.deadlineType;
    _selectedDepartmentId = widget.initialData.departmentId;
    _selectedDepartmentName = widget.initialData.departmentName;
    _fromDate = widget.initialData.fromDate;
    _toDate = widget.initialData.toDate;
  }

  void _handleReset() {
    setState(() {
      _selectedPriority = 'all';
      _selectedDeadlineType = 'all';
      _selectedDepartmentId = null;
      _selectedDepartmentName = null;
      _fromDate = null;
      _toDate = null;
    });
  }

  void _handleApply() {
    final result = AdvancedFilterData(
      priority: _selectedPriority,
      deadlineType: _selectedDeadlineType,
      departmentId: _selectedDepartmentId,
      departmentName: _selectedDepartmentName,
      fromDate: _fromDate,
      toDate: _toDate,
    );
    widget.onApply(result);
    Navigator.of(context).pop(result);
  }

  void _setShortcutDateRange(String type) {
    final now = DateTime.now();
    setState(() {
      if (type == 'today') {
        _fromDate = DateTime(now.year, now.month, now.day);
        _toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else if (type == 'week') {
        // Đầu tuần (Thứ 2) đến cuối tuần (Chủ nhật)
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
        _fromDate = DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
        _toDate = _fromDate!.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      } else if (type == 'month') {
        _fromDate = DateTime(now.year, now.month, 1);
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        _toDate = nextMonth.subtract(const Duration(seconds: 1));
      } else if (type == 'last30') {
        _fromDate = now.subtract(const Duration(days: 30));
        _toDate = now;
      }
    });
  }

  Future<void> _pickDate({required bool isFromDate}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initialDate = isFromDate
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? _fromDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.cardDark,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
            _toDate = _fromDate;
          }
        } else {
          _toDate = picked;
          if (_fromDate != null && _fromDate!.isAfter(_toDate!)) {
            _fromDate = _toDate;
          }
        }
      });
    }
  }

  int get _currentActiveCount {
    int count = 0;
    if (_selectedPriority != 'all') count++;
    if (_selectedDeadlineType != 'all') count++;
    if (_selectedDepartmentId != null) count++;
    if (_fromDate != null || _toDate != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. THANH KÉO (DRAG HANDLE) & TIÊU ĐỀ HEADER
          _buildHeader(isDark),

          const Divider(height: 1, color: AppColors.black12),

          // 2. NỘI DUNG BỘ LỌC CUỘN ĐƯỢC
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: MỨC ĐỘ ƯU TIÊN ---
                  if (widget.showPriority) ...[
                    _buildSectionTitle(
                      title: 'Mức độ ưu tiên',
                      icon: Icons.flag_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildPriorityFilter(isDark),
                    const SizedBox(height: 20),
                  ],

                  // --- SECTION 2: LOẠI THỜI HẠN ---
                  if (widget.showDeadlineType) ...[
                    _buildSectionTitle(
                      title: 'Loại thời hạn',
                      icon: Icons.timer_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildDeadlineTypeFilter(isDark),
                    const SizedBox(height: 20),
                  ],

                  // --- SECTION 3: PHÒNG BAN THỰC HIỆN ---
                  if (widget.showDepartment && widget.departments.isNotEmpty) ...[
                    _buildSectionTitle(
                      title: 'Phòng ban thực hiện',
                      icon: Icons.apartment_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildDepartmentFilter(isDark),
                    const SizedBox(height: 20),
                  ],

                  // --- SECTION 4: KHOẢNG THỜI GIAN ---
                  if (widget.showDateRange) ...[
                    _buildSectionTitle(
                      title: 'Khoảng thời gian',
                      icon: Icons.calendar_month_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildDateShortcuts(isDark),
                    const SizedBox(height: 10),
                    _buildDateRangePickers(isDark),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.black12),

          // 3. FOOTER NÚT ÁP DỤNG & THIẾT LẬP LẠI
          _buildFooter(isDark),
        ],
      ),
    );
  }

  /// Header Top Bar
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.white24 : AppColors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Bộ lọc nâng cao',
                style: AppTextStyle.cardTitle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppColors.white : AppColors.black87,
                ),
              ),
              if (_currentActiveCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_currentActiveCount',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Nút đặt lại nhanh
              if (_currentActiveCount > 0)
                TextButton(
                  onPressed: _handleReset,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Đặt lại',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: isDark ? AppColors.white70 : AppColors.grey[600],
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tiêu đề từng nhóm bộ lọc
  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: isDark ? AppColors.white70 : AppColors.grey[700]),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.black87,
          ),
        ),
      ],
    );
  }

  /// 1. Bộ lọc Mức độ ưu tiên
  Widget _buildPriorityFilter(bool isDark) {
    final priorities = [
      {'key': 'all', 'label': 'Tất cả', 'color': AppColors.grey},
      {'key': 'urgent', 'label': 'Khẩn cấp', 'color': AppColors.priorityUrgent},
      {'key': 'high', 'label': 'Cao', 'color': AppColors.priorityHigh},
      {'key': 'medium', 'label': 'Trung bình', 'color': AppColors.priorityMedium},
      {'key': 'low', 'label': 'Thấp', 'color': AppColors.priorityLow},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: priorities.map((p) {
        final key = p['key'] as String;
        final label = p['label'] as String;
        final color = p['color'] as Color;
        final isSelected = _selectedPriority == key;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _selectedPriority = key;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: isDark ? 0.25 : 0.12)
                  : (isDark ? AppColors.cardDark : AppColors.lightBg),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color
                    : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.06)),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (key != 'all') ...[
                  AppPriorityIndicator(
                    priority: key,
                    size: 8,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : color)
                        : (isDark ? AppColors.white70 : AppColors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 2. Bộ lọc Loại thời hạn
  Widget _buildDeadlineTypeFilter(bool isDark) {
    final types = [
      {'key': 'all', 'label': 'Tất cả'},
      {'key': 'has_deadline', 'label': 'Có thời hạn'},
      {'key': 'no_deadline', 'label': 'Không thời hạn'},
    ];

    return Row(
      children: types.map((t) {
        final key = t['key'] as String;
        final label = t['label'] as String;
        final isSelected = _selectedDeadlineType == key;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  _selectedDeadlineType = key;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                      : (isDark ? AppColors.cardDark : AppColors.lightBg),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.06)),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.white70 : AppColors.grey[700]),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 3. Bộ lọc Phòng ban
  Widget _buildDepartmentFilter(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedDepartmentId != null
              ? AppColors.primary
              : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.06)),
          width: _selectedDepartmentId != null ? 1.5 : 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedDepartmentId,
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: isDark ? AppColors.white70 : AppColors.grey[600],
            ),
          ),
          dropdownColor: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              'Tất cả phòng ban',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.white70 : AppColors.grey[700],
              ),
            ),
          ),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  'Tất cả phòng ban',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: _selectedDepartmentId == null ? FontWeight.bold : FontWeight.normal,
                    color: _selectedDepartmentId == null ? AppColors.primary : (isDark ? AppColors.white : AppColors.black87),
                  ),
                ),
              ),
            ),
            ...widget.departments.map((dept) => DropdownMenuItem<int?>(
                  value: dept.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text(
                      dept.name,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: _selectedDepartmentId == dept.id ? FontWeight.bold : FontWeight.normal,
                        color: _selectedDepartmentId == dept.id ? AppColors.primary : (isDark ? AppColors.white : AppColors.black87),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )),
          ],
          onChanged: (val) {
            setState(() {
              _selectedDepartmentId = val;
              if (val != null) {
                final found = widget.departments.where((d) => d.id == val);
                _selectedDepartmentName = found.isNotEmpty ? found.first.name : null;
              } else {
                _selectedDepartmentName = null;
              }
            });
          },
        ),
      ),
    );
  }

  /// Phím tắt chọn nhanh khoảng thời gian
  Widget _buildDateShortcuts(bool isDark) {
    final shortcuts = [
      {'key': 'today', 'label': 'Hôm nay'},
      {'key': 'week', 'label': 'Tuần này'},
      {'key': 'month', 'label': 'Tháng này'},
      {'key': 'last30', 'label': '30 ngày qua'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: shortcuts.map((s) {
          final key = s['key'] as String;
          final label = s['label'] as String;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _setShortcutDateRange(key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.lightBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.white70 : AppColors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 4. Ô chọn Từ ngày - Đến ngày
  Widget _buildDateRangePickers(bool isDark) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final fromText = _fromDate != null ? dateFormat.format(_fromDate!) : 'Từ ngày';
    final toText = _toDate != null ? dateFormat.format(_toDate!) : 'Đến ngày';

    return Row(
      children: [
        // Từ ngày
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _pickDate(isFromDate: true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.lightBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _fromDate != null
                      ? AppColors.primary
                      : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.06)),
                  width: _fromDate != null ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: _fromDate != null ? AppColors.primary : AppColors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fromText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _fromDate != null ? FontWeight.w600 : FontWeight.normal,
                        color: _fromDate != null
                            ? (isDark ? AppColors.white : AppColors.black87)
                            : AppColors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_fromDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _fromDate = null),
                      child: const Icon(Icons.close, size: 14, color: AppColors.grey),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '→',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white24 : AppColors.grey[400],
          ),
        ),
        const SizedBox(width: 8),
        // Đến ngày
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _pickDate(isFromDate: false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.lightBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _toDate != null
                      ? AppColors.primary
                      : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.06)),
                  width: _toDate != null ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 14,
                    color: _toDate != null ? AppColors.primary : AppColors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      toText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _toDate != null ? FontWeight.w600 : FontWeight.normal,
                        color: _toDate != null
                            ? (isDark ? AppColors.white : AppColors.black87)
                            : AppColors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_toDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _toDate = null),
                      child: const Icon(Icons.close, size: 14, color: AppColors.grey),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Footer Nút Áp dụng
  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: isDark ? AppColors.cardDark : AppColors.white,
      child: Row(
        children: [
          // Nút Đóng
          Expanded(
            flex: 1,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: isDark ? AppColors.white24 : AppColors.grey[300]!,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white70 : AppColors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nút Áp dụng
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 2,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _handleApply,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    _currentActiveCount > 0
                        ? 'Áp dụng ($_currentActiveCount)'
                        : 'Áp dụng',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
