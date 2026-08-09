import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/navigation.dart';
import '../../untils/app_colors.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final TaskController taskController = Get.isRegistered<TaskController>()
      ? Get.find<TaskController>()
      : Get.put(TaskController());

  final RxInt activeDistributionTab = 0.obs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () {
            Get.find<NavigationController>().changeIndex(0);
          },
        ),
        title: const Text(
          'Thống kê & Báo cáo lãnh đạo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await taskController.fetchStats();
            await taskController.fetchTasks();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopFilters(isDark),
                const SizedBox(height: 16),
                _buildStatusGrid(isDark),
                const SizedBox(height: 24),
                _buildTimingGrid(isDark),
                const SizedBox(height: 24),
                _buildDoughnutChartsSection(isDark),
                const SizedBox(height: 24),
                _buildDetailedDistributionSection(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- FILTERS SECTION ---
  Widget _buildTopFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final startDate = taskController.startDate.value;
        final endDate = taskController.endDate.value;
        
        return Column(
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('Khoảng thời gian:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              DateTime? currentEnd = endDate != null ? DateTime.tryParse(endDate) : null;
                              taskController.setDateRange(picked, currentEnd);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(startDate ?? 'Từ ngày', style: TextStyle(fontSize: 11, color: startDate != null ? (isDark ? Colors.white : Colors.black) : Colors.grey), overflow: TextOverflow.ellipsis)),
                                Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('-', style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              DateTime? currentStart = startDate != null ? DateTime.tryParse(startDate) : null;
                              taskController.setDateRange(currentStart, picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(endDate ?? 'Đến ngày', style: TextStyle(fontSize: 11, color: endDate != null ? (isDark ? Colors.white : Colors.black) : Colors.grey), overflow: TextOverflow.ellipsis)),
                                Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.business_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                const Text('Đơn vị:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(width: 24),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: taskController.selectedDepartmentId.value,
                        hint: const Text('Tất cả phòng ban', style: TextStyle(fontSize: 12)),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[600]),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Tất cả phòng ban', style: TextStyle(fontSize: 12)),
                          ),
                          ...taskController.departments.map((dept) {
                            return DropdownMenuItem<int>(
                              value: dept.id,
                              child: Text(dept.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          taskController.setDepartment(value);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCardItem(String label, String value, Color textColor, Color bgColor, bool isDark) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          width: 0.5,
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : textColor.withOpacity(0.8),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TRẠNG THÁI XỬ LÝ GRID ---
  Widget _buildStatusGrid(bool isDark) {
    return Obx(() {
      final stats = taskController.stats;
      final total = stats['total'] ?? 0;
      final todo = (stats['todo'] ?? 0) as int;
      final inProgress = (stats['in_progress'] ?? 0) as int;
      final pendingApproval = (stats['pending_approval'] ?? 0) as int;
      final done = (stats['done'] ?? 0) as int;
      final paused = (stats['paused'] ?? 0) as int;
      final cancelled = (stats['cancelled'] ?? 0) as int;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRẠNG THÁI XỬ LÝ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildStatCardItem('Tổng công việc', total.toString(), const Color(0xFF8B5CF6), const Color(0xFFF5F3FF), isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _buildStatCardItem('Chưa thực hiện', todo.toString(), const Color(0xFF4B5563), const Color(0xFFF3F4F6), isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: _buildStatCardItem('Đang thực hiện', inProgress.toString(), const Color(0xFF0EA5E9), const Color(0xFFF0F9FF), isDark),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCardItem('Chờ duyệt', pendingApproval.toString(), const Color(0xFFD946EF), const Color(0xFFFDF4FF), isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCardItem('Hoàn thành', done.toString(), const Color(0xFF10B981), const Color(0xFFECFDF5), isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCardItem('Tạm dừng', paused.toString(), const Color(0xFFF59E0B), const Color(0xFFFFFBEB), isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCardItem('Đã hủy', cancelled.toString(), const Color(0xFF6B7280), const Color(0xFFF9FAFB), isDark),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });
  }

  // --- TIẾN ĐỘ CÔNG VIỆC GRID ---
  Widget _buildTimingGrid(bool isDark) {
    return Obx(() {
      final stats = taskController.stats;
      final timing = stats['timing_stats'] ?? {};
      final upcoming = (timing['upcoming'] ?? 0) as int;
      final early = (timing['early'] ?? 0) as int;
      final onTime = (timing['on_time'] ?? 0) as int;
      final late = (timing['late'] ?? 0) as int;
      final overdue = (timing['overdue'] ?? 0) as int;
      final timingCancelled = (timing['cancelled'] ?? 0) as int;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TIẾN ĐỘ CÔNG VIỆC',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCardItem('Chưa đến hạn', upcoming.toString(), const Color(0xFF0D9488), const Color(0xFFF0FDFA), isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCardItem('Sớm hạn', early.toString(), const Color(0xFF047857), const Color(0xFFECFDF5), isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCardItem('Đúng hạn', onTime.toString(), const Color(0xFF1D4ED8), const Color(0xFFEFF6FF), isDark),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCardItem('Trễ hạn', late.toString(), const Color(0xFFBE123C), const Color(0xFFFFF1F2), isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCardItem('Quá hạn', overdue.toString(), const Color(0xFF991B1B), const Color(0xFFFEF2F2), isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCardItem('Đã hủy', timingCancelled.toString(), const Color(0xFF6B7280), const Color(0xFFF9FAFB), isDark),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });
  }

  // --- DOUGHNUT CHARTS SECTION ---
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
                  const Text('Cơ cấ'
                      ''
                      ''
                      ''
                      ''
                      ''
                      ''
                      ''
                      ''
                      ''
                      ''
                      ''
                      ''
                      ''
                      'u Trạng thái', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  // --- PHÂN BỐ CHI TIẾT ---
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PHÂN BỐ CHI TIẾT',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
              ),
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

          _buildSegmentRow('UBND Phường', 5, 25, 24, [const Color(0xFF8B5CF6), const Color(0xFF0EA5E9), const Color(0xFF10B981)]),
          _buildSegmentRow('Công an Phường', 2, 10, 8, [const Color(0xFF8B5CF6), const Color(0xFF0EA5E9), const Color(0xFF10B981)]),
          _buildSegmentRow('Y tế Phường', 1, 8, 4, [const Color(0xFF8B5CF6), const Color(0xFF0EA5E9), const Color(0xFF10B981)]),
          _buildSegmentRow('Đội QLĐT', 3, 12, 10, [const Color(0xFF8B5CF6), const Color(0xFF0EA5E9), const Color(0xFF10B981)]),
          _buildSegmentRow('Tư pháp', 2, 6, 8, [const Color(0xFF8B5CF6), const Color(0xFF0EA5E9), const Color(0xFF10B981)]),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),

          const Text(
            '2. PHÂN BỐ THEO TIẾN ĐỘ THỜI GIAN',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          _buildSegmentRow('Mục 1', 6, 3, 1, [const Color(0xFF10B981), const Color(0xFFEF4444), const Color(0xFFEC4899)]),
          _buildSegmentRow('Mục 2', 1, 3, 1, [const Color(0xFF0EA5E9), const Color(0xFF10B981), const Color(0xFFEC4899)]),
          _buildSegmentRow('Mục 3', 1, 3, 1, [const Color(0xFF0EA5E9), const Color(0xFF10B981), const Color(0xFFEC4899)]),
          _buildSegmentRow('Mục 4', 2, 1, 3, [const Color(0xFF0EA5E9), const Color(0xFF4F46E5), const Color(0xFFEF4444)]),
          _buildSegmentRow('Mục 5', 1, 3, 2, [const Color(0xFF0EA5E9), const Color(0xFF10B981), const Color(0xFFEC4899), const Color(0xFFEF4444)], 1),
          _buildSegmentRow('Mục 6', 3, 4, 0, [const Color(0xFF10B981), const Color(0xFFEF4444)]),

          const SizedBox(height: 16),
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
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isActive ? const Color(0xFF2563EB) : Colors.grey[600]),
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
}
