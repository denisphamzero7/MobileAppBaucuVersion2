import 'package:flutter/material.dart';
import '../../../../model/task_model.dart';
import '../../../../untils/app_colors.dart';
import '../../../../helper/date_helper.dart';
import '../../../../core/utils/app_file_downloader.dart';

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
    final List<TaskAttachment> attachments = task.attachmentList ?? [];

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
          // 1. TIÊU ĐỀ VĂN BẢN
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

          // 2. MÃ VĂN BẢN
          _buildInfoItem(
            icon: Icons.confirmation_number_outlined,
            label: 'MÃ / SỐ VĂN BẢN',
            value: task.taskAssignmentDocumentId != null ? 'VB-${task.taskAssignmentDocumentId}' : 'Chưa gắn mã',
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // 3. NGÀY BAN HÀNH
          _buildInfoItem(
            icon: Icons.calendar_today_outlined,
            label: 'NGÀY BAN HÀNH',
            value: DateHelper.formatDate(task.createdAt, fallback: '-'),
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // 4. TIÊU ĐỀ TỆP ĐÍNH KÈM
          Row(
            children: [
              Icon(Icons.attach_file, size: 14, color: AppColors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'TỆP ĐÍNH KÈM (${attachments.length})',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey[500],
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 5. DANH SÁCH TỆP HOẶC TRẠNG THÁI CHƯA CÓ TỆP
          if (attachments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Chưa có tệp đính kèm',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.white70 : AppColors.grey[500],
                ),
              ),
            )
          else
            ...attachments.map((file) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.badgeBlueBg.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.white10 : AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: AppColors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          file.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          final fileUrl = file.url ?? file.path ?? '';
                          final url = fileUrl.isNotEmpty
                              ? fileUrl
                              : (task.taskAssignmentDocumentId != null
                                  ? 'task-assignment-documents/${task.taskAssignmentDocumentId}/download'
                                  : '');
                          AppFileDownloader.downloadAndOpen(
                            fileUrl: url,
                            customFileName: file.name,
                          );
                        },
                        child: const Text(
                          'Mở / Tải về',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
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
