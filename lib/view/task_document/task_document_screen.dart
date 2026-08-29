import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_document_controller.dart';
import '../../model/task_assignment_document_model.dart';
import '../../untils/app_colors.dart';
import '../../untils/app_strings.dart';
import '../../core/widgets/app_pagination_widget.dart';
import '../../core/widgets/app_paged_list_wrapper.dart';
import '../../core/widgets/import_excel_button.dart';
import '../../view/widgets/skeleton_loader.dart';
import '../../view/widgets/smart_skeleton_wrapper.dart';
import '../../view/widgets/quick_action_bottom_sheet.dart';
import 'widgets/task_document_card.dart';
import 'widgets/task_document_details_dialog.dart';
import 'widgets/task_document_form_modal.dart';
import 'widgets/task_document_stats_grid_widget.dart';
import 'widgets/task_document_search_filter_bar.dart';

class TaskDocumentScreen extends StatefulWidget {
  const TaskDocumentScreen({super.key});

  @override
  State<TaskDocumentScreen> createState() => _TaskDocumentScreenState();
}

class _TaskDocumentScreenState extends State<TaskDocumentScreen> {
  final TaskDocumentController controller = Get.isRegistered<TaskDocumentController>()
      ? Get.find<TaskDocumentController>()
      : Get.put(TaskDocumentController());

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openQuickActions(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final canCreate = authCtrl.can('create', 'TaskAssignmentDocuments');
    final canDelete = authCtrl.can('destroy', 'TaskAssignmentDocuments');
    final canExport = authCtrl.can('read', 'TaskAssignmentDocuments');

    final List<QuickActionItem> items = [];

    if (canCreate) {
      items.add(
        QuickActionItem(
          title: 'Tạo văn bản mới',
          subtitle: 'Thêm & phân công',
          icon: Icons.note_add_rounded,
          color: AppColors.primary,
          onTap: () => TaskDocumentFormModal.show(
            context,
            departments: controller.departments,
            onSaved: () => controller.onRefresh(),
          ),
        ),
      );
      items.add(
        QuickActionItem(
          title: 'Nhập Excel',
          subtitle: 'Tải danh sách văn bản',
          icon: Icons.upload_file_rounded,
          color: Colors.green,
          onTap: () {
            ImportExcelButton.pickAndUpload(
              uploadUrl: 'task-assignment-documents/import',
              onSuccess: () => controller.onRefresh(),
            );
          },
        ),
      );
    }

    if (canExport) {
      items.add(
        QuickActionItem(
          title: 'Xuất Excel',
          subtitle: 'Tải danh sách ra máy',
          icon: Icons.download_rounded,
          color: Colors.orange,
          onTap: () => controller.exportExcel(),
        ),
      );
    }

    if (canDelete) {
      items.add(
        QuickActionItem(
          title: controller.isMultiSelectMode.value ? 'Hủy chọn nhiều' : 'Xóa đã chọn',
          subtitle: 'Xóa nhiều văn bản cùng lúc',
          icon: controller.isMultiSelectMode.value ? Icons.close_rounded : Icons.checklist_rtl_rounded,
          color: Colors.purple,
          badge: controller.selectedDocIds.isNotEmpty ? '${controller.selectedDocIds.length}' : null,
          onTap: () => controller.toggleMultiSelectMode(),
        ),
      );
    }

    if (items.isEmpty) {
      Get.snackbar('Thông báo', 'Bạn không có quyền thực hiện tác vụ này.');
      return;
    }

    QuickActionBottomSheet.show(
      context,
      title: 'Chi tiết văn bản',
      subtitle: 'Chọn tác vụ bạn muốn thực hiện',
      items: items,
    );
  }

