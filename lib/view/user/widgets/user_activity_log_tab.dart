import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/log_activity_controller.dart';
import '../../../model/log_activity.dart';
import '../../../untils/app_colors.dart';
import '../../widgets/skeleton_loader.dart';

class UserActivityLogTab extends StatefulWidget {
  final bool isDark;

  const UserActivityLogTab({
    super.key,
    required this.isDark,
  });

  @override
  State<UserActivityLogTab> createState() => _UserActivityLogTabState();
}

class _UserActivityLogTabState extends State<UserActivityLogTab> {
  final LogActivityController logController = Get.find<LogActivityController>();

  final TextEditingController _searchController = TextEditingController();
  String _selectedMethod = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: widget.isDark ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  List<LogActivity> _filterLogs(List<LogActivity> logs) {
    final query = _searchController.text.trim().toLowerCase();

    return logs.where((log) {
      // 1. Search Query
      if (query.isNotEmpty) {
        final desc = log.description.toLowerCase();
        final ip = log.ipAddress.toLowerCase();
        if (!desc.contains(query) && !ip.contains(query)) {
          return false;
        }
      }

      // 2. Method Filter
      if (_selectedMethod != 'all') {
        if (log.method.toUpperCase() != _selectedMethod.toUpperCase()) {
          return false;
        }
      }

      // 3. Date Filters
      if (_startDate != null || _endDate != null) {
        try {
          DateTime? logDate;
          final datePart = log.createdAt.split(' ').length > 1
              ? log.createdAt.split(' ')[1]
              : log.createdAt;
          if (datePart.contains('/')) {
            final parts = datePart.split('/');
            if (parts.length >= 3) {
              logDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            }
          } else if (datePart.contains('-')) {
            logDate = DateTime.tryParse(datePart);
          }

          if (logDate != null) {
            if (_startDate != null && logDate.isBefore(_startDate!)) {
              return false;
            }
            if (_endDate != null && logDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
              return false;
            }
          }
        } catch (_) {}
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ==================== 1. FILTER CARD ====================
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Search TextField & Method Dropdown
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppColors.white24 : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white : AppColors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm hành động...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.grey[500] : const Color(0xFF94A3B8),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 17,
                            color: isDark ? AppColors.grey[400] : const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 9),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.white24 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMethod,
                        isDense: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: isDark ? AppColors.grey[400] : AppColors.grey[600],
                        ),
                        dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tất cả Method', style: TextStyle(fontSize: 11.5))),
                          DropdownMenuItem(value: 'GET', child: Text('GET', style: TextStyle(fontSize: 11.5))),
                          DropdownMenuItem(value: 'POST', child: Text('POST', style: TextStyle(fontSize: 11.5))),
                          DropdownMenuItem(value: 'PUT', child: Text('PUT', style: TextStyle(fontSize: 11.5))),
                          DropdownMenuItem(value: 'DELETE', child: Text('DELETE', style: TextStyle(fontSize: 11.5))),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedMethod = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 2: Date Picker (Từ ngày & Đến ngày)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Từ ngày:',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.grey[400] : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _pickDate(true),
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? AppColors.white24 : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _startDate != null
                                      ? DateFormat('dd/MM/yyyy').format(_startDate!)
                                      : '',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? Colors.white : AppColors.black87,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: isDark ? AppColors.grey[400] : AppColors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đến ngày:',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.grey[400] : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _pickDate(false),
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? AppColors.white24 : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _endDate != null
                                      ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                      : '',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? Colors.white : AppColors.black87,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: isDark ? AppColors.grey[400] : AppColors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ==================== 2. LOG LIST CARD ====================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() {
            if (logController.isLoading.value && logController.logs.isEmpty) {
              return _buildSkeletonList();
            }

            final filteredLogs = _filterLogs(logController.logs);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 18,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'NHẬT KÝ CÁ NHÂN',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Tổng: ${filteredLogs.length} bản ghi',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.grey[400] : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (filteredLogs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history_toggle_off_rounded,
                            size: 38,
                            color: isDark ? AppColors.grey[600] : AppColors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Không tìm thấy nhật ký phù hợp',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? AppColors.grey[400] : AppColors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredLogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _buildLogItem(log, isDark);
                    },
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLogItem(LogActivity log, bool isDark) {
    final method = log.method.toUpperCase();
    Color badgeBg;
    Color badgeText;
    Color badgeBorder;

    switch (method) {
      case 'POST':
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFFD97706);
        badgeBorder = const Color(0xFFFDE68A);
        break;
      case 'PUT':
      case 'PATCH':
        badgeBg = const Color(0xFFEDE9FE);
        badgeText = const Color(0xFF7C3AED);
        badgeBorder = const Color(0xFFDDD6FE);
        break;
      case 'DELETE':
        badgeBg = const Color(0xFFFEE2E2);
        badgeText = const Color(0xFFDC2626);
        badgeBorder = const Color(0xFFFECACA);
        break;
      case 'GET':
      default:
        badgeBg = isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE);
        badgeText = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
        badgeBorder = isDark ? const Color(0xFF0369A1) : const Color(0xFFBAE6FD);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.white10 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Badge + Description + CreatedAt
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeBorder, width: 0.8),
                ),
                child: Text(
                  method,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: badgeText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  log.description,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                log.createdAt,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? AppColors.grey[400] : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: IP Address
          Text(
            'IP: ${log.ipAddress}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.grey[400] : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: SkeletonLoader(
            child: SkeletonBox(
              width: double.infinity,
              height: 54,
              radius: 12,
            ),
          ),
        ),
      ),
    );
  }
}
