import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation.dart';
import '../../controllers/auth_controller.dart';
import '../../model/task_assignment_document_model.dart';
import '../../model/department_model.dart';
import '../../service/task_assignment_documents_service.dart';
import '../../untils/app_colors.dart';
import '../../core/widgets/app_pagination_widget.dart';
import '../../core/widgets/app_paged_list_wrapper.dart';
import '../../core/widgets/export_excel_button.dart';
import '../../core/widgets/import_excel_button.dart';
import '../../view/widgets/skeleton_loader.dart';
import '../../view/widgets/smart_skeleton_wrapper.dart';
import '../../view/widgets/quick_action_bottom_sheet.dart';
import 'widgets/task_document_card.dart';
import 'widgets/task_document_details_dialog.dart';
import 'widgets/task_document_form_modal.dart';

class TaskDocumentScreen extends StatefulWidget {
  const TaskDocumentScreen({super.key});

  @override
  State<TaskDocumentScreen> createState() => _TaskDocumentScreenState();
}

class _TaskDocumentScreenState extends State<TaskDocumentScreen> {
  final TaskAssignmentDocumentsService _docService = TaskAssignmentDocumentsService();
  final TextEditingController _searchController = TextEditingController();

  final RxList<TaskAssignmentDocumentModel> _allDocuments = <TaskAssignmentDocumentModel>[].obs;
  final Rx<TaskAssignmentDocumentStatsModel> _stats = TaskAssignmentDocumentStatsModel().obs;
  final RxList<DepartmentModel> _departments = <DepartmentModel>[].obs;

  final RxBool _isLoading = true.obs;
  final RxInt _currentPage = 1.obs;
  final RxBool _isPageChanging = false.obs; // Cờ hiệu ứng chuyển trang cục bộ
  final ScrollController _scrollController = ScrollController(); // Tự động cuộn mượt lên đầu
  final RxString _searchText = ''.obs;
  final int _perPage = 10;

  // Active Filters
  final RxString _selectedStatus = 'all'.obs; // 'all', 'published', 'draft'
  final Rx<int?> _selectedDepartmentId = Rx<int?>(null);

