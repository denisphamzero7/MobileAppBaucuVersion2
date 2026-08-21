import 'package:flutter/material.dart';
import '../../../../model/task_model.dart';
import '../../../../untils/app_colors.dart';

class TaskReportTab extends StatelessWidget {
  final TaskModel task;
  final bool isDark;
  final VoidCallback onAddReport;

  const TaskReportTab({
    super.key,
    required this.task,
    required this.isDark,
    required this.onAddReport,
  });

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '-';
    final trimmed = raw.trim();
    try {
      if (trimmed.contains(' ')) {
        final parts = trimmed.split(' ');
        if (parts.length >= 2) {
          if (parts[0].contains('-')) {
            final dateParts = parts[0].split('-');
            if (dateParts.length == 3) {
              return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
            }
          }
          return parts[0];
        }
      } else if (trimmed.contains('-')) {
        final dateParts = trimmed.split('-');
        if (dateParts.length == 3) {
          return '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
        }
      }
    } catch (_) {}
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final reports = task.progressReports ?? [];

    if (reports.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardItemDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 54, color: isDark ? AppColors.white24 : AppColors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Chưa có báo cáo tiến độ nào được nộp',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.white70 : AppColors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: onAddReport,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nộp báo cáo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardItemDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch sử báo cáo (${reports.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white70 : AppColors.grey[700],
                ),
              ),
              InkWell(
                onTap: onAddReport,
                child: const Text(
                  '+ Nộp báo cáo',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: reports.map((item) {
              final percent = item.percent;
              final dateStr = _formatDate(item.date);
              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          value: (percent.clamp(0, 100)) / 100.0,
                          strokeWidth: 4,
                          backgroundColor: isDark ? AppColors.white10 : AppColors.badgeBlueBg,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white70 : AppColors.grey[700],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
