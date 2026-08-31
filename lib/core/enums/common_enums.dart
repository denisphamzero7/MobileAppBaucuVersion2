import 'package:flutter/material.dart';

/// ============================================================================
/// 1. BỘ LỌC KHOẢNG THỜI GIAN (TIME RANGE FILTER)
/// ============================================================================
enum TimeRangeFilter {
  all(
    key: 'all',
    label: 'Tất cả thời gian',
    icon: Icons.all_inclusive,
    aliases: ['tat_ca', 'tatca'],
  ),
  today(
    key: 'today',
    label: 'Hôm nay',
    icon: Icons.today_outlined,
    aliases: ['hom_nay'],
  ),
  thisWeek(
    key: 'this_week',
    label: 'Tuần này',
    icon: Icons.view_week_outlined,
    aliases: ['tuan_nay', 'week'],
  ),
  thisMonth(
    key: 'this_month',
    label: 'Tháng này',
    icon: Icons.calendar_month_outlined,
    aliases: ['thang_nay', 'month'],
  ),
  thisQuarter(
    key: 'this_quarter',
    label: 'Quý này',
    icon: Icons.calendar_view_month_outlined,
    aliases: ['quy_nay', 'quarter'],
  ),
  thisYear(
    key: 'this_year',
    label: 'Năm nay',
    icon: Icons.calendar_today_outlined,
    aliases: ['nam_nay', 'year'],
  ),
  custom(
    key: 'custom',
    label: 'Tùy chọn ngày',
    icon: Icons.date_range_outlined,
    aliases: ['tuy_chon', 'custom_range'],
  );

  final String key;
  final String label;
  final IconData icon;
  final List<String> aliases;

  const TimeRangeFilter({
    required this.key,
    required this.label,
    required this.icon,
    this.aliases = const [],
  });

  static final Map<String, TimeRangeFilter> _lookupMap = () {
    final map = <String, TimeRangeFilter>{};
    for (final f in TimeRangeFilter.values) {
      map[f.key.toLowerCase()] = f;
      for (final alias in f.aliases) {
        map[alias.toLowerCase()] = f;
      }
    }
    return map;
  }();

  static TimeRangeFilter fromKey(
    String? key, {
    TimeRangeFilter fallback = TimeRangeFilter.thisMonth,
  }) {
    if (key == null || key.trim().isEmpty) return fallback;
    return _lookupMap[key.toLowerCase().trim()] ?? fallback;
  }
}

/// ============================================================================
/// 2. TIÊU CHÍ SẮP XẾP DANH SÁCH (SORT ORDER)
/// ============================================================================
enum SortOrder {
  newest(
    key: 'newest',
    label: 'Mới nhất',
    icon: Icons.arrow_downward_outlined,
  ),
  oldest(
    key: 'oldest',
    label: 'Cũ nhất',
    icon: Icons.arrow_upward_outlined,
  ),
  deadlineAsc(
    key: 'deadline_asc',
    label: 'Sắp hết hạn trước',
    icon: Icons.access_time_outlined,
  ),
  priorityDesc(
    key: 'priority_desc',
    label: 'Độ ưu tiên cao nhất',
    icon: Icons.priority_high_outlined,
  ),
  nameAsc(
    key: 'name_asc',
    label: 'Tên A - Z',
    icon: Icons.sort_by_alpha_outlined,
  );

  final String key;
  final String label;
  final IconData icon;

  const SortOrder({
    required this.key,
    required this.label,
    required this.icon,
  });
}

/// ============================================================================
/// 3. CHẾ ĐỘ GIAO DIỆN SÁNG / TỐI (APP THEME MODE)
/// ============================================================================
enum AppThemeMode {
  light(
    key: 'light',
    label: 'Giao diện Sáng',
    icon: Icons.light_mode_outlined,
    themeMode: ThemeMode.light,
  ),
  dark(
    key: 'dark',
    label: 'Giao diện Tối',
    icon: Icons.dark_mode_outlined,
    themeMode: ThemeMode.dark,
  ),
  system(
    key: 'system',
    label: 'Theo hệ thống',
    icon: Icons.settings_brightness_outlined,
    themeMode: ThemeMode.system,
  );

  final String key;
  final String label;
  final IconData icon;
  final ThemeMode themeMode;

  const AppThemeMode({
    required this.key,
    required this.label,
    required this.icon,
    required this.themeMode,
  });

  static AppThemeMode fromKey(String? key) {
    if (key == 'light') return AppThemeMode.light;
    if (key == 'dark') return AppThemeMode.dark;
    return AppThemeMode.system;
  }
}

/// ============================================================================
/// 4. TAB THANH ĐIỀU HƯỚNG CHÍNH (APP NAVIGATION TAB)
/// ============================================================================
enum AppNavigationTab {
  home(
    label: 'Trang chủ',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
  ),
  sentTasks(
    label: 'Đang giao',
    icon: Icons.send_outlined,
    activeIcon: Icons.send,
  ),
  receivedTasks(
    label: 'Được giao',
    icon: Icons.mail_outline,
    activeIcon: Icons.mail,
  ),
  petitions(
    label: 'Đơn thư',
    icon: Icons.description_outlined,
    activeIcon: Icons.description,
  ),
  taskDocuments(
    label: 'Văn bản',
    icon: Icons.insert_drive_file_outlined,
    activeIcon: Icons.insert_drive_file,
  ),
  statistic(
    label: 'Thống kê',
    icon: Icons.pie_chart_outline,
    activeIcon: Icons.pie_chart,
  ),
  profile(
    label: 'Người dùng',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
  );

  final String label;
  final IconData icon;
  final IconData activeIcon;

  const AppNavigationTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  static AppNavigationTab fromIndex(int index) {
    if (index >= 0 && index < AppNavigationTab.values.length) {
      return AppNavigationTab.values[index];
    }
    return AppNavigationTab.home;
  }
}
