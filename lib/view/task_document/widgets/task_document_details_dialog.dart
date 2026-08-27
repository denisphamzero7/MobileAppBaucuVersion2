import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/task_assignment_document_model.dart';
import '../../../model/task_model.dart';
import '../../../service/task_assignment_documents_service.dart';
import '../../../service/task_service.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_textstyles.dart';
import '../../task/widgets/task_card_widget.dart';
import '../../widgets/skeleton_loader.dart';

class TaskDocumentDetailsBottomSheet extends StatefulWidget {
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

  @override
  State<TaskDocumentDetailsBottomSheet> createState() => _TaskDocumentDetailsBottomSheetState();
}

class _TaskDocumentDetailsBottomSheetState extends State<TaskDocumentDetailsBottomSheet> {
  final TaskService _taskService = TaskService();
  bool _isLoading = true;
  List<TaskModel> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchDocumentTasks();
  }

  Future<void> _fetchDocumentTasks() async {
    setState(() => _isLoading = true);
    try {
      final response = await _taskService.getTasks(
        documentId: widget.document.id,
        limit: 100,
      );
      if (response != null && response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _tasks = response.data;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _tasks = [];
        _isLoading = false;
      });
    }
  }

  void _confirmDelete(BuildContext context) {
    final service = TaskAssignmentDocumentsService();
    Get.defaultDialog(
      title: 'Xác nhận xóa',
      middleText: 'Bạn có chắc chắn muốn xóa văn bản "${widget.document.title}"?',
      textConfirm: 'Xóa',
      textCancel: 'Hủy',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        Navigator.pop(context);
        final success = await service.deleteDocument(widget.document.id);
        if (success) {
          widget.onRefreshParent();
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
                color: widget.isDark ? AppColors.white24 : AppColors.borderGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.document.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? AppColors.white : AppColors.textHeading,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DANH SÁCH CÔNG VIỆC THUỘC VĂN BẢN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppColors.white10 : AppColors.borderLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: widget.isDark ? AppColors.white70 : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Danh sách công việc
          Expanded(
            child: _isLoading
                ? ListView.separated(
                    itemCount: 3,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => const SkeletonLoader(
                      child: SkeletonBox(
                        width: double.infinity,
                        height: 68,
                        radius: 16,
                      ),
                    ),
                  )
                : _tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 42, color: AppColors.grey[400]),
                            const SizedBox(height: 10),
                            Text(
                              'Không có công việc nào thuộc văn bản này',
                              style: AppTextStyle.cardSubtitle.copyWith(
                                color: AppColors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return TaskCardWidget(
                            task: task,
                            isDark: widget.isDark,
                            primaryColor: AppColors.primary,
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),

          // Bottom buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isDark ? AppColors.white10 : AppColors.badgeBlueBg,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onEditDocument(widget.document);
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
                      backgroundColor: widget.isDark ? AppColors.dangerBg.withValues(alpha: 0.2) : AppColors.dangerBg,
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
}