  void _showDocumentDetails(BuildContext context, TaskAssignmentDocumentModel doc, bool isDark) {
    TaskDocumentDetailsBottomSheet.show(
      context,
      document: doc,
      isDark: isDark,
      onRefreshParent: () => controller.onRefresh(),
      onEditDocument: (d) => TaskDocumentFormModal.show(
        context,
        docToEdit: d,
        departments: controller.departments,
        onSaved: () => controller.onRefresh(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authCtrl = Get.find<AuthController>();
    final canDelete = authCtrl.can('destroy', 'TaskAssignmentDocuments');

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () => Get.find<NavigationController>().changeIndex(0),
        ),
        title: const Text(
          AppStrings.taskDocumentScreenTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            if (controller.isMultiSelectMode.value) {
              return IconButton(
                icon: const Icon(Icons.close, size: 22),
                tooltip: 'Thoát chọn nhiều',
                onPressed: () => controller.toggleMultiSelectMode(),
              );
            }
            return QuickActionButton(
              tooltip: 'Thao tác nhanh',
              onPressed: () => _openQuickActions(context),
            );
          }),
        ],
        elevation: 0,
        backgroundColor: isDark ? AppColors.black : AppColors.white,
        foregroundColor: isDark ? AppColors.white : AppColors.black87,
      ),
      floatingActionButton: Obx(() {
        if (controller.isMultiSelectMode.value && controller.selectedDocIds.isNotEmpty && canDelete) {
          return FloatingActionButton.extended(
            onPressed: () {
              Get.defaultDialog(
                title: 'Xác nhận xóa',
                middleText: 'Bạn có chắc chắn muốn xóa ${controller.selectedDocIds.length} văn bản này?',
                textConfirm: 'Xóa',
                textCancel: 'Hủy',
                confirmTextColor: Colors.white,
                buttonColor: AppColors.dangerText,
                onConfirm: () {
                  Get.back();
                  controller.bulkDeleteSelected();
                },
              );
            },
            backgroundColor: Colors.red,
            icon: const Icon(Icons.delete, color: Colors.white),
            label: Text(
              'Xóa (${controller.selectedDocIds.length})',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
      body: SafeArea(
        child: Obx(() {
          final filteredDocs = controller.getFilteredDocuments();
          final totalItems = filteredDocs.length;
          final totalPages = (totalItems / TaskDocumentController.perPage).ceil().clamp(1, 9999);

          if (controller.currentPage.value > totalPages) {
            controller.currentPage.value = totalPages;
          }

          final startIndex = (controller.currentPage.value - 1) * TaskDocumentController.perPage;
          final pagedDocs = filteredDocs.skip(startIndex).take(TaskDocumentController.perPage).toList();

          return SmartSkeletonWrapper(
            showSkeleton: controller.isLoading.value && (controller.allDocuments.isEmpty || controller.isManualRefreshing.value),
            skeleton: AppSkeleton.fullPageLayout(
              statusGridCount: 3,
              statusGridCols: 3,
              statusGridRatio: 2.2,
              timingGridCount: 0,
              cardCount: 5,
              cardHeight: 68,
            ),
            onRefresh: () => controller.onRefresh(),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. THANH TÌM KIẾM & BỘ LỌC
                  TaskDocumentSearchFilterBar(
                    controller: controller,
                    searchController: _searchController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),

                  // 2. THỐNG KÊ TRẠNG THÁI VĂN BẢN (3 Cards)
                  TaskDocumentStatsGridWidget(
                    controller: controller,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),

                  // 3. DANH SÁCH VĂN BẢN GIAO VIỆC
                  if (pagedDocs.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 54,
                            color: isDark ? AppColors.white30 : AppColors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppStrings.noTaskDocumentsFound,
                            style: TextStyle(
                              color: isDark ? AppColors.white70 : AppColors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    AppPagedListWrapper(
                      isChangingPage: controller.isPageChanging.value,
                      skeleton: AppSkeleton.listCards(count: 5, height: 68),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pagedDocs.length,
                        itemBuilder: (ctx, idx) {
                          final doc = pagedDocs[idx];
                          return Obx(() {
                            final isSelected = controller.selectedDocIds.contains(doc.id);
                            final isMulti = controller.isMultiSelectMode.value;

                            final cardWidget = TaskDocumentCard(
                              document: doc,
                              isDark: isDark,
                              isSelected: isSelected,
                              isMultiSelectMode: isMulti,
                              onToggleSelect: () => controller.toggleDocumentSelection(doc.id),
                              onTap: () {
                                if (isMulti) {
                                  controller.toggleDocumentSelection(doc.id);
                                } else {
                                  _showDocumentDetails(context, doc, isDark);
                                }
                              },
                              onLongPress: () {
                                if (!isMulti) {
                                  controller.isMultiSelectMode.value = true;
                                  controller.toggleDocumentSelection(doc.id);
                                }
                              },
                            );

                            if (isMulti || !canDelete) {
                              return cardWidget;
                            }

                            return Dismissible(
                              key: ValueKey('task_doc_${doc.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await Get.defaultDialog<bool>(
                                  title: 'Xác nhận xóa',
                                  middleText: 'Bạn có chắc chắn muốn xóa văn bản "${doc.title}"?',
                                  textConfirm: 'Xóa',
                                  textCancel: 'Hủy',
                                  confirmTextColor: Colors.white,
                                  buttonColor: AppColors.dangerText,
                                  onConfirm: () => Get.back(result: true),
                                  onCancel: () => Get.back(result: false),
                                );
                              },
                              onDismissed: (direction) {
                                controller.deleteSingleDocument(doc.id);
                              },
                              child: cardWidget,
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. PHÂN TRANG
                    AppPaginationWidget(
                      currentPage: controller.currentPage.value,
                      totalPages: totalPages,
                      totalItems: totalItems,
                      itemsPerPage: TaskDocumentController.perPage,
                      isLoading: controller.isPageChanging.value,
                      onPageChanged: (newPage) => controller.changePage(newPage, _scrollController),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
