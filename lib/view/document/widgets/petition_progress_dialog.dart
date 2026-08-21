import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../service/petition_service.dart';
import '../../../untils/app_colors.dart';

class PetitionProgressDialog extends StatefulWidget {
  final PetitionItemModel petition;
  final bool isDark;
  final Function(PetitionItemModel updated) onSuccess;

  const PetitionProgressDialog({
    super.key,
    required this.petition,
    required this.isDark,
    required this.onSuccess,
  });

  static void show(
    BuildContext context, {
    required PetitionItemModel petition,
    required bool isDark,
    required Function(PetitionItemModel updated) onSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => PetitionProgressDialog(
        petition: petition,
        isDark: isDark,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<PetitionProgressDialog> createState() => _PetitionProgressDialogState();
}

class _PetitionProgressDialogState extends State<PetitionProgressDialog> {
  final PetitionService _petitionService = PetitionService();
  late String _selectedStatus;
  late double _progress;
  late TextEditingController _docNumberCtrl;
  late TextEditingController _docExcerptCtrl;
  late TextEditingController _responseContentCtrl;
  bool _isLoading = false;

  final List<Map<String, String>> _statuses = [
    {'key': 'new', 'label': 'Mới tiếp nhận'},
    {'key': 'processing', 'label': 'Đang xử lý'},
    {'key': 'completed', 'label': 'Đã hoàn thành'},
    {'key': 'paused', 'label': 'Tạm dừng'},
    {'key': 'cancelled', 'label': 'Đã hủy'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.petition.processingStatus;
    _progress = widget.petition.completionPercent.toDouble();
    _docNumberCtrl = TextEditingController(text: widget.petition.documentNumber ?? '');
    _docExcerptCtrl = TextEditingController(text: widget.petition.documentExcerpt ?? '');
    _responseContentCtrl = TextEditingController(text: widget.petition.responseContent ?? '');
  }

  @override
  void dispose() {
    _docNumberCtrl.dispose();
    _docExcerptCtrl.dispose();
    _responseContentCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final formattedNow = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final payload = <String, dynamic>{
        'processing_status': _selectedStatus,
        'completion_percent': _progress.toInt(),
        'document_number': _docNumberCtrl.text.trim(),
        'document_excerpt': _docExcerptCtrl.text.trim(),
        'response_content': _responseContentCtrl.text.trim(),
      };

      if (_selectedStatus == 'completed' || _selectedStatus == 'done') {
        payload['completed_at'] = formattedNow;
      }

      final res = await _petitionService.updatePetition(widget.petition.id, payload);
      if (res != null) {
        if (!mounted) return;
        Navigator.pop(context);
        widget.onSuccess(res.data);
        Get.snackbar(
          'Thành công',
          'Đã cập nhật tiến độ đơn thư',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Lỗi', 'Không thể cập nhật tiến độ', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Cập nhật thất bại: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
                  'Cập nhật tiến độ Đơn thư',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Form inputs
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Trạng thái xử lý
                    _buildLabel('Trạng thái xử lý', isDark),
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
                          value: _selectedStatus,
                          dropdownColor: isDark ? AppColors.cardDark : AppColors.white,
                          items: _statuses.map((s) => DropdownMenuItem<String>(
                            value: s['key']!,
                            child: Text(s['label']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedStatus = val;
                                if (val == 'completed' || val == 'done') {
                                  _progress = 100;
                                } else if (val == 'processing' && _progress == 0) {
                                  _progress = 50;
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Phần trăm hoàn thành
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('Tiến độ hoàn thành', isDark),
                        Text(
                          '${_progress.toInt()}%',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    Slider(
                      value: _progress,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _progress = val),
                    ),
                    const SizedBox(height: 12),

                    // 3. Số ký hiệu văn bản
                    _buildLabel('Số ký hiệu văn bản', isDark),
                    _buildTextField(_docNumberCtrl, 'Nhập số ký hiệu (vd: 123/UBND)...', isDark),
                    const SizedBox(height: 14),

                    // 4. Trích yếu văn bản
                    _buildLabel('Trích yếu văn bản', isDark),
                    _buildTextField(_docExcerptCtrl, 'Nhập trích yếu văn bản...', isDark),
                    const SizedBox(height: 14),

                    // 5. Nội dung trả lời
                    _buildLabel('Nội dung trả lời công dân', isDark),
                    _buildTextField(_responseContentCtrl, 'Nhập kết quả, nội dung phúc đáp công dân...', isDark, maxLines: 3),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Lưu tiến độ & Kết quả',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.white70 : AppColors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, bool isDark, {int maxLines = 1}) {
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
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
