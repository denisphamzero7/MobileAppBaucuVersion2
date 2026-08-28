import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/petition_controller.dart';
import '../../../helper/date_helper.dart';
import '../../../model/department_model.dart';
import '../../../service/petition_service.dart';
import '../../../untils/app_colors.dart';

class PetitionFormModal {
  static void show(
    BuildContext context, {
    PetitionItemModel? petitionToEdit,
    required List<DepartmentModel> departments,
    required VoidCallback onSaved,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = petitionToEdit != null;
    final authCtrl = Get.find<AuthController>();
    final canCreate = authCtrl.can('create', 'TaskAssignmentPetitions');
    final canUpdate = authCtrl.can('update', 'TaskAssignmentPetitions');

    if (isEdit && !canUpdate) {
      Get.snackbar(
        'Từ chối truy cập',
        'Bạn không có quyền cập nhật đơn thư này.',
        backgroundColor: Colors.red.shade100,
      );
      return;
    }
    if (!isEdit && !canCreate) {
      Get.snackbar(
        'Từ chối truy cập',
        'Bạn không có quyền tạo đơn thư mới.',
        backgroundColor: Colors.red.shade100,
      );
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
    DateTime submissionDate = DateHelper.parseDateTime(petitionToEdit?.submissionDate) ?? DateTime.now();
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
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInputLabel('Ngày gửi đơn *', isDark),
                                      InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: submissionDate,
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2035),
                                          );
                                          if (picked != null) {
                                            setModalState(() {
                                              submissionDate = picked;
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 48,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: isDark ? AppColors.white10 : AppColors.lightBg,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: isDark ? AppColors.white10 : AppColors.black12),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${submissionDate.day.toString().padLeft(2, '0')}/${submissionDate.month.toString().padLeft(2, '0')}/${submissionDate.year}',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: isDark ? AppColors.white : AppColors.black87,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const Icon(Icons.calendar_month, size: 16, color: AppColors.primary),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
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
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: isDark ? AppColors.white10 : AppColors.lightBg,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: isDark ? AppColors.white10 : AppColors.black12),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  deadlineDate != null
                                                      ? '${deadlineDate!.day.toString().padLeft(2, '0')}/${deadlineDate!.month.toString().padLeft(2, '0')}/${deadlineDate!.year}'
                                                      : 'Chọn hạn',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: deadlineDate != null ? (isDark ? AppColors.white : AppColors.black87) : AppColors.grey,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
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
                            'submission_date': DateHelper.formatForApi(submissionDate, includeTime: false),
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

                          final petitionCtrl = Get.find<PetitionController>();
                          if (isEdit) {
                            final success = await petitionCtrl.updatePetition(petitionToEdit.id, payload);
                            if (success) {
                              Get.snackbar('Thành công', 'Đã cập nhật đơn thư', backgroundColor: Colors.green, colorText: Colors.white);
                              onSaved();
                            } else {
                              Get.snackbar('Lỗi', 'Cập nhật đơn thư thất bại', backgroundColor: Colors.red, colorText: Colors.white);
                            }
                          } else {
                            final success = await petitionCtrl.createPetition(payload);
                            if (success) {
                              Get.snackbar('Thành công', 'Đã tạo đơn thư mới thành công', backgroundColor: Colors.green, colorText: Colors.white);
                              onSaved();
                            } else {
                              Get.snackbar('Lỗi', 'Tạo đơn thư thất bại', backgroundColor: Colors.red, colorText: Colors.white);
                            }
                          }
                        },
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: Text(
                          isEdit ? 'LƯU THAY ĐỔI' : 'TẠO ĐƠN THƯ',
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

  static Widget _buildInputLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.grey : AppColors.black87,
        ),
      ),
    );
  }

  static Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isDark, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.white10 : AppColors.lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.white10 : AppColors.black12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.white : AppColors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
