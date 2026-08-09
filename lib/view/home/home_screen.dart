import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/navigation.dart';
import '../../untils/app_textstyles.dart';
import '../../untils/app_colors.dart';
import '../widgets/Status_info_card.dart';
import '../user/user_screen.dart';

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
                  border: Border.all(color: Colors.white30, width: 1.5),
                  image: DecorationImage(
                    image: avatarProvider,
                    fit: BoxFit.cover,
                    onError: (err, stack) {},
                  ),
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
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.waving_hand, color: Color(0xFFFBBF24), size: 12),
                      ],
                    ),
                    Text(
                      user?.name ?? 'Admin',
                      style: AppTextStyle.bodyLarge.copyWith(
                        color: Colors.white,
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
          StatusInfoCard(whiteColor: Colors.white),
        ],
      ),
    );
  }

  // --- 2. TWO DOUGHNUT CHARTS SIDE-BY-SIDE ---
  Widget _buildDoughnutChartsSection(bool isDark) {
    return Obx(() {
      final stats = taskController.stats;
      final total = stats['total'] ?? 0;

      // Status Stats values
      final todo = (stats['todo'] ?? 0) as int;
      final inProgress = (stats['in_progress'] ?? 0) as int;
      final pendingApproval = (stats['pending_approval'] ?? 0) as int;
      final done = (stats['done'] ?? 0) as int;
      final paused = (stats['paused'] ?? 0) as int;
      final cancelled = (stats['cancelled'] ?? 0) as int;

      // Timing Stats values
      final timing = stats['timing_stats'] ?? {};
      final upcoming = (timing['upcoming'] ?? 0) as int;
      final early = (timing['early'] ?? 0) as int;
      final onTime = (timing['on_time'] ?? 0) as int;
      final late = (timing['late'] ?? 0) as int;
      final overdue = (timing['overdue'] ?? 0) as int;
      final timingCancelled = (timing['cancelled'] ?? 0) as int;

      // Calculate percentages helper
      String getPercentStr(int value, int totalVal) {
        if (totalVal == 0) return '0%';
        final double percent = (value / totalVal) * 100;
        return '${percent.round()}%';
      }

      // Doughnut Sections for Status Structure
      final List<PieChartSectionData> statusSections = [];
      if (total == 0) {
        statusSections.add(PieChartSectionData(color: Colors.grey[300], value: 1, radius: 12, showTitle: false));
      } else {
        if (todo > 0) statusSections.add(PieChartSectionData(color: const Color(0xFF8B5CF6), value: todo.toDouble(), radius: 12, showTitle: false));
        if (inProgress > 0) statusSections.add(PieChartSectionData(color: const Color(0xFF0EA5E9), value: inProgress.toDouble(), radius: 12, showTitle: false));
        if (pendingApproval > 0) statusSections.add(PieChartSectionData(color: const Color(0xFFD946EF), value: pendingApproval.toDouble(), radius: 12, showTitle: false));
        if (done > 0) statusSections.add(PieChartSectionData(color: const Color(0xFF10B981), value: done.toDouble(), radius: 12, showTitle: false));
        if (paused > 0) statusSections.add(PieChartSectionData(color: const Color(0xFFF59E0B), value: paused.toDouble(), radius: 12, showTitle: false));
        if (cancelled > 0) statusSections.add(PieChartSectionData(color: const Color(0xFF6B7280), value: cancelled.toDouble(), radius: 12, showTitle: false));
      }

      // Doughnut Sections for Timing Structure
      final List<PieChartSectionData> timingSections = [];
      if (total == 0) {
        timingSections.add(PieChartSectionData(color: Colors.grey[300], value: 1, radius: 12, showTitle: false));
      } else {
        if (upcoming > 0) timingSections.add(PieChartSectionData(color: const Color(0xFF0EA5E9), value: upcoming.toDouble(), radius: 12, showTitle: false));
        if (early > 0) timingSections.add(PieChartSectionData(color: const Color(0xFF10B981), value: early.toDouble(), radius: 12, showTitle: false));
        if (onTime > 0) timingSections.add(PieChartSectionData(color: const Color(0xFF4F46E5), value: onTime.toDouble(), radius: 12, showTitle: false));
        if (late > 0) timingSections.add(PieChartSectionData(color: const Color(0xFFEC4899), value: late.toDouble(), radius: 12, showTitle: false));
        if (overdue > 0) timingSections.add(PieChartSectionData(color: const Color(0xFFEF4444), value: overdue.toDouble(), radius: 12, showTitle: false));
        if (timingCancelled > 0) timingSections.add(PieChartSectionData(color: const Color(0xFF6B7280), value: timingCancelled.toDouble(), radius: 12, showTitle: false));
      }

      return Row(
        children: [
          // 1. Status Doughnut Chart Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cơ cấu Trạng thái', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Theo trạng thái xử lý', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                  const SizedBox(height: 16),
                  Center(child: _buildDoughnut(statusSections, total)),
                  const SizedBox(height: 16),
                  _buildLegendItem('Chưa làm', '$todo (${getPercentStr(todo, total)})', const Color(0xFF8B5CF6)),
                  _buildLegendItem('Đang làm', '$inProgress (${getPercentStr(inProgress, total)})', const Color(0xFF0EA5E9)),
                  _buildLegendItem('Chờ duyệt', '$pendingApproval (${getPercentStr(pendingApproval, total)})', const Color(0xFFD946EF)),
                  _buildLegendItem('Hoàn thành', '$done (${getPercentStr(done, total)})', const Color(0xFF10B981)),
                  _buildLegendItem('Tạm dừng', '$paused (${getPercentStr(paused, total)})', const Color(0xFFF59E0B)),
                  _buildLegendItem('Đã hủy', '$cancelled (${getPercentStr(cancelled, total)})', const Color(0xFF6B7280)),
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
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cơ cấu Tiến độ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Theo hạn chót xử lý', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                  const SizedBox(height: 16),
                  Center(child: _buildDoughnut(timingSections, total)),
                  const SizedBox(height: 16),
                  _buildLegendItem('Chưa đến hạn', '$upcoming (${getPercentStr(upcoming, total)})', const Color(0xFF0EA5E9)),
                  _buildLegendItem('Sớm hạn', '$early (${getPercentStr(early, total)})', const Color(0xFF10B981)),
                  _buildLegendItem('Đúng hạn', '$onTime (${getPercentStr(onTime, total)})', const Color(0xFF4F46E5)),
                  _buildLegendItem('Trễ hạn', '$late (${getPercentStr(late, total)})', const Color(0xFFEC4899)),
                  _buildLegendItem('Quá hạn', '$overdue (${getPercentStr(overdue, total)})', const Color(0xFFEF4444)),
                  _buildLegendItem('Đã hủy', '$timingCancelled (${getPercentStr(timingCancelled, total)})', const Color(0xFF6B7280)),
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
              style: TextStyle(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.w500),
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
              style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500),
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
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                    color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
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
          const Text(
            '1. PHÂN BỐ THEO TRẠNG THÁI XỬ LÝ',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // Horizontal segment bars - Status
          _buildSegmentRow('UBND Phường', 5, 25, 24, [AppColors.todo, AppColors.inProgress, AppColors.done]),
          _buildSegmentRow('Công an Phường', 2, 10, 8, [AppColors.todo, AppColors.inProgress, AppColors.done]),
          _buildSegmentRow('Y tế Phường', 1, 8, 4, [AppColors.todo, AppColors.inProgress, AppColors.done]),
          _buildSegmentRow('Đội QLĐT', 3, 12, 10, [AppColors.todo, AppColors.inProgress, AppColors.done]),
          _buildSegmentRow('Tư pháp', 2, 6, 8, [AppColors.todo, AppColors.inProgress, AppColors.done]),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),

          const Text(
            '2. PHÂN BỐ THEO TIẾN ĐỘ THỜI GIAN',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // Horizontal segment bars - Timing
          _buildSegmentRow('Mục 1', 6, 3, 1, [AppColors.early, AppColors.overdue, AppColors.late]),
          _buildSegmentRow('Mục 2', 1, 3, 1, [AppColors.upcoming, AppColors.early, AppColors.late]),
          _buildSegmentRow('Mục 3', 1, 3, 1, [AppColors.upcoming, AppColors.early, AppColors.late]),
          _buildSegmentRow('Mục 4', 2, 1, 3, [AppColors.upcoming, AppColors.onTime, AppColors.overdue]),
          _buildSegmentRow('Mục 5', 1, 3, 2, [AppColors.upcoming, AppColors.early, AppColors.late, AppColors.overdue], 1),
          _buildSegmentRow('Mục 6', 3, 4, 0, [AppColors.early, AppColors.overdue]),

          const SizedBox(height: 16),
          // Legend for section 2
          _buildTimingLegendGrid(),
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
              _buildDotLegend('Chưa đến hạn', const Color(0xFF0EA5E9)),
              const SizedBox(width: 8),
              _buildDotLegend('Sớm hạn', const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _buildDotLegend('Đúng hạn', const Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              _buildDotLegend('Trễ hạn', const Color(0xFFEC4899)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDotLegend('Quá hạn', const Color(0xFFEF4444)),
            const SizedBox(width: 24),
            _buildDotLegend('Đã hủy', const Color(0xFF6B7280)),
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
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPillTabItem(String label, IconData icon, bool isActive, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? const Color(0xFF1E1E1E) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
              color: isActive ? const Color(0xFF2563EB) : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF2563EB) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentRow(String label, int val1, int val2, int val3, List<Color> colors, [int val4 = 0]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
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
                child: Row(
                  children: [
                    if (val1 > 0 && colors.isNotEmpty) Expanded(flex: val1, child: Container(color: colors[0])),
                    if (val2 > 0 && colors.length > 1) Expanded(flex: val2, child: Container(color: colors[1])),
                    if (val3 > 0 && colors.length > 2) Expanded(flex: val3, child: Container(color: colors[2])),
                    if (val4 > 0 && colors.length > 3) Expanded(flex: val4, child: Container(color: colors[3])),
                  ],
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
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              _buildDirectoryButton('Công việc đang giao', Icons.send_outlined, const Color(0xFFEFF6FF), const Color(0xFF2563EB), () {
                Get.find<NavigationController>().changeIndex(3);
              }, isDark),
              _buildDirectoryButton('Công việc được giao', Icons.mail_outline, const Color(0xFFECFDF5), const Color(0xFF10B981), () {
                Get.find<NavigationController>().changeIndex(3);
              }, isDark),
              _buildDirectoryButton('Thống kê & Báo cáo', Icons.pie_chart_outline, const Color(0xFFF5F3FF), const Color(0xFF8B5CF6), () {
                Get.find<NavigationController>().changeIndex(3);
              }, isDark),
              _buildDirectoryButton('Đơn thư & Kiến nghị', Icons.description_outlined, const Color(0xFFFFFBEB), const Color(0xFFF59E0B), () {
                Get.find<NavigationController>().changeIndex(4);
              }, isDark),
              _buildDirectoryButton('Thông tin cá nhân', Icons.person_outline, const Color(0xFFEFF6FF), const Color(0xFF0EA5E9), () {
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
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
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
                color: isDark ? Colors.white10 : bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDark ? Colors.white : iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
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
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11),
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
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
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
              color: Color(0xFFF59E0B),
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
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
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
                          color: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(assignee, style: TextStyle(fontSize: 9, color: Colors.grey[700])),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.circle, size: 3, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text('Hạn: $deadline', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      const SizedBox(width: 6),
                      const Icon(Icons.circle, size: 3, color: Colors.grey),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('• $percent%', style: const TextStyle(fontSize: 9, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
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
                  color: statusText == 'Hoàn thành' ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusText == 'Hoàn thành' ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: timingText == 'QUÁ HẠN' ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  timingText,
                  style: TextStyle(
                    color: timingText == 'QUÁ HẠN' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
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