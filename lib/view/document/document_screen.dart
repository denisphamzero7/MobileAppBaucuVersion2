import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/petition_controller.dart';
import '../../untils/app_colors.dart';
import '../../helper/date_helper.dart';
import '../../service/petition_service.dart';
import '../../core/widgets/import_excel_button.dart';
import '../../core/widgets/app_pagination_widget.dart';
import '../../core/widgets/app_paged_list_wrapper.dart';
import '../../view/widgets/quick_action_bottom_sheet.dart';
import '../../view/widgets/skeleton_loader.dart';
import '../../view/widgets/smart_skeleton_wrapper.dart';
import 'widgets/petition_details_dialog.dart';
import 'widgets/petition_card_widget.dart';
import 'widgets/petition_form_modal.dart';
import 'widgets/petition_stats_grid_widget.dart';
import 'widgets/petition_search_filter_bar.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final PetitionController controller = Get.isRegistered<PetitionController>()
      ? Get.find<PetitionController>()
      : Get.put(PetitionController());

  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _openQuickActions(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final canCreate = authCtrl.can('create', 'TaskAssignmentPetitions');
    final canDelete = authCtrl.can('destroy', 'TaskAssignmentPetitions');
    final canExport = authCtrl.can('read', 'TaskAssignmentPetitions');

    final List<QuickActionItem> items = [];

    if (canCreate) {
      items.add(
        QuickActionItem(
          title: 'Tạo đơn thư',
          subtitle: 'Tiếp nhận kiến nghị mới',
          icon: Icons.note_add_rounded,
          color: AppColors.primary,
          onTap: () => PetitionFormModal.show(
            context,
            departments: controller.departments,
            onSaved: () => controller.onRefresh(),
          ),
        ),
      );
      items.add(
        QuickActionItem(
          title: 'Nhập Excel',
          subtitle: 'Tải danh sách từ tệp',
          icon: Icons.upload_file_rounded,
          color: Colors.green,
          onTap: () {
            ImportExcelButton.pickAndUpload(
              uploadUrl: 'task-assignment-petitions/import',
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
          subtitle: 'Tải báo cáo tệp',
          icon: Icons.download_rounded,
          color: Colors.orange,
          onTap: () => controller.exportExcel(),
        ),
      );
    }

    if (canDelete) {
      items.add(
        QuickActionItem(
          title: controller.isMultiSelectMode.value ? 'Hủy chọn' : 'Chọn nhiều',
          subtitle: 'Xóa hàng loạt',
          icon: controller.isMultiSelectMode.value ? Icons.close_rounded : Icons.checklist_rtl_rounded,
          color: Colors.purple,
          badge: controller.selectedPetitionIds.isNotEmpty ? '${controller.selectedPetitionIds.length}' : null,
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
      title: 'Thao tác Đơn thư',
      subtitle: 'Chọn tác vụ bạn muốn thực hiện',
      items: items,
    );
  }

  void _showPetitionDetails(BuildContext context, PetitionItemModel petition, bool isDark) {
    PetitionDetailsBottomSheet.show(
      context,
      petition: petition,
      isDark: isDark,
      onRefreshParent: () => controller.onRefresh(),
      onEditPetition: (p) => PetitionFormModal.show(
        context,
        petitionToEdit: p,
        departments: controller.departments,
        onSaved: () => controller.onRefresh(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authCtrl = Get.find<AuthController>();
    final canDelete = authCtrl.can('destroy', 'TaskAssignmentPetitions');
    final canUpdate = authCtrl.can('update', 'TaskAssignmentPetitions');

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () => Get.find<NavigationController>().changeIndex(0),
        ),
        title: const Text(
          'Đơn thư & Kiến nghị',
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
        if (controller.isMultiSelectMode.value && controller.selectedPetitionIds.isNotEmpty && canDelete) {
          return FloatingActionButton.extended(
            onPressed: () {
              Get.defaultDialog(
                title: 'Xóa đơn thư',
                middleText: 'Bạn có chắc chắn muốn xóa ${controller.selectedPetitionIds.length} đơn thư này?',
                textConfirm: 'Xóa',
                textCancel: 'Hủy',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  Get.back();
                  controller.bulkDeleteSelected();
                },
              );
            },
            backgroundColor: Colors.red,
            icon: const Icon(Icons.delete, color: Colors.white),
            label: Text('Xóa (${controller.selectedPetitionIds.length})', style: const TextStyle(color: Colors.white)),
          );
        }
        return const SizedBox.shrink();
      }),
      body: SafeArea(
        child: Obx(() {
          final showSkeleton = controller.isLoading.value && (controller.petitionsList.isEmpty || controller.isManualRefreshing.value);

          // --- LỌC NÂNG CAO CHO ĐƠN THƯ ---
          var filteredPetitions = List<PetitionItemModel>.from(controller.petitionsList);

          final af = controller.advancedFilter.value;
          if (af.departmentId != null) {
            filteredPetitions = filteredPetitions.where((p) => p.departmentId == af.departmentId).toList();
          }

          if (af.deadlineType != 'all') {
            if (af.deadlineType == 'has_deadline') {
              filteredPetitions = filteredPetitions.where((p) => p.deadlineDate.isNotEmpty).toList();
            } else if (af.deadlineType == 'no_deadline') {
              filteredPetitions = filteredPetitions.where((p) => p.deadlineDate.isEmpty).toList();
            }
          }

          if (af.fromDate != null) {
            filteredPetitions = filteredPetitions.where((p) {
              final date = DateHelper.parseDateTime(p.submissionDate);
              if (date == null) return true;
              return date.isAfter(af.fromDate!) || date.isAtSameMomentAs(af.fromDate!);
            }).toList();
          }

          if (af.toDate != null) {
            final endOfDay = DateTime(af.toDate!.year, af.toDate!.month, af.toDate!.day, 23, 59, 59);
            filteredPetitions = filteredPetitions.where((p) {
              final date = DateHelper.parseDateTime(p.submissionDate);
              if (date == null) return true;
              return date.isBefore(endOfDay) || date.isAtSameMomentAs(endOfDay);
            }).toList();
          }

          final int totalFilteredItems = filteredPetitions.length;
          final int totalPages = (totalFilteredItems / PetitionController.itemsPerPage).ceil().clamp(1, 9999);
          if (controller.currentPage.value > totalPages) {
            controller.currentPage.value = totalPages;
          }
          final int startIndex = (controller.currentPage.value - 1) * PetitionController.itemsPerPage;
          final pagedPetitions = filteredPetitions.skip(startIndex).take(PetitionController.itemsPerPage).toList();

          return SmartSkeletonWrapper(
            showSkeleton: showSkeleton,
            skeleton: AppSkeleton.fullPageLayout(
              statusGridCount: 6,
              statusGridCols: 3,
              statusGridRatio: 2.1,
              timingGridCount: 0,
              cardCount: 5,
              cardHeight: 68,
            ),
            onRefresh: () => controller.onRefresh(),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. THANH TÌM KIẾM & BỘ LỌC
                  PetitionSearchFilterBar(
                    controller: controller,
                    searchController: searchController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // B. LƯỚI THỐNG KÊ TRẠNG THÁI
                  PetitionStatsGridWidget(
                    controller: controller,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // C. DANH SÁCH ĐƠN THƯ & PHÂN TRANG
                  if (controller.isLoading.value)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        child: SkeletonLoader(
                          child: SkeletonBox(
                            width: double.infinity,
                            height: 120,
                            radius: 16,
                          ),
                        ),
                      ),
                    )
                  else if (controller.petitionsList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.mark_email_read_outlined, size: 48, color: AppColors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Không có đơn thư nào phù hợp',
                              style: TextStyle(fontSize: 13, color: AppColors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        AppPagedListWrapper(
                          isChangingPage: controller.isPageChanging.value,
                          skeleton: AppSkeleton.listCards(count: 5, height: 68),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pagedPetitions.length,
                            itemBuilder: (context, index) {
                              final petition = pagedPetitions[index];
                              return _buildPetitionCard(context, petition, isDark, canDelete, canUpdate);
                            },
                          ),
                        ),
                        if (totalFilteredItems > 0) ...[
                          const SizedBox(height: 16),
                          AppPaginationWidget(
                            currentPage: controller.currentPage.value,
                            totalPages: totalPages,
                            totalItems: totalFilteredItems,
                            itemsPerPage: PetitionController.itemsPerPage,
                            isLoading: controller.isLoading.value || controller.isPageChanging.value,
                            onPageChanged: (newPage) => controller.changePage(newPage, _scrollController),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPetitionCard(BuildContext context, PetitionItemModel petition, bool isDark, bool canDelete, bool canUpdate) {
    return Obx(() {
      final isSelected = controller.selectedPetitionIds.contains(petition.id);

      final cardWidget = PetitionCardWidget(
        petition: petition,
        isDark: isDark,
        isSelected: isSelected,
        isMultiSelectMode: controller.isMultiSelectMode.value,
        canUpdate: canUpdate,
        onTap: () => _showPetitionDetails(context, petition, isDark),
        onEdit: canUpdate ? () => PetitionFormModal.show(
          context,
          petitionToEdit: petition,
          departments: controller.departments,
          onSaved: () => controller.onRefresh(),
        ) : null,
        onToggleSelect: () => controller.togglePetitionSelection(petition.id),
      );

      if (controller.isMultiSelectMode.value && canDelete) {
        return cardWidget;
      } else if (canDelete) {
        return Dismissible(
          key: ValueKey('petition_${petition.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await Get.defaultDialog<bool>(
              title: 'Xóa đơn thư',
              middleText: 'Bạn có chắc chắn muốn xóa đơn thư "${petition.title}"?',
              textConfirm: 'Xóa',
              textCancel: 'Hủy',
              confirmTextColor: Colors.white,
              buttonColor: Colors.red,
              onConfirm: () => Get.back(result: true),
              onCancel: () => Get.back(result: false),
            );
          },
          onDismissed: (direction) {
            controller.deleteSinglePetition(petition.id);
          },
          child: cardWidget,
        );
      } else {
        return cardWidget;
      }
    });
  }
}
