import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/navigation.dart';
import '../../untils/app_textstyles.dart';
import '../../untils/app_colors.dart';
import '../widgets/Status_info_card.dart';
import '../user/user_screen.dart';
import '../../core/api_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TaskController taskController = Get.isRegistered<TaskController>()
      ? Get.find<TaskController>()
      : Get.put(TaskController());

  // Active pill selection for PHÂN BỐ CHI TIẾT (0 = Phòng Ban, 1 = Loại CV)
  final RxInt activeDistributionTab = 0.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. BLUE HEADER AREA (Contains User Profile & StatusInfoCard)
              _buildTopHeaderArea(context, isDark),

              // 2. MAIN BODY (White-ish background)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    // A. TWO DOUGHNUT CHARTS SIDE-BY-SIDE
                    _buildDoughnutChartsSection(isDark),

                    const SizedBox(height: 16),

                    // B. PHÂN BỐ CHI TIẾT SECTION
                    _buildDetailedDistributionSection(isDark),

                    const SizedBox(height: 16),

                    // C. DANH MỤC QUẢN LÝ
                    _buildManagementDirectorySection(context, isDark),

                    const SizedBox(height: 16),

                    // D. CÔNG VIỆC MỚI NHẤT
                    _buildLatestTasksSection(isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. BLUE HEADER AREA WITH PROFILE & STATS CARD ---
  Widget _buildTopHeaderArea(BuildContext context, bool isDark) {
    final user = authController.currentUser.value;

    // Get Avatar Image URL
    ImageProvider avatarProvider;
    if (user != null && user.avatar.isNotEmpty) {
      final avatarUrl = user.avatar.startsWith('http')
          ? user.avatar
          : 'https://danatec-test.theworkpc.com${user.avatar}';
      avatarProvider = NetworkImage(avatarUrl);
    } else {
      avatarProvider = const AssetImage('assets/images/logo.png'); // Fallback
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepBlue, AppColors.darkBlue, AppColors.primary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(top: 10, left: 12, right: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Profile Header row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.badgeRedBg, width: 1.5),
                  color: AppColors.blueGrey,
                ),
                child: ClipOval(
                  child: (user != null && user.avatar.isNotEmpty)
                      ? Image.network(
                          user.avatar.startsWith('http')
                              ? user.avatar
                              : '${ApiConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '')}${user.avatar}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, color: AppColors.white, size: 30),
                        )
                      : const Icon(Icons.person, color: AppColors.white, size: 30),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'XIN CHÀO',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.waving_hand, color: AppColors.textOrangeAlert, size: 12),
                      ],
                    ),
                    Text(
                      user?.name ?? 'Admin',
                      style: AppTextStyle.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Overview Statistics Card Overlay
          StatusInfoCard(whiteColor: AppColors.white),
        ],
      ),
    );
  }

  // --- 2. TWO DOUGHNUT CHARTS SIDE-BY-SIDE ---
  Widget _buildDoughnutChartsSection(bool isDark) {
    return Obx(() {
      final stats = taskController.stats.value;
      final total = stats.total;
      final todo = stats.todo;
      final inProgress = stats.inProgress;
      final pendingApproval = stats.pendingApproval;
      final done = stats.done;
      final paused = stats.paused;
      final cancelled = stats.cancelled;

      final timing = stats.timingStats;
      final upcoming = timing.upcoming;
      final early = timing.early;
      final onTime = timing.onTime;
      final late = timing.late;
      final overdue = timing.overdue;
      final timingCancelled = timing.cancelled;

      // Calculate percentages helper
      String getPercentStr(int value, int totalVal) {
        if (totalVal == 0) return '0%';
        final double percent = (value / totalVal) * 100;
        return '${percent.round()}%';
      }

      // Doughnut Sections for Status Structure
      final List<PieChartSectionData> statusSections = [];
      if (total == 0) {
        statusSections.add(PieChartSectionData(color: AppColors.grey[300], value: 1, radius: 12, showTitle: false));
      } else {
        if (todo > 0) statusSections.add(PieChartSectionData(color: AppColors.todo, value: todo.toDouble(), radius: 12, showTitle: false));
        if (inProgress > 0) statusSections.add(PieChartSectionData(color: AppColors.inProgress, value: inProgress.toDouble(), radius: 12, showTitle: false));
        if (pendingApproval > 0) statusSections.add(PieChartSectionData(color: AppColors.pendingApproval, value: pendingApproval.toDouble(), radius: 12, showTitle: false));
        if (done > 0) statusSections.add(PieChartSectionData(color: AppColors.done, value: done.toDouble(), radius: 12, showTitle: false));
        if (paused > 0) statusSections.add(PieChartSectionData(color: AppColors.paused, value: paused.toDouble(), radius: 12, showTitle: false));
        if (cancelled > 0) statusSections.add(PieChartSectionData(color: AppColors.cancelled, value: cancelled.toDouble(), radius: 12, showTitle: false));
      }

      // Doughnut Sections for Timing Structure
      final List<PieChartSectionData> timingSections = [];
      if (total == 0) {
        timingSections.add(PieChartSectionData(color: AppColors.grey[300], value: 1, radius: 12, showTitle: false));
      } else {
        if (upcoming > 0) timingSections.add(PieChartSectionData(color: AppColors.inProgress, value: upcoming.toDouble(), radius: 12, showTitle: false));
        if (early > 0) timingSections.add(PieChartSectionData(color: AppColors.done, value: early.toDouble(), radius: 12, showTitle: false));
        if (onTime > 0) timingSections.add(PieChartSectionData(color: AppColors.onTime, value: onTime.toDouble(), radius: 12, showTitle: false));
        if (late > 0) timingSections.add(PieChartSectionData(color: AppColors.late, value: late.toDouble(), radius: 12, showTitle: false));
        if (overdue > 0) timingSections.add(PieChartSectionData(color: AppColors.overdue, value: overdue.toDouble(), radius: 12, showTitle: false));
        if (timingCancelled > 0) timingSections.add(PieChartSectionData(color: AppColors.cancelled, value: timingCancelled.toDouble(), radius: 12, showTitle: false));
      }

      return Row(
        children: [
          // 1. Status Doughnut Chart Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cơ cấu Trạng thái', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Theo trạng thái xử lý', style: TextStyle(color: AppColors.grey[500], fontSize: 10)),
                  const SizedBox(height: 16),
                  Center(child: _buildDoughnut(statusSections, total)),
                  const SizedBox(height: 16),
                  _buildLegendItem('Chưa làm', '$todo (${getPercentStr(todo, total)})', AppColors.todo),
                  _buildLegendItem('Đang làm', '$inProgress (${getPercentStr(inProgress, total)})', AppColors.inProgress),
                  _buildLegendItem('Chờ duyệt', '$pendingApproval (${getPercentStr(pendingApproval, total)})', AppColors.pendingApproval),
                  _buildLegendItem('Hoàn thành', '$done (${getPercentStr(done, total)})', AppColors.done),
                  _buildLegendItem('Tạm dừng', '$paused (${getPercentStr(paused, total)})', AppColors.paused),
                  _buildLegendItem('Đã hủy', '$cancelled (${getPercentStr(cancelled, total)})', AppColors.cancelled),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 2. Timing Doughnut Chart Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cơ cấu Tiến độ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Theo hạn chót xử lý', style: TextStyle(color: AppColors.grey[500], fontSize: 10)),
                  const SizedBox(height: 16),
                  Center(child: _buildDoughnut(timingSections, total)),
                  const SizedBox(height: 16),
                  _buildLegendItem('Chưa đến hạn', '$upcoming (${getPercentStr(upcoming, total)})', AppColors.inProgress),
                  _buildLegendItem('Sớm hạn', '$early (${getPercentStr(early, total)})', AppColors.done),
                  _buildLegendItem('Đúng hạn', '$onTime (${getPercentStr(onTime, total)})', AppColors.onTime),
                  _buildLegendItem('Trễ hạn', '$late (${getPercentStr(late, total)})', AppColors.late),
                  _buildLegendItem('Quá hạn', '$overdue (${getPercentStr(overdue, total)})', AppColors.overdue),
                  _buildLegendItem('Đã hủy', '$timingCancelled (${getPercentStr(timingCancelled, total)})', AppColors.cancelled),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDoughnut(List<PieChartSectionData> sections, int total) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: sections,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tổng',
              style: TextStyle(fontSize: 9, color: AppColors.grey[500], fontWeight: FontWeight.w500),
            ),
            Text(
              total.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.grey, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- B. PHÂN BỐ CHI TIẾT ---
  Widget _buildDetailedDistributionSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section & toggle pill bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PHÂN BỐ CHI TIẾT',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
              ),
              // Pills
              Obx(() {
                final selectedTab = activeDistributionTab.value;
                return Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardItemDark : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildPillTabItem('Phòng Ban', Icons.business_outlined, selectedTab == 0, () => activeDistributionTab.value = 0, isDark),
                      _buildPillTabItem('Loại CV', Icons.layers_outlined, selectedTab == 1, () => activeDistributionTab.value = 1, isDark),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final isDept = activeDistributionTab.value == 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. PHÂN BỐ THEO TRẠNG THÁI XỬ LÝ',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey),
                ),
                const SizedBox(height: 12),

                if (isDept) ...[
                  if (taskController.departmentStatsList.isNotEmpty)
                    ...taskController.departmentStatsList.map((item) {
                      final name = (item['department_name'] ?? item['name'] ?? item['department'] ?? 'Phòng ban').toString();
                      final todo = ((item['todo'] ?? item['todo_count'] ?? 0) as num).toInt();
                      final inProgress = ((item['in_progress'] ?? item['in_progress_count'] ?? 0) as num).toInt();
                      final pending = ((item['pending_approval'] ?? item['pending'] ?? 0) as num).toInt();
                      final done = ((item['completed'] ?? item['done_count'] ?? item['done'] ?? 0) as num).toInt();
                      final paused = ((item['paused'] ?? 0) as num).toInt();
                      final cancelled = ((item['cancelled'] ?? 0) as num).toInt();
                      return _buildSegmentRow(name, [
                        {'count': todo, 'color': AppColors.todo},
                        {'count': inProgress, 'color': AppColors.inProgress},
                        {'count': pending, 'color': AppColors.pendingApproval},
                        {'count': done, 'color': AppColors.done},
                        {'count': paused, 'color': AppColors.paused},
                        {'count': cancelled, 'color': AppColors.cancelled},
                      ]);
                    })
                  else if (taskController.departments.isNotEmpty)
                    ...taskController.departments.take(5).map((dept) {
                      return _buildSegmentRow(dept.name, [
                        {'count': 1, 'color': AppColors.todo},
                        {'count': 2, 'color': AppColors.inProgress},
                        {'count': 3, 'color': AppColors.done},
                      ]);
                    })
                  else ...[
                    _buildSegmentRow('Đang tải phòng ban...', []),
                  ]
                ] else ...[
                  if (taskController.itemTypeStatsList.isNotEmpty)
                    ...taskController.itemTypeStatsList.map((item) {
                      final name = (item['item_type_name'] ?? item['type_name'] ?? item['name'] ?? item['title'] ?? item['task_assignment_item_type_name'] ?? 'Loại công việc').toString();
                      final todo = ((item['todo'] ?? item['todo_count'] ?? 0) as num).toInt();
                      final inProgress = ((item['in_progress'] ?? item['in_progress_count'] ?? 0) as num).toInt();
                      final pending = ((item['pending_approval'] ?? item['pending'] ?? 0) as num).toInt();
                      final done = ((item['completed'] ?? item['done_count'] ?? item['done'] ?? 0) as num).toInt();
                      final paused = ((item['paused'] ?? 0) as num).toInt();
                      final cancelled = ((item['cancelled'] ?? 0) as num).toInt();
                      return _buildSegmentRow(name, [
                        {'count': todo, 'color': AppColors.todo},
                        {'count': inProgress, 'color': AppColors.inProgress},
                        {'count': pending, 'color': AppColors.pendingApproval},
                        {'count': done, 'color': AppColors.done},
                        {'count': paused, 'color': AppColors.paused},
                        {'count': cancelled, 'color': AppColors.cancelled},
                      ]);
                    })
                  else ...[
                    _buildSegmentRow('Chưa có loại công việc', []),
                  ]
                ],

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.black12),
                const SizedBox(height: 16),

                const Text(
                  '2. PHÂN BỐ THEO TIẾN ĐỘ THỜI GIAN',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey),
                ),
                const SizedBox(height: 12),

                if (isDept) ...[
                  if (taskController.departmentStatsList.isNotEmpty)
                    ...taskController.departmentStatsList.map((item) {
                      final name = (item['department_name'] ?? item['name'] ?? item['department'] ?? 'Phòng ban').toString();
                      final total = ((item['total'] ?? 0) as num).toInt();
                      final overdue = ((item['overdue'] ?? item['overdue_count'] ?? 0) as num).toInt();
                      final cancelled = ((item['cancelled'] ?? 0) as num).toInt();
                      final early = ((item['early'] ?? 0) as num).toInt();
                      final onTime = ((item['on_time'] ?? 0) as num).toInt();
                      final lateVal = ((item['late'] ?? 0) as num).toInt();
                      final upcoming = (total - overdue - cancelled - early - onTime - lateVal) > 0
                          ? (total - overdue - cancelled - early - onTime - lateVal)
                          : 0;
                      return _buildSegmentRow(name, [
                        {'count': upcoming, 'color': AppColors.inProgress},
                        {'count': early, 'color': AppColors.early},
                        {'count': onTime, 'color': AppColors.onTime},
                        {'count': lateVal, 'color': AppColors.late},
                        {'count': overdue, 'color': AppColors.overdue},
                        {'count': cancelled, 'color': AppColors.cancelled},
                      ]);
                    })
                  else if (taskController.departments.isNotEmpty)
                    ...taskController.departments.take(5).map((dept) {
                      return _buildSegmentRow(dept.name, [
                        {'count': 1, 'color': AppColors.inProgress},
                        {'count': 2, 'color': AppColors.overdue},
                        {'count': 1, 'color': AppColors.late},
                      ]);
                    })
                  else ...[
                    _buildSegmentRow('Đang tải phòng ban...', []),
                  ]
                ] else ...[
                  if (taskController.itemTypeStatsList.isNotEmpty)
                    ...taskController.itemTypeStatsList.map((item) {
                      final name = (item['item_type_name'] ?? item['type_name'] ?? item['name'] ?? item['title'] ?? item['task_assignment_item_type_name'] ?? 'Loại công việc').toString();
                      final total = ((item['total'] ?? 0) as num).toInt();
                      final overdue = ((item['overdue'] ?? item['overdue_count'] ?? 0) as num).toInt();
                      final cancelled = ((item['cancelled'] ?? 0) as num).toInt();
                      final early = ((item['early'] ?? 0) as num).toInt();
                      final onTime = ((item['on_time'] ?? 0) as num).toInt();
                      final lateVal = ((item['late'] ?? 0) as num).toInt();
                      final upcoming = (total - overdue - cancelled - early - onTime - lateVal) > 0
                          ? (total - overdue - cancelled - early - onTime - lateVal)
                          : 0;
                      return _buildSegmentRow(name, [
                        {'count': upcoming, 'color': AppColors.inProgress},
                        {'count': early, 'color': AppColors.early},
                        {'count': onTime, 'color': AppColors.onTime},
                        {'count': lateVal, 'color': AppColors.late},
                        {'count': overdue, 'color': AppColors.overdue},
                        {'count': cancelled, 'color': AppColors.cancelled},
                      ]);
                    })
                  else ...[
                    _buildSegmentRow('Chưa có loại công việc', []),
                  ]
                ],

                const SizedBox(height: 16),
                _buildTimingLegendGrid(),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _buildTimingLegendGrid() {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDotLegend('Chưa đến hạn', AppColors.inProgress),
              const SizedBox(width: 8),
              _buildDotLegend('Sớm hạn', AppColors.done),
              const SizedBox(width: 8),
              _buildDotLegend('Đúng hạn', AppColors.onTime),
              const SizedBox(width: 8),
              _buildDotLegend('Trễ hạn', AppColors.late),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDotLegend('Quá hạn', AppColors.overdue),
            const SizedBox(width: 24),
            _buildDotLegend('Đã hủy', AppColors.cancelled),
          ],
        )
      ],
    );
  }

  Widget _buildDotLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPillTabItem(String label, IconData icon, bool isActive, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? AppColors.cardDark : AppColors.white) : AppColors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isActive ? AppColors.primary : AppColors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primary : AppColors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentRow(String label, List<Map<String, dynamic>> segments) {
    final total = segments.fold<int>(0, (sum, s) => sum + ((s['count'] ?? 0) as num).toInt());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: total == 0
                    ? Container(color: AppColors.grey.withOpacity(0.12))
                    : Row(
                        children: segments.where((s) => ((s['count'] ?? 0) as num) > 0).map((s) {
                          final count = ((s['count'] ?? 0) as num).toInt();
                          final color = s['color'] as Color;
                          return Expanded(
                            flex: count,
                            child: Container(color: color),
                          );
                        }).toList(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- C. DANH MỤC QUẢN LÝ ---
  Widget _buildManagementDirectorySection(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DANH MỤC QUẢN LÝ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: [
              _buildDirectoryButton('Công việc đang giao', Icons.send_outlined, AppColors.badgeBlueBg, AppColors.primary, () {
                Get.find<NavigationController>().changeIndex(1);
              }, isDark),
              _buildDirectoryButton('Công việc được giao', Icons.mail_outline, AppColors.badgeGreenBg, AppColors.done, () {
                Get.find<NavigationController>().changeIndex(2);
              }, isDark),
              _buildDirectoryButton('Thống kê & Báo cáo', Icons.pie_chart_outline, AppColors.bgPurpleLight, AppColors.todo, () {
                Get.find<NavigationController>().changeIndex(4);
              }, isDark),
              _buildDirectoryButton('Đơn thư & Kiến nghị', Icons.description_outlined, AppColors.bgYellowLight, AppColors.paused, () {
                Get.find<NavigationController>().changeIndex(3);
              }, isDark),
              _buildDirectoryButton('Thông tin cá nhân', Icons.person_outline, AppColors.badgeBlueBg, AppColors.inProgress, () {
                Get.to(() => const ProfileScreen());
              }, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryButton(String label, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardItemDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.white10 : AppColors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.white10 : bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDark ? AppColors.white : iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- D. CÔNG VIỆC MỚI NHẤT ---
  Widget _buildLatestTasksSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CÔNG VIỆC MỚI NHẤT',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
              ),
              GestureDetector(
                onTap: () => Get.find<NavigationController>().changeIndex(3),
                child: const Text(
                  'Xem tất cả >',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final tasks = taskController.tasksList;
            if (tasks.isEmpty) {
              return Column(
                children: [
                  _buildTaskItem('Kiểm tra công tác trang trí, khánh tiết Đại hội', 'Nguyễn Văn Hùng', '01/04', 70, 'Đang thực hiện', 'QUÁ HẠN', isDark),
                  const SizedBox(height: 10),
                  _buildTaskItem('Soạn đề cương biên soạn lịch sử Đảng bộ TP', 'Huỳnh Thị Lan', '02/04', 40, 'Đang thực hiện', 'QUÁ HẠN', isDark),
                  const SizedBox(height: 10),
                  _buildTaskItem('Rà soát các trang mạng xã hội có nội dung xu...', 'Nguyễn Văn Hùng', '03/04', 50, 'Đang thực hiện', 'QUÁ HẠN', isDark),
                ],
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length > 5 ? 5 : tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final task = tasks[index];

                String statusText = 'Đang thực hiện';
                if (task.processingStatus == 'todo') statusText = 'Chưa thực hiện';
                if (task.processingStatus == 'done') statusText = 'Hoàn thành';
                if (task.processingStatus == 'paused') statusText = 'Tạm dừng';
                if (task.processingStatus == 'cancelled') statusText = 'Đã hủy';

                String timingText = 'ĐÚNG HẠN';
                if (task.isOverdue || task.timingStatus == 'overdue') {
                  timingText = 'QUÁ HẠN';
                } else if (task.timingStatus == 'late') {
                  timingText = 'TRỄ HẠN';
                } else if (task.timingStatus == 'early') {
                  timingText = 'SỚM HẠN';
                } else if (task.timingStatus == 'upcoming') {
                  timingText = 'CHƯA ĐẾN HẠN';
                }

                String deadlineStr = 'N/A';
                if (task.endAt != null && task.endAt!.isNotEmpty) {
                  try {
                    final spaceParts = task.endAt!.trim().split(' ');
                    String datePart = spaceParts.length >= 2 ? spaceParts[1] : spaceParts[0];
                    if (datePart.contains('/')) {
                      final dateParts = datePart.split('/');
                      if (dateParts.length >= 2) {
                        deadlineStr = '${dateParts[0]}/${dateParts[1]}';
                      }
                    } else if (datePart.contains('-')) {
                      final dateParts = datePart.split('-');
                      if (dateParts.length >= 3) {
                        if (dateParts[0].length == 4) {
                          deadlineStr = '${dateParts[2]}/${dateParts[1]}';
                        } else {
                          deadlineStr = '${dateParts[0]}/${dateParts[1]}';
                        }
                      }
                    }
                  } catch (_) {}
                }

                return _buildTaskItem(
                  task.name,
                  'Nguyễn Văn Hùng',
                  deadlineStr,
                  task.completionPercent,
                  statusText,
                  timingText,
                  isDark,
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, String assignee, String deadline, int percent, String statusText, String timingText, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardItemDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.white10 : AppColors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orange dot status indicator
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.paused,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          // Task Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.white10 : AppColors.lightBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(assignee, style: TextStyle(fontSize: 9, color: AppColors.grey[700])),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.circle, size: 3, color: AppColors.grey),
                      const SizedBox(width: 6),
                      Text('Hạn: $deadline', style: const TextStyle(fontSize: 9, color: AppColors.grey)),
                      const SizedBox(width: 6),
                      const Icon(Icons.circle, size: 3, color: AppColors.grey),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.badgeBlueBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('• $percent%', style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Right Badges Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusText == 'Hoàn thành' ? AppColors.badgeGreenBg : AppColors.badgeBlueBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusText == 'Hoàn thành' ? AppColors.done : AppColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: timingText == 'QUÁ HẠN' ? AppColors.badgeRedBg : AppColors.badgeGreenBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  timingText,
                  style: TextStyle(
                    color: timingText == 'QUÁ HẠN' ? AppColors.overdue : AppColors.done,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

