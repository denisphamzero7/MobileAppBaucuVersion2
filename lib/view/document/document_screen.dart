import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation.dart';
import '../../controllers/auth_controller.dart';
import '../../untils/app_colors.dart';
import '../../service/petition_service.dart';
import '../../core/widgets/import_excel_button.dart';
import '../../core/widgets/export_excel_button.dart';
import '../../view/widgets/quick_action_bottom_sheet.dart';
import '../../view/widgets/skeleton_loader.dart';
import '../../view/task/widgets/stat_card_widget.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final RxString selectedStatusFilter = 'all'.obs;
  final RxString searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();
  
  final PetitionService _petitionService = PetitionService();
  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  final Rxn<DepartmentModel> selectedDepartment = Rxn<DepartmentModel>();

  final RxList<PetitionItemModel> petitionsList = <PetitionItemModel>[].obs;
  final Rx<PetitionStatsModel> stats = PetitionStatsModel().obs;
  final RxBool isLoading = false.obs;

  // Multi-select & Bulk Delete
  final RxBool isMultiSelectMode = false.obs;
  final RxSet<int> selectedPetitionIds = <int>{}.obs;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    isLoading.value = true;
    await Future.wait([
      _fetchPetitions(),
      _fetchStats(),
      _fetchDepartments(),
    ]);
    isLoading.value = false;
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

  Future<void> _onRefresh() async {
    await Future.wait([
      _fetchPetitions(),
      _fetchStats(),
      _fetchDepartments(),
    ]);
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

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '--/--/----';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
      }
    } catch (_) {}
    return rawDate;
  }

  void _showDepartmentFilterModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lọc theo phòng ban',
                    style: TextStyle(
                      fontSize: 16,
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
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Tất cả phòng ban',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selectedDepartment.value == null ? FontWeight.bold : FontWeight.normal,
                    color: selectedDepartment.value == null ? AppColors.primary : (isDark ? AppColors.white70 : AppColors.black87),
                  ),
                ),
                trailing: selectedDepartment.value == null ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  selectedDepartment.value = null;
                  Navigator.pop(ctx);
                  _fetchPetitions();
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: departments.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final dept = departments[index];
                    final isSelected = selectedDepartment.value?.id == dept.id;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        dept.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : (isDark ? AppColors.white70 : AppColors.black87),
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                      onTap: () {
                        selectedDepartment.value = dept;
                        Navigator.pop(ctx);
                        _fetchPetitions();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateEditPetitionModal(BuildContext context, {PetitionItemModel? petitionToEdit}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = petitionToEdit != null;

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
                            'sender_phone': senderPhoneCtrl.text.trim(),
                            'sender_email': senderEmailCtrl.text.trim(),
                            'sender_cccd': senderCccdCtrl.text.trim(),
                            'sender_address': senderAddressCtrl.text.trim(),
                            'department_id': selectedDeptId,
                            'content': contentCtrl.text.trim(),
                            'processing_status': selectedStatus,
                          };
                          if (deadlineDate != null) {
                            payload['deadline_date'] = '${deadlineDate!.year}-${deadlineDate!.month.toString().padLeft(2, '0')}-${deadlineDate!.day.toString().padLeft(2, '0')}';
                          }

                          Navigator.pop(ctx);

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
    final authCtrl = Get.find<AuthController>();
    final canUpdate = authCtrl.can('update', 'TaskAssignmentPetitions');
    final canDelete = authCtrl.can('destroy', 'TaskAssignmentPetitions');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    petition.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Status & Timing Badges Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildPetitionStatusBadge(petition.processingStatus, isDark),
                      _buildPetitionTimingBadge(petition),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Progress Bar Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white10 : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tiến độ xử lý',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.white70 : AppColors.grey[800],
                              ),
                            ),
                            Text(
                              '${petition.completionPercent}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (petition.completionPercent / 100).clamp(0.0, 1.0),
                            backgroundColor: isDark ? AppColors.white10 : AppColors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              petition.completionPercent >= 100
                                  ? AppColors.done
                                  : AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow('Người gửi:', petition.senderName),
                  if (petition.senderCccd != null && petition.senderCccd!.isNotEmpty)
                    _buildDetailRow('Số CCCD:', petition.senderCccd!),
                  if (petition.senderPhone != null && petition.senderPhone!.isNotEmpty)
                    _buildDetailRow('Số điện thoại:', petition.senderPhone!),
                  if (petition.senderEmail != null && petition.senderEmail!.isNotEmpty)
                    _buildDetailRow('Email:', petition.senderEmail!),
                  if (petition.senderAddress != null && petition.senderAddress!.isNotEmpty)
                    _buildDetailRow('Địa chỉ:', petition.senderAddress!),
                  _buildDetailRow('Phòng ban xử lý:', petition.departmentName),
                  _buildDetailRow('Ngày tiếp nhận:', _formatDate(petition.submissionDate)),
                  _buildDetailRow('Hạn xử lý:', _formatDate(petition.deadlineDate)),
                  if (petition.completedAt != null && petition.completedAt!.isNotEmpty)
                    _buildDetailRow('Ngày hoàn thành:', _formatDate(petition.completedAt)),
                  if (petition.documentNumber != null && petition.documentNumber!.isNotEmpty)
                    _buildDetailRow('Số hiệu văn bản:', petition.documentNumber!),
                  const SizedBox(height: 12),
                  const Text('Nội dung phản ánh:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardItemDark : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      petition.content.isNotEmpty ? petition.content : 'Không có nội dung chi tiết',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  if (petition.responseContent != null && petition.responseContent!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Nội dung trả lời:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardItemDark : AppColors.badgeGreenBg.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        petition.responseContent!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Actions row in details bottom sheet
                  Row(
                    children: [
                      if (canDelete) ...[
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Get.defaultDialog(
                              title: 'Xác nhận xóa',
                              middleText: 'Bạn có chắc chắn muốn xóa đơn thư này?',
                              textConfirm: 'Xóa',
                              textCancel: 'Hủy',
                              confirmTextColor: Colors.white,
                              buttonColor: Colors.red,
                              onConfirm: () {
                                Get.back();
                                _deleteSinglePetition(petition.id);
                              },
                            );
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Xóa', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (canUpdate) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showCreateEditPetitionModal(context, petitionToEdit: petition);
                            },
                            icon: const Icon(Icons.edit_note_rounded, size: 18),
                            label: const Text('Cập nhật đơn thư', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildPetitionStatusBadge(String status, bool isDark) {
    Color color;
    Color bgColor;
    String label;

    switch (status.toLowerCase()) {
      case 'new':
      case 'todo':
        color = AppColors.grey[700]!;
        bgColor = isDark ? AppColors.white10 : AppColors.lightBg;
        label = 'Mới tiếp nhận';
        break;
      case 'processing':
      case 'in_progress':
        color = AppColors.primary;
        bgColor = AppColors.badgeBlueBg;
        label = 'Đang xử lý';
        break;
      case 'completed':
      case 'done':
        color = AppColors.done;
        bgColor = AppColors.badgeGreenBg;
        label = 'Hoàn thành';
        break;
      case 'paused':
        color = AppColors.paused;
        bgColor = AppColors.bgYellowLight;
        label = 'Tạm dừng';
        break;
      case 'cancelled':
        color = AppColors.overdue;
        bgColor = AppColors.badgeRedBg;
        label = 'Đã hủy';
        break;
      default:
        color = AppColors.grey[700]!;
        bgColor = isDark ? AppColors.white10 : AppColors.lightBg;
        label = status;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPetitionTimingBadge(PetitionItemModel petition) {
    Color color = AppColors.done;
    Color bgColor = AppColors.badgeGreenBg;
    String label = 'Đúng hạn';

    if (petition.isOverdue || petition.timingStatus == 'overdue') {
      color = AppColors.overdue;
      bgColor = AppColors.badgeRedBg;
      label = 'Quá hạn';
    } else if (petition.timingStatus == 'late') {
      color = AppColors.late;
      bgColor = AppColors.bgYellowLight;
      label = 'Trễ hạn';
    } else if (petition.timingStatus == 'early') {
      color = AppColors.early;
      bgColor = AppColors.badgeGreenBg;
      label = 'Sớm hạn';
    } else if (petition.timingStatus == 'upcoming') {
      color = AppColors.primary;
      bgColor = AppColors.badgeBlueBg;
      label = 'Chưa đến hạn';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
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
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 120.0),
            child: Obx(() {
              final st = stats.value;
              final dynamicTotal = st.total > 0 ? st.total : petitionsList.length;
              final dynamicNew = st.todo > 0 ? st.todo : petitionsList.where((p) => p.processingStatus == 'new').length;
              final dynamicProcessing = st.inProgress > 0 ? st.inProgress : petitionsList.where((p) => p.processingStatus == 'processing').length;
              final dynamicCompleted = st.done > 0 ? st.done : petitionsList.where((p) => p.processingStatus == 'completed').length;
              final dynamicPaused = st.paused > 0 ? st.paused : petitionsList.where((p) => p.processingStatus == 'paused').length;
              final dynamicCancelled = st.cancelled > 0 ? st.cancelled : petitionsList.where((p) => p.processingStatus == 'cancelled').length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. SEARCH BAR & FILTER BUTTON
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
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.filter_alt_outlined,
                            size: 18,
                            color: selectedDepartment.value != null ? AppColors.primary : AppColors.grey,
                          ),
                          tooltip: 'Lọc theo phòng ban',
                          onPressed: () => _showDepartmentFilterModal(context, isDark),
                        ),
                      ),
                    ],
                  ),

                  if (selectedDepartment.value != null) ...[
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
                            'Phòng ban: ${selectedDepartment.value!.name}',
                            style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              selectedDepartment.value = null;
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
                    childAspectRatio: 1.4,
                    children: [
                      StatCardWidget(
                        label: 'Tổng đơn thư',
                        count: dynamicTotal,
                        icon: Icons.filter_list,
                        color: AppColors.primary,
                        isSelected: selectedStatusFilter.value == 'all',
                        onTap: () {
                          selectedStatusFilter.value = 'all';
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
                          _fetchPetitions();
                        },
                        isDark: isDark,
                      ),
                      StatCardWidget(
                        label: 'Đã hoàn thành',
                        count: dynamicCompleted,
                        icon: Icons.check_circle_outline,
                        color: AppColors.done,
                        isSelected: selectedStatusFilter.value == 'completed',
                        onTap: () {
                          selectedStatusFilter.value = 'completed';
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
                          _fetchPetitions();
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // C. LIST OF PETITIONS
                  if (isLoading.value && petitionsList.isEmpty)
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: petitionsList.length,
                      itemBuilder: (context, index) {
                        final petition = petitionsList[index];
                        return _buildPetitionCard(context, petition, isDark, canDelete, canUpdate);
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              );
            }),
          ),
        ),
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
              decoration: const BoxDecoration(
                color: AppColors.paused,
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
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.white : AppColors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.white10 : AppColors.lightBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            petition.senderName,
                            style: TextStyle(fontSize: 9, color: isDark ? AppColors.white70 : AppColors.grey[700]),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.circle, size: 3, color: AppColors.grey),
                        const SizedBox(width: 6),
                        Text('Hạn: $deadlineStr', style: const TextStyle(fontSize: 9, color: AppColors.grey)),
                        const SizedBox(width: 6),
                        const Icon(Icons.circle, size: 3, color: AppColors.grey),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.badgeBlueBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '• ${petition.completionPercent}%',
                            style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: timingText == 'QUÁ HẠN' ? AppColors.badgeRedBg : AppColors.badgeGreenBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    timingText,
                    style: TextStyle(
                      color: timingText == 'QUÁ HẠN' ? AppColors.overdue : AppColors.done,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => togglePetitionSelection(petition.id),
              activeColor: Colors.red,
            ),
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
