import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../model/task_model.dart';
import '../../untils/app_colors.dart';
import '../widgets/skeleton_loader.dart';

class CreateTaskScreen extends StatefulWidget {

  final TaskModel? taskToUpdate;

  const CreateTaskScreen({super.key, this.taskToUpdate});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TaskController _controller = Get.find<TaskController>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  
  int? _selectedDocumentId;
  int? _selectedItemTypeId;
  String _priority = 'medium';
  String _deadlineType = 'has_deadline';
  DateTime? _startDate;
  DateTime? _endDate;
  final List<int> _selectedAssigneeIds = [];

  bool _isLoading = false;

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'low', 'label': 'Thấp', 'color': Colors.green},
    {'value': 'medium', 'label': 'Trung bình', 'color': Colors.orange},
    {'value': 'high', 'label': 'Cao', 'color': Colors.deepOrange},
    {'value': 'urgent', 'label': 'Khẩn cấp', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToUpdate?.name ?? '');
    _contentController = TextEditingController(text: widget.taskToUpdate?.description ?? '');
    
    if (widget.taskToUpdate != null) {
      final t = widget.taskToUpdate!;
      _selectedDocumentId = t.taskAssignmentDocumentId;
      _selectedItemTypeId = t.taskAssignmentItemTypeId;
      _priority = t.priority.isNotEmpty ? t.priority : 'medium';
      _deadlineType = t.deadlineType.isNotEmpty ? t.deadlineType : 'has_deadline';
      if (t.assigneeIds != null && t.assigneeIds!.isNotEmpty) {
        _selectedAssigneeIds.addAll(t.assigneeIds!);
      }

      if (t.startAt != null && t.startAt!.isNotEmpty) {
        try {
          _startDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(t.startAt!);
        } catch (_) {}
      }

      if (t.endAt != null && t.endAt!.isNotEmpty) {
        try {
          _endDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(t.endAt!);
        } catch (_) {}
      }
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 3));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchMetadata();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context, {required bool isStart}) async {
    final initial = (isStart ? _startDate : _endDate) ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );

      final result = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? 0,
        pickedTime?.minute ?? 0,
      );

      setState(() {
        if (isStart) {
          _startDate = result;
        } else {
          _endDate = result;
        }
      });
    }
  }

  void _showAssigneePicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final users = _controller.usersList;
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chọn người xử lý',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Xong', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: users.isEmpty
                        ? const Center(child: Text('Không có dữ liệu nhân viên'))
                        : ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final isSelected = _selectedAssigneeIds.contains(user.id);
                              return CheckboxListTile(
                                value: isSelected,
                                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: user.email.isNotEmpty ? Text(user.email, style: const TextStyle(fontSize: 12)) : null,
                                secondary: CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.15),
                                  child: Text(
                                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onChanged: (val) {
                                  setModalState(() {
                                    if (val == true) {
                                      _selectedAssigneeIds.add(user.id);
                                    } else {
                                      _selectedAssigneeIds.remove(user.id);
                                    }
                                  });
                                  setState(() {});
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
      },
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. Kiểm tra thời hạn
    if (_deadlineType == 'has_deadline' && _endDate == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn thời gian kết thúc/hạn chót', backgroundColor: Colors.red[100]);
      return;
    }

    // 2. Kiểm tra người xử lý
    if (_selectedAssigneeIds.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng chọn ít nhất một người xử lý (người nhận việc)', backgroundColor: Colors.red[100]);
      return;
    }

    // 3. Lấy ID người giao việc (User hiện tại)
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id ??
        int.tryParse(GetStorage().read('userId')?.toString() ?? '') ??
        (GetStorage().read('userInfo') != null ? int.tryParse(GetStorage().read('userInfo')['id']?.toString() ?? '') : null) ?? 1;

    // 4. Lấy ID văn bản giao việc (mặc định lấy văn bản đầu tiên hoặc 1)
    int? docId = _selectedDocumentId;
    if (docId == null && _controller.taskDocuments.isNotEmpty) {
      docId = _controller.taskDocuments.first.id;
    }
    docId ??= 1;

    // 5. Lấy ID loại công việc (mặc định loại đầu tiên hoặc 1)
    int? typeId = _selectedItemTypeId;
    if (typeId == null && _controller.itemTypes.isNotEmpty) {
      typeId = _controller.itemTypes.first.id;
    }
    typeId ??= 1;

    // 6. Tạo mảng users theo cấu trúc chi tiết backend yêu cầu:
    // [{ "user_id": 5, "department_id": 1, "department_role": "main", "assignment_role": "main" }]
    final defaultDeptId = _controller.departments.isNotEmpty ? _controller.departments.first.id : 1;

    final usersPayload = _selectedAssigneeIds.map((userId) {
      final userObj = _controller.usersList.firstWhereOrNull((u) => u.id == userId);
      final deptId = userObj?.departmentId ?? defaultDeptId;
      final deptRole = (userObj?.departmentRole == 'cooperate') ? 'cooperate' : 'main';
      final assignRole = (userObj?.assignmentRole == 'support') ? 'support' : 'main';

      return {
        'user_id': userId,
        'department_id': deptId,
        'department_role': deptRole,
        'assignment_role': assignRole,
      };
    }).toList();


    setState(() {
      _isLoading = true;
    });

    final payload = <String, dynamic>{
      'name': _titleController.text.trim(),
      'title': _titleController.text.trim(),
      'description': _contentController.text.trim(),
      'priority': _priority,
      'deadline_type': _deadlineType,
      'processing_status': widget.taskToUpdate?.processingStatus ?? 'todo',
      'task_assignment_document_id': docId,
      'document_id': docId,
      'task_assignment_item_type_id': typeId,
      'type_id': typeId,
      'assigned_by': currentUserId,
      'users': usersPayload,
      'assignee_ids': _selectedAssigneeIds,
      'user_ids': _selectedAssigneeIds,
    };



    if (_startDate != null) {
      payload['start_at'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(_startDate!);
    }
    if (_endDate != null) {
      payload['end_at'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(_endDate!);
      payload['deadline'] = DateFormat('yyyy-MM-dd').format(_endDate!);
    }

    bool success = false;
    if (widget.taskToUpdate == null) {
      success = await _controller.createTask(payload);
    } else {
      success = await _controller.updateTask(widget.taskToUpdate!.id, payload);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        Get.back();
        Get.snackbar(
          'Thành công',
          widget.taskToUpdate == null ? 'Đã tạo công việc mới thành công!' : 'Đã cập nhật công việc thành công!',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUpdate = widget.taskToUpdate != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          isUpdate ? 'Cập nhật công việc' : 'Tạo công việc mới',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: isDark ? AppColors.black : AppColors.white,
        foregroundColor: isDark ? AppColors.white : AppColors.black87,
      ),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoadingMetadata.value) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: const [
                  SkeletonLoader(
                    child: SkeletonBox(width: double.infinity, height: 48, radius: 10),
                  ),
                  SizedBox(height: 16),
                  SkeletonLoader(
                    child: SkeletonBox(width: double.infinity, height: 48, radius: 10),
                  ),
                  SizedBox(height: 16),
                  SkeletonLoader(
                    child: SkeletonBox(width: double.infinity, height: 100, radius: 10),
                  ),
                  SizedBox(height: 16),
                  SkeletonLoader(
                    child: SkeletonBox(width: double.infinity, height: 48, radius: 10),
                  ),
                ],
              ),
            );
          }


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: VĂN BẢN & THÔNG TIN CHUNG ---
                  _buildSectionTitle('THÔNG TIN CHUNG', isDark),
                  const SizedBox(height: 12),

                  // Dropdown chọn văn bản giao việc
                  _buildDocumentDropdown(isDark),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _titleController,
                    label: 'Tên / Tiêu đề công việc *',
                    hint: 'Nhập tên công việc...',
                    isDark: isDark,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tên công việc' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _contentController,
                    label: 'Nội dung chi tiết',
                    hint: 'Nhập mô tả chi tiết công việc...',
                    isDark: isDark,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 24),
                  // --- SECTION 2: PHÂN LOẠI & MỨC ĐỘ ƯU TIÊN ---
                  _buildSectionTitle('PHÂN LOẠI & MỨC ĐỘ', isDark),
                  const SizedBox(height: 12),

                  _buildItemTypeDropdown(isDark),
                  const SizedBox(height: 16),

                  _buildPrioritySelector(isDark),

                  const SizedBox(height: 24),
                  // --- SECTION 3: THỜI GIAN THỰC HIỆN ---
                  _buildSectionTitle('THỜI GIAN & TIẾN ĐỘ', isDark),
                  const SizedBox(height: 12),

                  _buildDeadlineTypeToggle(isDark),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDateCard(
                          label: 'Bắt đầu',
                          date: _startDate,
                          isDark: isDark,
                          onTap: () => _pickDateTime(context, isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateCard(
                          label: 'Hạn chót *',
                          date: _endDate,
                          isDark: isDark,
                          onTap: _deadlineType == 'has_deadline' ? () => _pickDateTime(context, isStart: false) : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // --- SECTION 4: PHÂN CÔNG NGƯỜI XỬ LÝ ---
                  _buildSectionTitle('PHÂN CÔNG XỬ LÝ', isDark),
                  const SizedBox(height: 12),

                  _buildAssigneeSelector(isDark),

                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              isUpdate ? 'LƯU THAY ĐỔI' : 'TẠO CÔNG VIỆC',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: isDark ? AppColors.grey[400] : AppColors.grey[600],
      ),
    );
  }

  Widget _buildDocumentDropdown(bool isDark) {
    final docs = _controller.taskDocuments;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: docs.any((d) => d.id == _selectedDocumentId) ? _selectedDocumentId : null,
          hint: Text('Chọn văn bản giao việc', style: TextStyle(color: AppColors.grey[500], fontSize: 15)),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
          items: docs.map((doc) {
            return DropdownMenuItem<int>(
              value: doc.id,
              child: Text(
                doc.name,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedDocumentId = val;
            });
          },
        ),
      ),
    );
  }

  Widget _buildItemTypeDropdown(bool isDark) {
    final types = _controller.itemTypes;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: types.any((t) => t.id == _selectedItemTypeId) ? _selectedItemTypeId : null,
          hint: Text('Chọn loại công việc', style: TextStyle(color: AppColors.grey[500], fontSize: 15)),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
          items: types.map((type) {
            return DropdownMenuItem<int>(
              value: type.id,
              child: Text(
                type.name,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedItemTypeId = val;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mức độ ưu tiên',
          style: TextStyle(fontSize: 13, color: isDark ? AppColors.grey[400] : AppColors.grey[700]),
        ),
        const SizedBox(height: 8),
        Row(
          children: _priorities.map((item) {
            final isSelected = _priority == item['value'];
            final Color itemColor = item['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _priority = item['value'] as String;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? itemColor.withOpacity(0.2) : (isDark ? AppColors.cardDark : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? itemColor : (isDark ? Colors.white10 : Colors.black12),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? itemColor : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeadlineTypeToggle(bool isDark) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Có thời hạn'),
          selected: _deadlineType == 'has_deadline',
          onSelected: (selected) {
            if (selected) {
              setState(() => _deadlineType = 'has_deadline');
            }
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: _deadlineType == 'has_deadline' ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: _deadlineType == 'has_deadline' ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Không có hạn'),
          selected: _deadlineType == 'no_deadline',
          onSelected: (selected) {
            if (selected) {
              setState(() => _deadlineType = 'no_deadline');
            }
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: _deadlineType == 'no_deadline' ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: _deadlineType == 'no_deadline' ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard({
    required String label,
    required DateTime? date,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.grey[500])),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date == null ? 'Chưa chọn' : DateFormat('dd/MM/yyyy HH:mm').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssigneeSelector(bool isDark) {
    final users = _controller.usersList;
    final selectedUsers = users.where((u) => _selectedAssigneeIds.contains(u.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showAssigneePicker(context, isDark),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedUsers.isEmpty ? 'Chọn người xử lý' : 'Đã chọn ${selectedUsers.length} người xử lý',
                    style: TextStyle(
                      color: selectedUsers.isEmpty ? AppColors.grey[500] : (isDark ? Colors.white : Colors.black87),
                      fontSize: 14,
                      fontWeight: selectedUsers.isEmpty ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey),
              ],
            ),
          ),
        ),
        if (selectedUsers.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedUsers.map((user) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
                label: Text(user.name, style: const TextStyle(fontSize: 12)),
                onDeleted: () {
                  setState(() {
                    _selectedAssigneeIds.remove(user.id);
                  });
                },
                deleteIconColor: Colors.grey,
                backgroundColor: isDark ? AppColors.cardDark : Colors.grey[200],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: AppColors.grey[500]),
        hintStyle: TextStyle(color: AppColors.grey[400]),
        filled: true,
        fillColor: isDark ? AppColors.cardDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: validator,
    );
  }
}