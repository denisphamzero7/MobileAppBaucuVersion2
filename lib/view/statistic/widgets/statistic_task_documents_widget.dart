import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_controller.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_textstyles.dart';
import '../../../core/widgets/app_pagination_widget.dart';
import '../../widgets/skeleton_loader.dart';
import '../../task_document/widgets/task_document_card.dart';
import '../../task_document/widgets/task_document_details_dialog.dart';
import '../../task_document/widgets/task_document_form_modal.dart';

class StatisticTaskDocumentsWidget extends StatelessWidget {
  final TaskController taskController;
  final RxInt documentPage;
  final int docsPerPage;
  final bool isDark;

  const StatisticTaskDocumentsWidget({
    super.key,
    required this.taskController,
    required this.documentPage,
    this.docsPerPage = 5,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final docs = taskController.taskDocuments;
      final isLoading = taskController.isDocumentsLoading.value;

      final int totalItems = docs.length;
      final int totalPages = (totalItems / docsPerPage).ceil().clamp(1, 9999);
      if (documentPage.value > totalPages) {
        documentPage.value = totalPages;
      }
      final int startIndex = (documentPage.value - 1) * docsPerPage;
      final pagedDocs = docs.skip(startIndex).take(docsPerPage).toList();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TIÊU ĐỀ KHỐI
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'DANH SÁCH VĂN BẢN GIAO VIỆC',
                          style: AppTextStyle.cardTitle.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalItems văn bản',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2. DANH SÁCH VĂN BẢN (TÁI SỬ DỤNG TASKDOCUMENTCARD)
            if (isLoading && docs.isEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, __) => const SkeletonBox(
                  width: double.infinity,
                  height: 72,
                  radius: 14,
                ),
              )
            else if (pagedDocs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.folder_open_outlined, size: 36, color: AppColors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Chưa có văn bản giao việc nào',
                        style: TextStyle(fontSize: 12.5, color: AppColors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pagedDocs.length,
                itemBuilder: (context, index) {
                  final doc = pagedDocs[index];
                  return TaskDocumentCard(
                    document: doc,
                    isDark: isDark,
                    isSelected: false,
                    isMultiSelectMode: false,
                    onTap: () {
                      TaskDocumentDetailsBottomSheet.show(
                        context,
                        document: doc,
                        isDark: isDark,
                        onRefreshParent: () => taskController.fetchTaskDocuments(),
                        onEditDocument: (d) {
                          TaskDocumentFormModal.show(
                            context,
                            docToEdit: d,
                            onSaved: () => taskController.fetchTaskDocuments(),
                          );
                        },
                      );
                    },
                    onLongPress: () {},
                  );
                },
              ),

            // 3. PHÂN TRANG (TÁI SỬ DỤNG APPPAGINATIONWIDGET)
            if (totalItems > 0) ...[
              const SizedBox(height: 12),
              AppPaginationWidget(
                currentPage: documentPage.value,
                totalPages: totalPages,
                totalItems: totalItems,
                itemsPerPage: docsPerPage,
                isLoading: isLoading,
                onPageChanged: (newPage) {
                  documentPage.value = newPage;
                },
              ),
            ],
          ],
        ),
      );
    });
  }
}
