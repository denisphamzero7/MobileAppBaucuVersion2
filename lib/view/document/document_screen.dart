import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation.dart';
import '../../controllers/auth_controller.dart';
import '../../untils/app_colors.dart';
import '../../untils/app_textstyles.dart';
import '../../helper/date_helper.dart';
import '../../core/widgets/app_tag.dart';
import '../../service/petition_service.dart';
import '../../core/widgets/import_excel_button.dart';
import '../../core/widgets/export_excel_button.dart';
import '../../core/widgets/app_pagination_widget.dart';
import '../../view/widgets/quick_action_bottom_sheet.dart';
import '../../view/widgets/skeleton_loader.dart';
import '../../view/widgets/smart_skeleton_wrapper.dart';
import '../../view/task/widgets/stat_card_widget.dart';
import 'widgets/petition_details_dialog.dart';
import '../../model/advanced_filter_data.dart';
import '../../core/widgets/app_advanced_filter_bottom_sheet.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final RxString selectedStatusFilter = 'all'.obs;
  final Rx<AdvancedFilterData> advancedFilter = AdvancedFilterData.initial.obs;
  final RxString searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final RxInt currentPage = 1.obs;
  static const int itemsPerPage = 10;
  
  final PetitionService _petitionService = PetitionService();
  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  final Rxn<DepartmentModel> selectedDepartment = Rxn<DepartmentModel>();

  final RxList<PetitionItemModel> petitionsList = <PetitionItemModel>[].obs;
  final Rx<PetitionStatsModel> stats = PetitionStatsModel().obs;
  final RxBool isLoading = true.obs;
  final RxBool isInitialLoaded = false.obs;

  // Multi-select & Bulk Delete
  final RxBool isMultiSelectMode = false.obs;
  final RxSet<int> selectedPetitionIds = <int>{}.obs;
  final RxBool isManualRefreshing = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (petitionsList.isEmpty) {
        _fetchInitialData();
      } else {
        isLoading.value = false;
        isInitialLoaded.value = true;
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    isManualRefreshing.value = true;
    currentPage.value = 1;
    await _fetchInitialData();
    isManualRefreshing.value = false;
  }

  Future<void> _fetchInitialData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _fetchPetitions(),
        _fetchStats(),
        _fetchDepartments(),
      ]);
    } finally {
      isLoading.value = false;
      isInitialLoaded.value = true;
    }
  }

  Future<void> _fetchPetitions() async {
    final response = await _petitionService.getPetitions(
      search: searchText.value.isNotEmpty ? searchText.value : null,
      processingStatus: selectedStatusFilter.value != 'all' ? selectedStatusFilter.value : null,
      departmentId: selectedDepartment.value?.id,
    );
    if (response != null && response.statusCode == 200) {
      petitionsList.assignAll(response.data);
    } else {
      petitionsList.clear();
    }
  }

  Future<void> _fetchStats() async {
    final res = await _petitionService.getPetitionStats();
    if (res != null) {
      stats.value = res;
    }
  }

  Future<void> _fetchDepartments() async {
    final response = await _petitionService.getAvailableDepartments();
    if (response != null && response.statusCode == 200) {
      departments.assignAll(response.data);
    }
  }

  void toggleMultiSelectMode() {
    isMultiSelectMode.value = !isMultiSelectMode.value;
    if (!isMultiSelectMode.value) {
      selectedPetitionIds.clear();
    }
  }

  void togglePetitionSelection(int id) {
    if (selectedPetitionIds.contains(id)) {
      selectedPetitionIds.remove(id);
    } else {
      selectedPetitionIds.add(id);
    }
  }

  void _openQuickActions(BuildContext context) {
    final queryParams = <String, dynamic>{};
    if (searchText.value.isNotEmpty) queryParams['search'] = searchText.value;
    if (selectedStatusFilter.value != 'all') queryParams['processing_status'] = selectedStatusFilter.value;
    if (selectedDepartment.value != null) queryParams['department_id'] = selectedDepartment.value!.id;

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
          onTap: () => _showCreateEditPetitionModal(context),
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
              onSuccess: () => _onRefresh(),
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
          onTap: () {
            ExportExcelButton.downloadAndSave(
              url: 'task-assignment-petitions/export',
              queryParams: queryParams,
              fileNamePrefix: 'DonThuKienNghi',
            );
          },
        ),
      );
    }

    if (canDelete) {
      items.add(
        QuickActionItem(
          title: isMultiSelectMode.value ? 'Hủy chọn' : 'Chọn nhiều',
          subtitle: 'Xóa hàng loạt',
          icon: isMultiSelectMode.value ? Icons.close_rounded : Icons.checklist_rtl_rounded,
          color: Colors.purple,
          badge: selectedPetitionIds.isNotEmpty ? '${selectedPetitionIds.length}' : null,
          onTap: () => toggleMultiSelectMode(),
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

  Future<void> _deleteSinglePetition(int id) async {
    final success = await _petitionService.deletePetition(id);
    if (success) {
      petitionsList.removeWhere((p) => p.id == id);
      Get.snackbar('Thành công', 'Đã xóa đơn thư', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      _fetchStats();
    } else {
      Get.snackbar('Lỗi', 'Không thể xóa đơn thư này', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      _onRefresh();
    }
  }

  Future<void> _bulkDeleteSelected() async {
    if (selectedPetitionIds.isEmpty) return;
    final idsToDelete = selectedPetitionIds.toList();
    final success = await _petitionService.bulkDeletePetitions(idsToDelete);
    if (success) {
      petitionsList.removeWhere((p) => idsToDelete.contains(p.id));
      Get.snackbar('Thành công', 'Đã xóa ${idsToDelete.length} đơn thư được chọn', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      selectedPetitionIds.clear();
      isMultiSelectMode.value = false;
      _fetchStats();
    } else {
      Get.snackbar('Lỗi', 'Có lỗi xảy ra khi xóa hàng loạt', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      _onRefresh();
    }
  }

  void _showCreateEditPetitionModal(BuildContext context, {PetitionItemModel? petitionToEdit}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = petitionToEdit != null;
    final authCtrl = Get.find<AuthController>();
    final canCreate = authCtrl.can('create', 'TaskAssignmentPetitions');
    final canUpdate = authCtrl.can('update', 'TaskAssignmentPetitions');

    if (isEdit && !canUpdate) {
      Get.snackbar('Từ chối truy cập', 'Bạn không có quyền cập nhật đơn thư này.',
          backgroundColor: Colors.red.shade100);
      return;
    }
    if (!isEdit && !canCreate) {
      Get.snackbar('Từ chối truy cập', 'Bạn không có quyền tạo đơn thư mới.',
          backgroundColor: Colors.red.shade100);
      return;
    }

    final titleCtrl = TextEditingController(text: petitionToEdit?.title ?? '');
    final senderNameCtrl = TextEditingController(text: petitionToEdit?.senderName ?? '');
    final senderPhoneCtrl = TextEditingController(text: petitionToEdit?.senderPhone ?? '');
    final senderEmailCtrl = TextEditingController(text: petitionToEdit?.senderEmail ?? '');
    final senderCccdCtrl = TextEditingController(text: petitionToEdit?.senderCccd ?? '');
    final senderAddressCtrl = TextEditingController(text: petitionToEdit?.senderAddress ?? '');
    final contentCtrl = TextEditingController(text: petitionToEdit?.content ?? '');

    int? selectedDeptId = petitionToEdit?.departmentId;
    String selectedStatus = petitionToEdit?.processingStatus ?? 'new';
    DateTime? deadlineDate;

    if (petitionToEdit?.deadlineDate != null && petitionToEdit!.deadlineDate.isNotEmpty) {
      try {
        deadlineDate = DateTime.tryParse(petitionToEdit.deadlineDate);
      } catch (_) {}
    }

    final statuses = [
      {'key': 'new', 'label': 'Mới tiếp nhận'},
      {'key': 'processing', 'label': 'Đang xử lý'},
      {'key': 'completed', 'label': 'Đã hoàn thành'},
      {'key': 'paused', 'label': 'Tạm dừng'},
      {'key': 'cancelled', 'label': 'Đã hủy'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.white24 : AppColors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Cập nhật Đơn thư' : 'Tạo Đơn thư mới',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // Form Fields
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Tiêu đề đơn thư *', isDark),
                            _buildTextField(titleCtrl, 'Nhập tiêu đề đơn thư...', isDark),
                            const SizedBox(height: 12),

                            _buildInputLabel('Họ và tên người nộp *', isDark),
                            _buildTextField(senderNameCtrl, 'Nhập họ tên công dân...', isDark),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInputLabel('Số điện thoại', isDark),
                                      _buildTextField(senderPhoneCtrl, 'SĐT liên hệ...', isDark, keyboardType: TextInputType.phone),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInputLabel('Số CCCD/CMND', isDark),
                                      _buildTextField(senderCccdCtrl, 'Số CCCD...', isDark),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            _buildInputLabel('Email người nộp', isDark),
                            _buildTextField(senderEmailCtrl, 'Địa chỉ email...', isDark, keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 12),

                            _buildInputLabel('Địa chỉ liên hệ', isDark),
                            _buildTextField(senderAddressCtrl, 'Nhập địa chỉ cư trú...', isDark),
                            const SizedBox(height: 12),

                            _buildInputLabel('Phòng ban xử lý', isDark),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.white10 : AppColors.lightBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDark ? AppColors.white10 : AppColors.black12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int?>(
                                  isExpanded: true,
                                  value: selectedDeptId,
                                  dropdownColor: isDark ? AppColors.cardDark : AppColors.white,
                                  hint: const Text('Chọn phòng ban xử lý', style: TextStyle(fontSize: 13)),
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('Chưa phân công', style: TextStyle(fontSize: 13)),
                                    ),
                                    ...departments.map((d) => DropdownMenuItem<int?>(
                                      value: d.id,
                                      child: Text(d.name, style: const TextStyle(fontSize: 13)),
                                    )),
                                  ],
                                  onChanged: (val) {
                                    setModalState(() {
                                      selectedDeptId = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInputLabel('Trạng thái xử lý', isDark),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.white10 : AppColors.lightBg,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: isDark ? AppColors.white10 : AppColors.black12),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            value: selectedStatus,
                                            dropdownColor: isDark ? AppColors.cardDark : AppColors.white,
                                            items: statuses.map((s) => DropdownMenuItem<String>(
                                              value: s['key']!,
                                              child: Text(s['label']!, style: const TextStyle(fontSize: 12)),
                                            )).toList(),
                                            onChanged: (val) {
                                              if (val != null) {
                                                setModalState(() {
                                                  selectedStatus = val;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInputLabel('Hạn xử lý', isDark),
                                      InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: deadlineDate ?? DateTime.now().add(const Duration(days: 7)),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2035),
                                          );
                                          if (picked != null) {
                                            setModalState(() {
                                              deadlineDate = picked;
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: isDark ? AppColors.white10 : AppColors.lightBg,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: isDark ? AppColors.white10 : AppColors.black12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                deadlineDate != null
                                                    ? '${deadlineDate!.day.toString().padLeft(2, '0')}/${deadlineDate!.month.toString().padLeft(2, '0')}/${deadlineDate!.year}'
                                                    : 'Chọn hạn',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: deadlineDate != null ? (isDark ? AppColors.white : AppColors.black87) : AppColors.grey,
                                                ),
                                              ),
                                              const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            _buildInputLabel('Nội dung phản ánh / kiến nghị *', isDark),
                            _buildTextField(contentCtrl, 'Nhập nội dung chi tiết đơn thư...', isDark, maxLines: 4),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (titleCtrl.text.trim().isEmpty) {
                            Get.snackbar('Lỗi', 'Vui lòng nhập tiêu đề đơn thư');
                            return;
                          }
                          if (senderNameCtrl.text.trim().isEmpty) {
                            Get.snackbar('Lỗi', 'Vui lòng nhập họ tên người gửi');
                            return;
                          }
                          if (contentCtrl.text.trim().isEmpty) {
                            Get.snackbar('Lỗi', 'Vui lòng nhập nội dung đơn thư');
                            return;
                          }

                          final payload = <String, dynamic>{
                            'title': titleCtrl.text.trim(),
                            'sender_name': senderNameCtrl.text.trim(),
                            'content': contentCtrl.text.trim(),
                            'processing_status': selectedStatus,
                          };

                          if (senderPhoneCtrl.text.trim().isNotEmpty) {
                            payload['sender_phone'] = senderPhoneCtrl.text.trim();
                          }
                          if (senderEmailCtrl.text.trim().isNotEmpty) {
                            payload['sender_email'] = senderEmailCtrl.text.trim();
                          }
                          if (senderCccdCtrl.text.trim().isNotEmpty) {
                            payload['sender_cccd'] = senderCccdCtrl.text.trim();
                          }
                          if (senderAddressCtrl.text.trim().isNotEmpty) {
                            payload['sender_address'] = senderAddressCtrl.text.trim();
                          }
                          if (selectedDeptId != null) {
                            payload['department_id'] = selectedDeptId;
                          }
                          if (deadlineDate != null) {
                            payload['deadline_date'] = DateHelper.formatForApi(deadlineDate, includeTime: false);
                          }

                          Navigator.pop(ctx);

                          try {
                            if (isEdit) {
                              final res = await _petitionService.updatePetition(petitionToEdit.id, payload);
                              if (res != null) {
                                Get.snackbar('Thành công', 'Đã cập nhật đơn thư', backgroundColor: Colors.green, colorText: Colors.white);
                                _onRefresh();
                              } else {
                                Get.snackbar('Lỗi', 'Cập nhật đơn thư thất bại', backgroundColor: Colors.red, colorText: Colors.white);
                              }
                            } else {
                              final res = await _petitionService.createPetition(payload);
                              if (res != null) {
                                Get.snackbar('Thành công', 'Đã tạo đơn thư mới thành công', backgroundColor: Colors.green, colorText: Colors.white);
                                _onRefresh();
                              } else {
                                Get.snackbar('Lỗi', 'Tạo đơn thư thất bại', backgroundColor: Colors.red, colorText: Colors.white);
                              }
                            }
                          } catch (e) {
                            final errorMsg = e.toString().replaceAll('Exception: ', '').replaceAll('DioException [bad response]: ', '');
                            Get.snackbar(
                              'Lỗi',
                              'Thao tác thất bại: $errorMsg',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 4),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(
                          isEdit ? 'Lưu thay đổi' : 'Tạo đơn thư',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.white70 : AppColors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, bool isDark, {int maxLines = 1, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.white10 : AppColors.lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.white10 : AppColors.black12),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 13, color: isDark ? AppColors.white : AppColors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  void _showPetitionDetails(BuildContext context, PetitionItemModel petition, bool isDark) {
    PetitionDetailsBottomSheet.show(
      context,
      petition: petition,
      isDark: isDark,
      onRefreshParent: () => _onRefresh(),
      onEditPetition: (p) => _showCreateEditPetitionModal(context, petitionToEdit: p),
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
          onPressed: () {
            Get.find<NavigationController>().changeIndex(0);
          },
        ),
        title: const Text(
          'Đơn thư & Kiến nghị',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            if (isMultiSelectMode.value) {
              return IconButton(
                icon: const Icon(Icons.close, size: 22),
                tooltip: 'Thoát chọn nhiều',
                onPressed: () => toggleMultiSelectMode(),
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
        if (isMultiSelectMode.value && selectedPetitionIds.isNotEmpty && canDelete) {
          return FloatingActionButton.extended(
            onPressed: () {
              Get.defaultDialog(
                title: 'Xóa đơn thư',
                middleText: 'Bạn có chắc chắn muốn xóa ${selectedPetitionIds.length} đơn thư này?',
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
            backgroundColor: Colors.red,
            icon: const Icon(Icons.delete, color: Colors.white),
            label: Text('Xóa (${selectedPetitionIds.length})', style: const TextStyle(color: Colors.white)),
          );
        }
        return const SizedBox.shrink();
      }),
      body: SafeArea(
        child: Obx(() {
          final showSkeleton = isLoading.value && (petitionsList.isEmpty || isManualRefreshing.value);

          final st = stats.value;
          final dynamicTotal = st.total > 0 ? st.total : petitionsList.length;
          final dynamicNew = st.todo > 0 ? st.todo : petitionsList.where((p) => p.processingStatus == 'new').length;
          final dynamicProcessing = st.inProgress > 0 ? st.inProgress : petitionsList.where((p) => p.processingStatus == 'processing').length;
          final dynamicCompleted = st.done > 0 ? st.done : petitionsList.where((p) => p.processingStatus == 'completed').length;
          final dynamicPaused = st.paused > 0 ? st.paused : petitionsList.where((p) => p.processingStatus == 'paused').length;
          final dynamicCancelled = st.cancelled > 0 ? st.cancelled : petitionsList.where((p) => p.processingStatus == 'cancelled').length;

          // --- ÁP DỤNG BỘ LỌC NÂNG CAO CHO ĐƠN THƯ ---
          var filteredPetitions = List<PetitionItemModel>.from(petitionsList);

          final af = advancedFilter.value;
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
          final int totalPages = (totalFilteredItems / itemsPerPage).ceil().clamp(1, 9999);
          if (currentPage.value > totalPages) {
            currentPage.value = totalPages;
          }
          final int startIndex = (currentPage.value - 1) * itemsPerPage;
          final pagedPetitions = filteredPetitions.skip(startIndex).take(itemsPerPage).toList();

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
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. SEARCH BAR & ADVANCED FILTER BUTTON
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.lightBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: (val) {
                              searchText.value = val.trim();
                              currentPage.value = 1;
                              _fetchPetitions();
                            },
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm đơn thư, kiến nghị',
                              hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
                              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.grey),
                              suffixIcon: Obx(() => searchText.value.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () {
                                        searchController.clear();
                                        searchText.value = '';
                                        currentPage.value = 1;
                                        _fetchPetitions();
                                      },
                                    )
                                  : const SizedBox.shrink()),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // NÚT BỘ LỌC NÂNG CAO ĐƠN THƯ
                      Obx(() {
                        final isFilterActive = advancedFilter.value.isActive;
                        final activeCount = advancedFilter.value.activeCount;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: isFilterActive
                                    ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                                    : (isDark ? AppColors.cardDark : AppColors.white),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isFilterActive
                                      ? AppColors.primary
                                      : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05)),
                                  width: isFilterActive ? 1.5 : 1.0,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.filter_alt_outlined,
                                  size: 18,
                                  color: isFilterActive ? AppColors.primary : AppColors.grey,
                                ),
                                tooltip: 'Bộ lọc nâng cao',
                                onPressed: () {
                                  AppAdvancedFilterBottomSheet.show(
                                    context,
                                    initialData: advancedFilter.value,
                                    departments: departments,
                                    showPriority: false, // Đơn thư không có mức ưu tiên
                                    onApply: (data) {
                                      advancedFilter.value = data;
                                      if (data.departmentId != null) {
                                        final found = departments.where((d) => d.id == data.departmentId);
                                        selectedDepartment.value = found.isNotEmpty ? found.first : null;
                                      } else {
                                        selectedDepartment.value = null;
                                      }
                                      currentPage.value = 1;
                                    },
                                    onReset: () {
                                      advancedFilter.value = AdvancedFilterData.initial;
                                      selectedDepartment.value = null;
                                      currentPage.value = 1;
                                    },
                                  );
                                },
                              ),
                            ),
                            if (isFilterActive && activeCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Center(
                                    child: Text(
                                      '$activeCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),

                  if (advancedFilter.value.departmentName != null || selectedDepartment.value != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Phòng ban: ${advancedFilter.value.departmentName ?? selectedDepartment.value?.name}',
                            style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              selectedDepartment.value = null;
                              advancedFilter.value = advancedFilter.value.copyWith(clearDepartment: true);
                              currentPage.value = 1;
                              _fetchPetitions();
                            },
                            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // B. TRẠNG THÁI XỬ LÝ GRID
                  const Text(
                    'TRẠNG THÁI XỬ LÝ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.grey, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 2.1,
                    children: [
                      StatCardWidget(
                        label: 'Tổng',
                        count: dynamicTotal,
                        icon: Icons.filter_list,
                        color: AppColors.primary,
                        isSelected: selectedStatusFilter.value == 'all',
                        onTap: () {
                          selectedStatusFilter.value = 'all';
                          currentPage.value = 1;
                          _fetchPetitions();
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Mới tiếp nhận',
                        count: dynamicNew,
                        icon: Icons.access_time,
                        color: AppColors.todo,
                        isSelected: selectedStatusFilter.value == 'new',
                        onTap: () {
                          selectedStatusFilter.value = 'new';
                          currentPage.value = 1;
                          _fetchPetitions();
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Đang xử lý',
                        count: dynamicProcessing,
                        icon: Icons.rotate_right,
                        color: AppColors.inProgress,
                        isSelected: selectedStatusFilter.value == 'processing',
                        onTap: () {
                          selectedStatusFilter.value = 'processing';
                          currentPage.value = 1;
                          _fetchPetitions();
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Đã hoàn thành',
                        count: dynamicCompleted,
                        icon: Icons.done_all,
                        color: AppColors.done,
                        isSelected: selectedStatusFilter.value == 'completed',
                        onTap: () {
                          selectedStatusFilter.value = 'completed';
                          currentPage.value = 1;
                          _fetchPetitions();
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Tạm dừng',
                        count: dynamicPaused,
                        icon: Icons.pause_circle_outline,
                        color: AppColors.paused,
                        isSelected: selectedStatusFilter.value == 'paused',
                        onTap: () {
                          selectedStatusFilter.value = 'paused';
                          currentPage.value = 1;
                          _fetchPetitions();
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Đã hủy',
                        count: dynamicCancelled,
                        icon: Icons.cancel_outlined,
                        color: AppColors.overdue,
                        isSelected: selectedStatusFilter.value == 'cancelled',
                        onTap: () {
                          selectedStatusFilter.value = 'cancelled';
                          currentPage.value = 1;
                          _fetchPetitions();
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // C. LIST OF PETITIONS
                  if (isLoading.value)
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
                  else if (petitionsList.isEmpty)
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
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pagedPetitions.length,
                          itemBuilder: (context, index) {
                            final petition = pagedPetitions[index];
                            return _buildPetitionCard(context, petition, isDark, canDelete, canUpdate);
                          },
                        ),
                        if (totalFilteredItems > 0) ...[
                          const SizedBox(height: 16),
                          AppPaginationWidget(
                            currentPage: currentPage.value,
                            totalPages: totalPages,
                            totalItems: totalFilteredItems,
                            itemsPerPage: itemsPerPage,
                            isLoading: isLoading.value,
                            onPageChanged: (newPage) {
                              currentPage.value = newPage;
                            },
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
    // Determine status text & colors
    String statusText = 'Mới tiếp nhận';
    Color statusColor = AppColors.textGrayDark;
    Color statusBgColor = isDark ? AppColors.white10 : AppColors.lightBg;

    if (petition.processingStatus == 'processing' || petition.processingStatus == 'in_progress') {
      statusText = 'Đang xử lý';
      statusColor = AppColors.primary;
      statusBgColor = AppColors.badgeBlueBg;
    } else if (petition.processingStatus == 'completed' || petition.processingStatus == 'done') {
      statusText = 'Hoàn thành';
      statusColor = AppColors.done;
      statusBgColor = AppColors.badgeGreenBg;
    } else if (petition.processingStatus == 'paused') {
      statusText = 'Tạm dừng';
      statusColor = AppColors.paused;
      statusBgColor = AppColors.bgYellowLight;
    } else if (petition.processingStatus == 'cancelled') {
      statusText = 'Đã hủy';
      statusColor = AppColors.overdue;
      statusBgColor = AppColors.badgeRedBg;
    }

    // Determine timing text
    String timingText = 'ĐÚNG HẠN';
    if (petition.isOverdue || petition.timingStatus == 'overdue') {
      timingText = 'QUÁ HẠN';
    } else if (petition.timingStatus == 'late') {
      timingText = 'TRỄ HẠN';
    } else if (petition.timingStatus == 'early') {
      timingText = 'SỚM HẠN';
    } else if (petition.timingStatus == 'upcoming') {
      timingText = 'CHƯA ĐẾN HẠN';
    }

    // Format deadline
    String deadlineStr = 'N/A';
    if (petition.deadlineDate.isNotEmpty) {
      try {
        final spaceParts = petition.deadlineDate.trim().split(' ');
        String datePart = spaceParts.length >= 2 ? spaceParts[1] : spaceParts[0];
        if (datePart.contains('/')) {
          final dateParts = datePart.split('/');
          if (dateParts.length >= 2) {
            deadlineStr = '${dateParts[0]}/${dateParts[1]}';
          }
        } else if (datePart.contains('-')) {
          final dateParts = datePart.split('-');
          if (dateParts.length >= 3) {
            if (dateParts[0].length == 4) {
              deadlineStr = '${dateParts[2]}/${dateParts[1]}';
            } else {
              deadlineStr = '${dateParts[0]}/${dateParts[1]}';
            }
          }
        }
      } catch (_) {}
    }

    final card = Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showPetitionDetails(context, petition, isDark),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    petition.title,
                    style: AppTextStyle.cardTitle.copyWith(
                      color: isDark ? AppColors.white : AppColors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        AppTag.info(
                          label: petition.senderName,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.circle, size: 3, color: AppColors.grey),
                        const SizedBox(width: 6),
                        AppTag.date(
                          dateText: deadlineStr,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.circle, size: 3, color: AppColors.grey),
                        const SizedBox(width: 6),
                        AppTag.percent(
                          percent: petition.completionPercent,
                          isDark: isDark,
                          showBullet: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTag.status(
                      label: statusText,
                      color: statusColor,
                      backgroundColor: statusBgColor,
                      borderRadius: 20,
                      isDark: isDark,
                    ),
                    if (canUpdate) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _showCreateEditPetitionModal(context, petitionToEdit: petition),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.white10 : AppColors.badgeBlueBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.edit_outlined, size: 14, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                AppTag.status(
                  label: timingText,
                  color: timingText == 'QUÁ HẠN' ? AppColors.overdue : AppColors.done,
                  backgroundColor: timingText == 'QUÁ HẠN' ? AppColors.badgeRedBg : AppColors.badgeGreenBg,
                  borderRadius: 4,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Obx(() {
      final isSelected = selectedPetitionIds.contains(petition.id);

      if (isMultiSelectMode.value && canDelete) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => togglePetitionSelection(petition.id),
                activeColor: Colors.red,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => togglePetitionSelection(petition.id),
                child: card,
              ),
            ),
          ],
        );
      } else if (canDelete) {
        return Dismissible(
          key: ValueKey('petition_${petition.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
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
            _deleteSinglePetition(petition.id);
          },
          child: GestureDetector(
            onTap: () => _showPetitionDetails(context, petition, isDark),
            child: card,
          ),
        );
      } else {
        return GestureDetector(
          onTap: () => _showPetitionDetails(context, petition, isDark),
          child: card,
        );
      }
    });
  }
}
