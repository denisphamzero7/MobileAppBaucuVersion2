import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/task_controller.dart';
import '../../../untils/app_colors.dart';

class StatisticDoughnutChartsWidget extends StatelessWidget {
  final TaskController taskController;
  final bool isDark;

  const StatisticDoughnutChartsWidget({
    super.key,
    required this.taskController,
    required this.isDark,
  });

  String _getPercentStr(int value, int totalVal) {
    if (totalVal == 0) return '0%';
    final double percent = (value / totalVal) * 100;
    return '${percent.round()}%';
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = taskController.stats.value;
      final total = stats.total;

      // Status Stats values
      final todo = stats.todo;
      final inProgress = stats.inProgress;
      final pendingApproval = stats.pendingApproval;
      final done = stats.done;
      final paused = stats.paused;
      final cancelled = stats.cancelled;

      // Timing Stats values
      final timing = stats.timingStats;
      final upcoming = timing.upcoming;
      final early = timing.early;
      final onTime = timing.onTime;
      final late = timing.late;
      final overdue = timing.overdue;
      final timingCancelled = timing.cancelled;

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

      final timingTotal = upcoming + early + onTime + late + overdue + timingCancelled;

      // Doughnut Sections for Timing Structure
      final List<PieChartSectionData> timingSections = [];
      if (timingTotal == 0) {
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
                    color: AppColors.black.withValues(alpha: 0.02),
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
                  _buildLegendItem('Chưa thực hiện', '$todo (${_getPercentStr(todo, total)})', AppColors.todo),
                  _buildLegendItem('Đang thực hiện', '$inProgress (${_getPercentStr(inProgress, total)})', AppColors.inProgress),
                  _buildLegendItem('Chờ duyệt', '$pendingApproval (${_getPercentStr(pendingApproval, total)})', AppColors.pendingApproval),
                  _buildLegendItem('Hoàn thành', '$done (${_getPercentStr(done, total)})', AppColors.done),
                  _buildLegendItem('Tạm dừng', '$paused (${_getPercentStr(paused, total)})', AppColors.paused),
                  _buildLegendItem('Đã hủy', '$cancelled (${_getPercentStr(cancelled, total)})', AppColors.cancelled),
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
                    color: AppColors.black.withValues(alpha: 0.02),
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
                  Center(child: _buildDoughnut(timingSections, timingTotal)),
                  const SizedBox(height: 16),
                  _buildLegendItem('Chưa đến hạn', '$upcoming (${_getPercentStr(upcoming, timingTotal)})', AppColors.inProgress),
                  _buildLegendItem('Sớm hạn', '$early (${_getPercentStr(early, timingTotal)})', AppColors.done),
                  _buildLegendItem('Đúng hạn', '$onTime (${_getPercentStr(onTime, timingTotal)})', AppColors.onTime),
                  _buildLegendItem('Trễ hạn', '$late (${_getPercentStr(late, timingTotal)})', AppColors.late),
                  _buildLegendItem('Quá hạn', '$overdue (${_getPercentStr(overdue, timingTotal)})', AppColors.overdue),
                  _buildLegendItem('Đã hủy', '$timingCancelled (${_getPercentStr(timingCancelled, timingTotal)})', AppColors.cancelled),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
