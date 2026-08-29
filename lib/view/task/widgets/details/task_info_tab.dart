import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../model/task_model.dart';
import '../../../../untils/app_colors.dart';
import '../../../../helper/date_helper.dart';
import '../../../../core/utils/app_file_downloader.dart';

class TaskInfoTab extends StatefulWidget {
  final TaskModel task;
  final bool isDark;

  const TaskInfoTab({
    super.key,
    required this.task,
    required this.isDark,
  });

  @override
  State<TaskInfoTab> createState() => _TaskInfoTabState();
}

class _TaskInfoTabState extends State<TaskInfoTab> {
  bool _isDescriptionExpanded = false;

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return 'Chưa thực hiện';
      case 'pending_approval':
      case 'pending':
        return 'Chờ duyệt';
      case 'in_progress':
      case 'processing':
        return 'Đang thực hiện';
      case 'completed':
      case 'done':
        return 'Hoàn thành';
      case 'paused':
        return 'Tạm dừng';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 'Khẩn cấp';
      case 'high':
        return 'Cao';
      case 'medium':
        return 'Trung bình';
      case 'low':
      default:
        return 'Thấp';
    }
  }

  String _getTimingStatusLabel(TaskModel task) {
    if (task.isOverdue || task.timingStatus == 'overdue') {
      return 'Quá hạn';
    }
    switch (task.timingStatus.toLowerCase()) {
      case 'late':
        return 'Trễ hạn';
      case 'early':
        return 'Sớm hạn';
      case 'on_time':
        return 'Đúng hạn';
      case 'upcoming':
      default:
        return 'Chưa đến hạn';
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDark = widget.isDark;

    // Danh sách tệp đính kèm thật từ API
    final List<TaskAttachment> attachments = task.attachmentList ?? [];

    // Danh sách nhắc lịch thật từ API
    final List<TaskReminder> reminders = task.reminderList ?? [];

    return Container(
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
          // 1. MÔ TẢ CÔNG VIỆC
          if (task.description.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.description_outlined, size: 15, color: AppColors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  'MÔ TẢ CÔNG VIỆC',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey[500],
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              task.description,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: isDark ? AppColors.white70 : AppColors.black87,
              ),
              maxLines: _isDescriptionExpanded ? null : 3,
              overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
            ),
            InkWell(
              onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 2. LƯỚI THÔNG TIN 2 CỘT
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cột trái
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      icon: Icons.work_outline,
                      label: 'LOẠI CÔNG VIỆC',
                      value: task.itemTypeName ?? 'Chưa phân loại',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      icon: Icons.access_time,
                      label: 'THỜI HẠN CÔNG VIỆC',
                      value: task.deadlineType == 'no_deadline' ? 'Không thời hạn' : 'Có thời hạn',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'NGÀY BẮT ĐẦU',
                      value: DateHelper.formatDate(task.startAt, fallback: '-'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      icon: Icons.person_outline,
                      label: 'NGƯỜI QUẢN LÝ',
                      value: task.assignerName ?? 'Không có',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      icon: Icons.warning_amber_rounded,
                      label: 'TÌNH TRẠNG',
                      value: _getTimingStatusLabel(task),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Cột phải
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      icon: Icons.electric_bolt_outlined,
                      label: 'TRẠNG THÁI',
                      value: _getStatusLabel(task.processingStatus),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      icon: Icons.local_fire_department_outlined,
                      label: 'ƯU TIÊN',
                      value: _getPriorityLabel(task.priority),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'NGÀY KẾT THÚC',
                      value: DateHelper.formatDate(task.endAt, fallback: '-'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      icon: Icons.person_outline,
                      label: 'NGƯỜI THỰC HIỆN',
                      value: task.assigneeName ?? 'Không có',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. NHẮC LỊCH
          Row(
            children: [
              Icon(Icons.notifications_none_outlined, size: 14, color: AppColors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'NHẮC LỊCH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey[500],
                  letterSpacing: 0.4,
                ),
              ),
              if (reminders.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.bgYellowLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${reminders.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCA8A04),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          if (reminders.isEmpty)
            Text(
              task.reminder != null && task.reminder!.isNotEmpty ? task.reminder! : 'Không có nhắc lịch',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.white70 : AppColors.grey[600]),
            )
          else
            ...reminders.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Color(0xFFEAB308)),
                      const SizedBox(width: 6),
                      Text(
                        r.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.white : AppColors.black87,
                        ),
                      ),
                      if (r.detailTime != null && r.detailTime!.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${r.detailTime})',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.white70 : AppColors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
          const SizedBox(height: 14),

          // 4. TỆP ĐÍNH KÈM
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
          if (attachments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Không có tệp đính kèm',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.white70 : AppColors.grey[500]),
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
                      const Icon(Icons.link, size: 18, color: AppColors.primary),
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
                          AppFileDownloader.downloadAndOpen(
                            fileUrl: fileUrl,
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

          // 8. DANH SÁCH BÁO CÁO TIẾN ĐỘ (GIỐNG WEB)
          () {
            final infoReports = (task.progressReports != null && task.progressReports!.isNotEmpty)
                ? task.progressReports!
                : (task.completionPercent > 0
                    ? [
                        TaskProgressReport(
                          percent: task.completionPercent,
                          date: task.createdAt,
                          note: 'Tiến độ ghi nhận',
                        )
                      ]
                    : <TaskProgressReport>[]);

            if (infoReports.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Danh sách báo cáo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white70 : AppColors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.badgeBlueBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${infoReports.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 14,
                  children: infoReports.map((item) {
                    final percent = item.percent;
                    final dateStr = DateHelper.formatDate(item.date, fallback: item.date.isNotEmpty ? item.date : '-');
                    final ringColor = percent >= 100 ? AppColors.done : const Color(0xFF10B981);

                    return Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                value: (percent.clamp(0, 100)) / 100.0,
                                strokeWidth: 3.5,
                                backgroundColor: isDark ? AppColors.white10 : AppColors.lightBg,
                                valueColor: AlwaysStoppedAnimation<Color>(ringColor),
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
                            color: isDark ? AppColors.cardDark : AppColors.badgeGreenBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.done,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            );
          }(),
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
