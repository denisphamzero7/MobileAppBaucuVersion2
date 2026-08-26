import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_controller.dart';
import '../../../untils/app_colors.dart';

class StatisticDistributionWidget extends StatelessWidget {
  final TaskController taskController;
  final RxInt activeDistributionTab;
  final bool isDark;

  const StatisticDistributionWidget({
    super.key,
    required this.taskController,
    required this.activeDistributionTab,
    required this.isDark,
  });

  Widget _buildPillTabItem(String label, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? (isDark ? AppColors.cardDark : AppColors.white) : AppColors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isActive ? AppColors.primary : AppColors.grey[600]),
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

  Widget _buildStatusLegendGrid() {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDotLegend('Chưa thực hiện', AppColors.todo),
              const SizedBox(width: 8),
              _buildDotLegend('Đang thực hiện', AppColors.inProgress),
              const SizedBox(width: 8),
              _buildDotLegend('Chờ duyệt', AppColors.pendingApproval),
              const SizedBox(width: 8),
              _buildDotLegend('Hoàn thành', AppColors.done),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDotLegend('Tạm dừng', AppColors.paused),
            const SizedBox(width: 24),
            _buildDotLegend('Đã hủy', AppColors.cancelled),
          ],
        )
      ],
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
                    ? Container(color: AppColors.grey.withValues(alpha: 0.12))
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(24),
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
                    color: isDark ? AppColors.cardItemDark : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildPillTabItem('Phòng Ban', Icons.business_outlined, selectedTab == 0, () => activeDistributionTab.value = 0),
                      _buildPillTabItem('Loại CV', Icons.layers_outlined, selectedTab == 1, () => activeDistributionTab.value = 1),
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
                    ...taskController.departmentStatsList
                        .where((item) => ((item['total'] ?? 0) as num) > 0)
                        .map((item) {
                      final name = (item['department_name'] ?? item['name'] ?? item['department'] ?? 'Phòng ban').toString();
                      final todo = ((item['todo'] ?? item['todo_count'] ?? 0) as num).toInt();
                      final inProgress = ((item['in_progress'] ?? item['in_progress_count'] ?? 0) as num).toInt();
                      final pending = ((item['pending_approval'] ?? item['pending'] ?? 0) as num).toInt();
                      final done = ((item['done'] ?? item['completed'] ?? item['done_count'] ?? 0) as num).toInt();
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
                    _buildSegmentRow('Chưa có dữ liệu phòng ban', []),
                  ]
                ] else ...[
                  if (taskController.itemTypeStatsList.isNotEmpty)
                    ...taskController.itemTypeStatsList
                        .where((item) => ((item['total'] ?? 0) as num) > 0)
                        .map((item) {
                      final name = (item['task_assignment_item_type_name'] ?? item['item_type_name'] ?? item['type_name'] ?? item['name'] ?? item['title'] ?? 'Loại công việc').toString();
                      final todo = ((item['todo'] ?? item['todo_count'] ?? 0) as num).toInt();
                      final inProgress = ((item['in_progress'] ?? item['in_progress_count'] ?? 0) as num).toInt();
                      final pending = ((item['pending_approval'] ?? item['pending'] ?? 0) as num).toInt();
                      final done = ((item['done'] ?? item['completed'] ?? item['done_count'] ?? 0) as num).toInt();
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
                    _buildSegmentRow('Chưa có dữ liệu loại công việc', []),
                  ]
                ],

                const SizedBox(height: 12),
                _buildStatusLegendGrid(),

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
                    ...taskController.departmentStatsList
                        .where((item) => ((item['total'] ?? 0) as num) > 0)
                        .map((item) {
                      final name = (item['department_name'] ?? item['name'] ?? item['department'] ?? 'Phòng ban').toString();
                      final timing = (item['timing_stats'] is Map<String, dynamic>)
                          ? item['timing_stats'] as Map<String, dynamic>
                          : <String, dynamic>{};
                      final upcoming = ((timing['upcoming'] ?? item['upcoming'] ?? 0) as num).toInt();
                      final early = ((timing['early'] ?? item['early'] ?? 0) as num).toInt();
                      final onTime = ((timing['on_time'] ?? item['on_time'] ?? 0) as num).toInt();
                      final lateVal = ((timing['late'] ?? item['late'] ?? 0) as num).toInt();
                      final overdue = ((timing['overdue'] ?? item['overdue'] ?? 0) as num).toInt();
                      final cancelled = ((timing['cancelled'] ?? item['cancelled'] ?? 0) as num).toInt();

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
                    _buildSegmentRow('Chưa có dữ liệu tiến độ', []),
                  ]
                ] else ...[
                  if (taskController.itemTypeStatsList.isNotEmpty)
                    ...taskController.itemTypeStatsList
                        .where((item) => ((item['total'] ?? 0) as num) > 0)
                        .map((item) {
                      final name = (item['task_assignment_item_type_name'] ?? item['item_type_name'] ?? item['type_name'] ?? item['name'] ?? item['title'] ?? 'Loại công việc').toString();
                      final timing = (item['timing_stats'] is Map<String, dynamic>)
                          ? item['timing_stats'] as Map<String, dynamic>
                          : <String, dynamic>{};
                      final upcoming = ((timing['upcoming'] ?? item['upcoming'] ?? 0) as num).toInt();
                      final early = ((timing['early'] ?? item['early'] ?? 0) as num).toInt();
                      final onTime = ((timing['on_time'] ?? item['on_time'] ?? 0) as num).toInt();
                      final lateVal = ((timing['late'] ?? item['late'] ?? 0) as num).toInt();
                      final overdue = ((timing['overdue'] ?? item['overdue'] ?? 0) as num).toInt();
                      final cancelled = ((timing['cancelled'] ?? item['cancelled'] ?? 0) as num).toInt();

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
                    _buildSegmentRow('Chưa có dữ liệu tiến độ', []),
                  ]
                ],

                const SizedBox(height: 12),
                _buildTimingLegendGrid(),
              ],
            );
          }),
        ],
      ),
    );
  }
}