  // Multi select
  final RxBool isMultiSelectMode = false.obs;
  final RxSet<int> selectedDocIds = <int>{}.obs;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    _isLoading.value = true;
    await Future.wait([
      _fetchDepartments(),
      _fetchStats(),
      _fetchDocuments(),
    ]);
    _isLoading.value = false;
  }

  Future<void> _fetchDepartments() async {
    final res = await _docService.getAvailableDepartments();
    if (res != null) {
      _departments.assignAll(res.data);
    }
  }

  Future<void> _fetchStats() async {
    final res = await _docService.getStats(
      departmentId: _selectedDepartmentId.value,
    );
    if (res != null) {
      _stats.value = res.data;
    }
  }

  Future<void> _fetchDocuments() async {
    try {
      final res = await _docService.getDocuments(
        page: 1,
        perPage: 100,
        search: _searchText.value.trim(),
        departmentId: _selectedDepartmentId.value,
      );

      if (res != null) {
        _allDocuments.assignAll(res.data);

        // Dynamically compute stats if stats API didn't return numbers
        if (_stats.value.total == 0 && res.data.isNotEmpty) {
          int pub = res.data.where((d) => d.isPublished).length;
          int draft = res.data.where((d) => d.isDraft).length;
          _stats.value = TaskAssignmentDocumentStatsModel(
            total: res.data.length,
            published: pub,
            draft: draft,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _onRefresh() async {
    _isLoading.value = true;
    await Future.wait([
      _fetchStats(),
      _fetchDocuments(),
    ]);
    _isLoading.value = false;
  }

  List<TaskAssignmentDocumentModel> _getFilteredDocuments() {
    final search = _searchText.value.trim().toLowerCase();
    return _allDocuments.where((doc) {
      // 1. Search text filter
      if (search.isNotEmpty) {
        final matchTitle = doc.title.toLowerCase().contains(search);
        final matchCode = doc.documentNumber?.toLowerCase().contains(search) ?? false;
        final matchDesc = doc.description?.toLowerCase().contains(search) ?? false;
        if (!matchTitle && !matchCode && !matchDesc) return false;
      }

      // 2. Status filter
      if (_selectedStatus.value == 'published' && !doc.isPublished) return false;
      if (_selectedStatus.value == 'draft' && !doc.isDraft) return false;

      // 3. Department filter
      if (_selectedDepartmentId.value != null && doc.departmentId != _selectedDepartmentId.value) {
        return false;
      }

      return true;
    }).toList();
  }

  void _toggleMultiSelect(int id) {
    if (selectedDocIds.contains(id)) {
      selectedDocIds.remove(id);
      if (selectedDocIds.isEmpty) {
        isMultiSelectMode.value = false;
      }
    } else {
      selectedDocIds.add(id);
    }
  }

  Future<void> _bulkDeleteSelected() async {
    if (selectedDocIds.isEmpty) return;
    final success = await _docService.bulkDeleteDocuments(selectedDocIds.toList());
    if (success) {
      Get.snackbar('Thành công', 'Đã xóa ${selectedDocIds.length} văn bản', backgroundColor: Colors.green, colorText: Colors.white);
      selectedDocIds.clear();
      isMultiSelectMode.value = false;
      _onRefresh();
    } else {
      Get.snackbar('Lỗi', 'Xóa thất bại', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _openQuickActions(BuildContext context) {
    final Map<String, dynamic> queryParams = {};
    if (_selectedStatus.value != 'all') queryParams['status'] = _selectedStatus.value;
    if (_selectedDepartmentId.value != null) queryParams['department_id'] = _selectedDepartmentId.value;

    final List<QuickActionItem> items = [
      QuickActionItem(
        title: 'Tạo văn bản mới',
        subtitle: 'Thêm & phân công',
        icon: Icons.note_add_rounded,
        color: AppColors.primary,
        onTap: () => _showCreateEditDocumentModal(context),
      ),
      QuickActionItem(
        title: 'Nhập Excel',
        subtitle: 'Tải danh sách văn bản',
        icon: Icons.upload_file_rounded,
        color: Colors.green,
        onTap: () {
          ImportExcelButton.pickAndUpload(
            uploadUrl: 'task-assignment-documents/import',
            onSuccess: () => _onRefresh(),
          );
        },
      ),
      QuickActionItem(
        title: 'Xuất Excel',
        subtitle: 'Tải danh sách ra máy',
        icon: Icons.download_rounded,
        color: Colors.orange,
        onTap: () {
          ExportExcelButton.downloadAndSave(
            url: 'task-assignment-documents/export',
            queryParams: queryParams,
            fileNamePrefix: 'VanBanGiaoViec',
          );
        },
      ),
      QuickActionItem(
        title: isMultiSelectMode.value ? 'Hủy chọn nhiều' : 'Xóa đã chọn',
        subtitle: 'Xóa nhiều văn bản cùng lúc',
        icon: isMultiSelectMode.value ? Icons.close_rounded : Icons.checklist_rtl_rounded,
        color: Colors.purple,
        badge: selectedDocIds.isNotEmpty ? '${selectedDocIds.length}' : null,
        onTap: () {
          isMultiSelectMode.toggle();
          if (!isMultiSelectMode.value) {
            selectedDocIds.clear();
          }
        },
      ),
    ];

    QuickActionBottomSheet.show(
      context,
      title: 'Chi tiết văn bản',
      subtitle: 'Chọn tác vụ bạn muốn thực hiện',
      items: items,
    );
  }

  void _showCreateEditDocumentModal(BuildContext context, {TaskAssignmentDocumentModel? docToEdit}) {
    TaskDocumentFormModal.show(
      context,
      docToEdit: docToEdit,
      departments: _departments,
      onSaved: () => _onRefresh(),
    );
  }

  void _showFilterModal(BuildContext context, bool isDark) {
    String tempStatus = _selectedStatus.value;
    int? tempDeptId = _selectedDepartmentId.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bộ lọc văn bản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempStatus = 'all';
                            tempDeptId = null;
                          });
                          _selectedStatus.value = 'all';
                          _selectedDepartmentId.value = null;
                          _currentPage.value = 1;
                          Navigator.pop(ctx);
                        },
                        child: const Text('Đặt lại', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Trạng thái văn bản', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('Tất cả', 'all', tempStatus, (v) => setModalState(() => tempStatus = v)),
                      _buildFilterChip('Đã ban hành', 'published', tempStatus, (v) => setModalState(() => tempStatus = v)),
                      _buildFilterChip('Bản nháp', 'draft', tempStatus, (v) => setModalState(() => tempStatus = v)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_departments.isNotEmpty) ...[
                    const Text('Phòng ban', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white10 : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: tempDeptId,
                          hint: const Text('Tất cả phòng ban', style: TextStyle(fontSize: 13)),
                          dropdownColor: isDark ? AppColors.cardDark : AppColors.white,
                          items: [
                            const DropdownMenuItem<int?>(value: null, child: Text('Tất cả phòng ban', style: TextStyle(fontSize: 13))),
                            ..._departments.map((d) => DropdownMenuItem<int?>(value: d.id, child: Text(d.name, style: const TextStyle(fontSize: 13)))),
                          ],
                          onChanged: (val) => setModalState(() => tempDeptId = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        _selectedStatus.value = tempStatus;
                        _selectedDepartmentId.value = tempDeptId;
                        _currentPage.value = 1;
                        Navigator.pop(ctx);
                      },
                      child: const Text('Áp dụng bộ lọc', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, String current, Function(String) onSelect) {
    final isSelected = value == current;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.black87, fontWeight: FontWeight.w600)),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.borderLight,
      onSelected: (_) => onSelect(value),
    );
  }

  Widget _buildTaskDocumentSkeleton() {
    return SkeletonLoader(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Bar + Filter + Excel row (matching 1-1 with real widget)
            Row(
              children: [
                Expanded(child: AppSkeleton.searchBar(height: 40, radius: 10)),
                const SizedBox(width: 8),
                const SkeletonBox(width: 40, height: 40, radius: 10),
                const SizedBox(width: 8),
                const SkeletonBox(width: 40, height: 40, radius: 10),
              ],
            ),
            const SizedBox(height: 14),

            // 2. 3 Stat cards row
            const Row(
              children: [
                Expanded(child: SkeletonBox(width: double.infinity, height: 62, radius: 12)),
                SizedBox(width: 8),
                Expanded(child: SkeletonBox(width: double.infinity, height: 62, radius: 12)),
                SizedBox(width: 8),
                Expanded(child: SkeletonBox(width: double.infinity, height: 62, radius: 12)),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Document list cards (72px each)
            AppSkeleton.listCards(count: 6, height: 72, radius: 14, verticalPadding: 5.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authCtrl = Get.find<AuthController>();
    final canDelete = authCtrl.can('destroy', 'TaskAssignmentDocuments');

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.pageBg,
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () {
            Get.find<NavigationController>().changeIndex(0);
          },
        ),
        title: const Text(
          'Văn bản giao việc',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            if (isMultiSelectMode.value) {
              return IconButton(
                icon: const Icon(Icons.close, size: 22),
                tooltip: 'Thoát chọn nhiều',
                onPressed: () {
                  isMultiSelectMode.value = false;
                  selectedDocIds.clear();
                },
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
        if (isMultiSelectMode.value && selectedDocIds.isNotEmpty && canDelete) {
          return FloatingActionButton.extended(
            onPressed: () {
              Get.defaultDialog(
                title: 'Xóa văn bản',
                middleText: 'Bạn có chắc chắn muốn xóa ${selectedDocIds.length} văn bản này?',
                textConfirm: 'Xóa',
                textCancel: 'Hủy',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  Get.back();
                  _bulkDeleteSelected();
                },
              );
            },
            backgroundColor: const Color(0xFFEF4444),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.delete, color: Colors.white),
            label: Text(
              'Xóa (${selectedDocIds.length})',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
      body: SafeArea(
        child: Obx(() {
          final filteredList = _getFilteredDocuments();
          final int totalItems = filteredList.length;
          final int totalPages = (totalItems / _perPage).ceil().clamp(1, 9999);
          if (_currentPage.value > totalPages) {
            _currentPage.value = totalPages;
          }
          final int startIndex = (_currentPage.value - 1) * _perPage;
          final pagedDocs = filteredList.skip(startIndex).take(_perPage).toList();

          return SmartSkeletonWrapper(
            showSkeleton: _isLoading.value,
            skeleton: _buildTaskDocumentSkeleton(),
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Search, Filter & Excel Row (100% pixel match with TaskScreen)
                  Row(
                    children: [
                      // Search box
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              _searchText.value = val;
                              _currentPage.value = 1;
                            },
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm văn bản theo tên, số hiệu...',
                              hintStyle: TextStyle(fontSize: 13, color: AppColors.grey),
                              prefixIcon: Icon(Icons.search, size: 18, color: AppColors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Filter button
                      Obx(() {
                        final bool hasActiveFilter = _selectedStatus.value != 'all' || _selectedDepartmentId.value != null;
                        return Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: hasActiveFilter
                                  ? AppColors.primary
                                  : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05)),
                              width: hasActiveFilter ? 1.5 : 1.0,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_alt_outlined,
                              size: 18,
                              color: hasActiveFilter ? AppColors.primary : AppColors.grey,
                            ),
                            tooltip: 'Bộ lọc',
                            onPressed: () => _showFilterModal(context, isDark),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),

                      // Excel button (matching 1-1 with TaskScreen green box)
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.badgeGreenBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.white10 : AppColors.borderGreen,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.description_outlined, size: 18, color: AppColors.textGreen),
                          tooltip: 'Xuất Excel',
                          onPressed: () {
                            final Map<String, dynamic> queryParams = {};
                            if (_selectedStatus.value != 'all') queryParams['status'] = _selectedStatus.value;
                            if (_selectedDepartmentId.value != null) queryParams['department_id'] = _selectedDepartmentId.value;
                            ExportExcelButton.downloadAndSave(
                              url: 'task-assignment-documents/export',
                              queryParams: queryParams,
                              fileNamePrefix: 'VanBanGiaoViec',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. Stat Cards Row (3 Cards: Tổng số, Đã ban hành, Bản nháp)
                  Obx(() {
                    final stats = _stats.value;
                    return Row(
                      children: [
                        // Card 1: Tổng số
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.description_outlined,
                            label: 'Tổng số',
                            count: stats.total,
                            borderColor: AppColors.borderBlue,
                            bgColor: isDark ? AppColors.cardDark : AppColors.badgeBlueBg,
                            textColor: AppColors.textMain,
                            iconColor: AppColors.primary,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Card 2: Đã ban hành
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle_outline,
                            label: 'Đã ban hành',
                            count: stats.published,
                            borderColor: AppColors.borderGreen,
                            bgColor: isDark ? AppColors.cardDark : AppColors.badgeGreenBg,
                            textColor: AppColors.textGreen,
                            iconColor: AppColors.done,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Card 3: Bản nháp
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.access_time_outlined,
                            label: 'Bản nháp',
                            count: stats.draft,
                            borderColor: AppColors.borderAmber,
                            bgColor: isDark ? AppColors.cardDark : AppColors.warningBg,
                            textColor: AppColors.warningOrange,
                            iconColor: AppColors.paused,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 14),

                  // 3. Document List
                  if (pagedDocs.isEmpty) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, size: 54, color: isDark ? AppColors.white30 : AppColors.grey[400]),
                          const SizedBox(height: 10),
                          Text('Không có văn bản giao việc nào', style: TextStyle(color: isDark ? AppColors.white70 : AppColors.grey[600], fontSize: 14)),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Bọc danh sách bằng AppPagedListWrapper để hiển thị Skeleton cục bộ khi chuyển trang
                    AppPagedListWrapper(
                      isChangingPage: _isPageChanging.value,
                      skeleton: AppSkeleton.listCards(count: 5, height: 68),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pagedDocs.length,
                        itemBuilder: (ctx, idx) {
                          final doc = pagedDocs[idx];
                          return Obx(() {
                            final isSelected = selectedDocIds.contains(doc.id);
                            final isMulti = isMultiSelectMode.value;

                            final cardWidget = TaskDocumentCard(
                              document: doc,
                              isDark: isDark,
                              isSelected: isSelected,
                              isMultiSelectMode: isMulti,
                              onToggleSelect: () => _toggleMultiSelect(doc.id),
                              onTap: () {
                                if (isMulti) {
                                  _toggleMultiSelect(doc.id);
                                } else {
                                  TaskDocumentDetailsBottomSheet.show(
                                    context,
                                    document: doc,
                                    isDark: isDark,
                                    onRefreshParent: () => _onRefresh(),
                                    onEditDocument: (d) => _showCreateEditDocumentModal(context, docToEdit: d),
                                  );
                                }
                              },
                              onLongPress: () {
                                if (!isMulti) {
                                  isMultiSelectMode.value = true;
                                  _toggleMultiSelect(doc.id);
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
                              onDismissed: (direction) async {
                                final success = await _docService.deleteDocument(doc.id);
                                if (success) {
                                  _allDocuments.removeWhere((d) => d.id == doc.id);
                                  Get.snackbar(
                                    'Thành công',
                                    'Đã xóa văn bản giao việc thành công',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: AppColors.done,
                                    colorText: Colors.white,
                                  );
                                  _fetchStats();
                                } else {
                                  Get.snackbar('Lỗi', 'Không thể xóa văn bản này', backgroundColor: Colors.red, colorText: Colors.white);
                                  _onRefresh();
                                }
                              },
                              child: cardWidget,
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. Pagination
                    AppPaginationWidget(
                      currentPage: _currentPage.value,
                      totalPages: totalPages,
                      totalItems: totalItems,
                      isLoading: _isPageChanging.value,
                      onPageChanged: (p) async {
                        if (_currentPage.value == p) return;
                        // 1. Bật cờ hiệu ứng chuyển trang cục bộ
                        _isPageChanging.value = true;
                        _currentPage.value = p;

                        // 2. Cuộn nhẹ lên đầu danh sách
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        }

                        // 3. Tắt trạng thái nạp sau khi hoàn tất hiệu ứng êm dịu (200ms)
                        await Future.delayed(const Duration(milliseconds: 200));
                        _isPageChanging.value = false;
                      },
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color borderColor,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.white10 : borderColor, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white70 : const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : textColor,
            ),
          ),
        ],
      ),
    );
  }
}
