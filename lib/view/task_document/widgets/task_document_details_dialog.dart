import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/task_assignment_document_model.dart';
import '../../../service/task_assignment_documents_service.dart';
import '../../../untils/app_colors.dart';
import '../../../helper/date_helper.dart';

class TaskDocumentDetailsBottomSheet extends StatelessWidget {
  final TaskAssignmentDocumentModel document;
  final bool isDark;
  final VoidCallback onRefreshParent;
  final Function(TaskAssignmentDocumentModel doc) onEditDocument;

  const TaskDocumentDetailsBottomSheet({
    super.key,
    required this.document,
    required this.isDark,
    required this.onRefreshParent,
    required this.onEditDocument,
  });

  static void show(
    BuildContext context, {
    required TaskAssignmentDocumentModel document,
    required bool isDark,
    required VoidCallback onRefreshParent,
    required Function(TaskAssignmentDocumentModel doc) onEditDocument,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TaskDocumentDetailsBottomSheet(
        document: document,
        isDark: isDark,
        onRefreshParent: onRefreshParent,
        onEditDocument: onEditDocument,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final service = TaskAssignmentDocumentsService();
    Get.defaultDialog(
      title: 'Xác nhận xóa',
      middleText: 'Bạn có chắc chắn muốn xóa văn bản "${document.title}"?',
      textConfirm: 'Xóa',
      textCancel: 'Hủy',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        Navigator.pop(context);
        final success = await service.deleteDocument(document.id);
        if (success) {
          onRefreshParent();
          Get.snackbar(
            'Thành công',
            'Đã xóa văn bản giao việc thành công',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.done,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar('Lỗi', 'Không thể xóa văn bản này', backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.white24 : AppColors.borderGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  document.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textHeading,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.white10 : AppColors.borderLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: isDark ? AppColors.white70 : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.white10 : AppColors.borderGrey,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trạng thái row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TRẠNG THÁI VĂN BẢN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.white70 : AppColors.textMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: document.isPublished ? AppColors.badgeGreenBg : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        document.isPublished ? 'Đã ban hành' : 'Bản nháp',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: document.isPublished ? AppColors.textGreen : AppColors.warningOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2 Cột: Loại văn bản & Ngày ban hành
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.category_outlined,
                        label: 'LOẠI VĂN BẢN',
                        value: document.typeName ?? 'Văn bản',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'NGÀY BAN HÀNH',
                        value: DateHelper.formatDate(document.documentDate, fallback: '-'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2 Cột: Số lượng công việc & Tiến độ
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.layers_outlined,
                        label: 'SỐ LƯỢNG CÔNG VIỆC',
                        value: '${document.taskCount} công việc',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.pie_chart_outline,
                        label: 'TIẾN ĐỘ THỰC HIỆN',
                        value: '${document.completionPercent}%',
                      ),
                    ),
                  ],
                ),
                if (document.description != null && document.description!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildInfoItem(
                    icon: Icons.subject,
                    label: 'TRÍCH YẾU / NỘI DUNG',
                    value: document.description!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Bottom buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.white10 : AppColors.badgeBlueBg,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onEditDocument(document);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Sửa văn bản', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.dangerBg.withValues(alpha: 0.2) : AppColors.dangerBg,
                      foregroundColor: AppColors.dangerText,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Xóa văn bản', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: isDark ? AppColors.white70 : AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white70 : AppColors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.textMain,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
