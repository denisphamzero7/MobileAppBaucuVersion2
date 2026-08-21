import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../model/task_model.dart';
import '../../../../untils/app_colors.dart';
import '../../../../helper/date_helper.dart';

class TaskDocumentTab extends StatelessWidget {
  final TaskModel task;
  final bool isDark;

  const TaskDocumentTab({
    super.key,
    required this.task,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final docTitle = task.documentName ?? 'Văn bản giao việc';

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
            children: [
              const Icon(Icons.folder_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  docTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.black87,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoItem(
            icon: Icons.confirmation_number_outlined,
            label: 'MÃ / SỐ VĂN BẢN',
            value: task.taskAssignmentDocumentId != null ? 'VB-${task.taskAssignmentDocumentId}' : 'Chưa gắn mã',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.calendar_today_outlined,
            label: 'NGÀY BAN HÀNH',
            value: DateHelper.formatDate(task.createdAt, fallback: '-'),
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.badgeBlueBg.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: AppColors.red, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '1.pdf',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.snackbar('Tải tệp', 'Đang mở tệp văn bản');
                  },
                  child: const Text(
                    'Mở / Tải về',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppColors.grey[500]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.grey[500],
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
