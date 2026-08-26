import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/task_assignment_document_model.dart';
import '../../../model/department_model.dart';
import '../../../service/task_assignment_documents_service.dart';
import '../../../untils/app_colors.dart';

class TaskDocumentFormModal {
  static void show(
    BuildContext context, {
    TaskAssignmentDocumentModel? docToEdit,
    List<DepartmentModel>? departments,
    VoidCallback? onSaved,
  }) {
    final isEdit = docToEdit != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleCtrl = TextEditingController(text: docToEdit?.title ?? '');
    final docNumberCtrl = TextEditingController(text: docToEdit?.documentNumber ?? '');
    final descCtrl = TextEditingController(text: docToEdit?.description ?? '');
    String status = docToEdit?.status ?? 'published';
    int? selectedDeptId = docToEdit?.departmentId;
    final docService = TaskAssignmentDocumentsService();

    List<DepartmentModel> availableDepts = departments ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            // Tải danh sách phòng ban nếu chưa có
            if (availableDepts.isEmpty) {
              docService.getAvailableDepartments().then((res) {
                if (res != null && res.data.isNotEmpty && modalCtx.mounted) {
                  setModalState(() {
                    availableDepts = res.data;
                  });
                }
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(modalCtx).size.height * 0.85),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Chỉnh sửa văn bản' : 'Thêm mới văn bản giao việc',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.textHeading,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Tiêu đề văn bản *', isDark),
                            _buildTextField(titleCtrl, 'Nhập tên/trích yếu văn bản...', isDark),
                            const SizedBox(height: 14),

                            _buildInputLabel('Số ký hiệu văn bản', isDark),
                            _buildTextField(docNumberCtrl, 'Nhập số ký hiệu (vd: 123/UBND)...', isDark),
                            const SizedBox(height: 14),

                            _buildInputLabel('Trạng thái văn bản', isDark),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.white10 : AppColors.lightBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDark ? AppColors.white10 : AppColors.black12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: status,
                                  dropdownColor: isDark ? AppColors.cardDark : AppColors.white,
                                  items: const [
                                    DropdownMenuItem(value: 'published', child: Text('Đã ban hành', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                    DropdownMenuItem(value: 'draft', child: Text('Bản nháp', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => status = val);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            if (availableDepts.isNotEmpty) ...[
                              _buildInputLabel('Phòng ban phụ trách', isDark),
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
                                    hint: const Text('Chọn phòng ban', style: TextStyle(fontSize: 13)),
                                    dropdownColor: isDark ? AppColors.cardDark : AppColors.white,
                                    items: [
                                      const DropdownMenuItem<int?>(value: null, child: Text('Tất cả phòng ban', style: TextStyle(fontSize: 13))),
                                      ...availableDepts.map((d) => DropdownMenuItem<int?>(
                                        value: d.id,
                                        child: Text(d.name, style: const TextStyle(fontSize: 13)),
                                      )),
                                    ],
                                    onChanged: (val) => setModalState(() => selectedDeptId = val),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            _buildInputLabel('Trích yếu / Nội dung', isDark),
                            _buildTextField(descCtrl, 'Nhập tóm tắt nội dung văn bản...', isDark, maxLines: 3),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
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
                            Get.snackbar('Lỗi', 'Vui lòng nhập tiêu đề văn bản');
                            return;
                          }

                          final payload = <String, dynamic>{
                            'title': titleCtrl.text.trim(),
                            'document_number': docNumberCtrl.text.trim(),
                            'status': status,
                            'description': descCtrl.text.trim(),
                            if (selectedDeptId != null) 'department_id': selectedDeptId,
                          };

                          Navigator.pop(ctx);

                          if (isEdit) {
                            final res = await docService.updateDocument(docToEdit.id, payload);
                            if (res != null) {
                              Get.snackbar('Thành công', 'Đã cập nhật văn bản', backgroundColor: Colors.green, colorText: Colors.white);
                              onSaved?.call();
                            } else {
                              Get.snackbar('Lỗi', 'Cập nhật văn bản thất bại', backgroundColor: Colors.red, colorText: Colors.white);
                            }
                          } else {
                            final res = await docService.createDocument(payload);
                            if (res != null) {
                              Get.snackbar('Thành công', 'Đã tạo văn bản thành công', backgroundColor: Colors.green, colorText: Colors.white);
                              onSaved?.call();
                            } else {
                              Get.snackbar('Lỗi', 'Tạo văn bản thất bại', backgroundColor: Colors.red, colorText: Colors.white);
                            }
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(
                          isEdit ? 'Lưu thay đổi' : 'Tạo văn bản',
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

  static Widget _buildInputLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white70 : AppColors.textMain,
        ),
      ),
    );
  }

  static Widget _buildTextField(TextEditingController ctrl, String hint, bool isDark, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.white10 : AppColors.lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.white10 : AppColors.black12),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(fontSize: 13, color: isDark ? AppColors.white : AppColors.black87),
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
