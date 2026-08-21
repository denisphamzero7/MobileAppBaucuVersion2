import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../service/petition_service.dart';
import '../../../untils/app_colors.dart';
import 'petition_info_tab.dart';
import 'petition_result_tab.dart';
import 'petition_progress_dialog.dart';

class PetitionDetailsBottomSheet extends StatefulWidget {
  final PetitionItemModel initialPetition;
  final bool isDark;
  final VoidCallback onRefreshParent;
  final Function(PetitionItemModel petition) onEditPetition;

  const PetitionDetailsBottomSheet({
    super.key,
    required this.initialPetition,
    required this.isDark,
    required this.onRefreshParent,
    required this.onEditPetition,
  });

  static void show(
    BuildContext context, {
    required PetitionItemModel petition,
    required bool isDark,
    required VoidCallback onRefreshParent,
    required Function(PetitionItemModel petition) onEditPetition,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => PetitionDetailsBottomSheet(
        initialPetition: petition,
        isDark: isDark,
        onRefreshParent: onRefreshParent,
        onEditPetition: onEditPetition,
      ),
    );
  }

  @override
  State<PetitionDetailsBottomSheet> createState() => _PetitionDetailsBottomSheetState();
}

class _PetitionDetailsBottomSheetState extends State<PetitionDetailsBottomSheet> {
  final PetitionService _petitionService = PetitionService();
  late PetitionItemModel _petition;
  int _selectedTab = 0; // 0: Thông tin, 1: Kết quả
  bool _isUnlocking = false;

  @override
  void initState() {
    super.initState();
    _petition = widget.initialPetition;
  }

  bool get _isLocked {
    final s = _petition.processingStatus.toLowerCase();
    return s == 'completed' || s == 'done' || s == 'cancelled';
  }

  Future<void> _handleUnlock() async {
    setState(() => _isUnlocking = true);
    try {
      final res = await _petitionService.updatePetition(_petition.id, {
        'processing_status': 'processing',
      });
      if (res != null) {
        setState(() {
          _petition = res.data;
        });
        widget.onRefreshParent();
        Get.snackbar(
          'Thành công',
          'Đã mở khóa đơn thư để tiếp tục xử lý.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Lỗi', 'Không thể mở khóa đơn thư', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Thao tác thất bại: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isUnlocking = false);
    }
  }

  void _confirmDelete() {
    Get.defaultDialog(
      title: 'Xác nhận xóa',
      middleText: 'Bạn có chắc chắn muốn xóa đơn thư này?',
      textConfirm: 'Xóa',
      textCancel: 'Hủy',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back(); // close confirm dialog
        Navigator.pop(context); // close bottom sheet
        final success = await _petitionService.deletePetition(_petition.id);
        if (success) {
          widget.onRefreshParent();
          Get.snackbar(
            'Thành công',
            'Đã xóa đơn thư thành công',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
          );
        } else {
          Get.snackbar('Lỗi', 'Không thể xóa đơn thư này', backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final authCtrl = Get.find<AuthController>();
    final canUpdate = authCtrl.can('update', 'TaskAssignmentPetitions');
    final canDelete = authCtrl.can('destroy', 'TaskAssignmentPetitions');

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: [
              // 1. Drag Handle
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

              // 2. Title & Close (X) button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      _petition.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.textHeading,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white10 : AppColors.borderLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 17,
                        color: isDark ? AppColors.white70 : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Lock warning banner (if in finished/locked status)
              if (_isLocked) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.warningBorder, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 20, color: AppColors.warningOrange),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Đơn thư đang ở trạng thái kết thúc (Khóa cập nhật)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warningText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (canUpdate)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warningOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: const Size(60, 34),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: _isUnlocking ? null : _handleUnlock,
                          child: _isUnlocking
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Mở khóa', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 4. Segmented 2-tab switch (Thông tin & Kết quả)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white10 : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? (isDark ? AppColors.cardDark : AppColors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Thông tin',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _selectedTab == 0
                                    ? AppColors.primary
                                    : (isDark ? AppColors.white70 : AppColors.textMuted),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? (isDark ? AppColors.cardDark : AppColors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Kết quả',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _selectedTab == 1
                                    ? AppColors.primary
                                    : (isDark ? AppColors.white70 : AppColors.textMuted),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 5. Tab View Content (Scrollable)
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    if (_selectedTab == 0)
                      PetitionInfoTab(
                        petition: _petition,
                        isDark: isDark,
                      )
                    else
                      PetitionResultTab(
                        petition: _petition,
                        isDark: isDark,
                      ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),

              // 6. Bottom Actions
              Column(
                children: [
                  // Full-width "Cập nhật tiến độ" button (in Tab 0 and editable)
                  if (_selectedTab == 0 && canUpdate && !_isLocked) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          PetitionProgressDialog.show(
                            context,
                            petition: _petition,
                            isDark: isDark,
                            onSuccess: (updated) {
                              setState(() {
                                _petition = updated;
                              });
                              widget.onRefreshParent();
                            },
                          );
                        },
                        icon: const Icon(Icons.check_box_outlined, size: 18),
                        label: const Text(
                          'Cập nhật tiến độ',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Row: "Sửa đơn" + "Xóa đơn"
                  Row(
                    children: [
                      if (canUpdate)
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppColors.white10 : AppColors.badgeBlueBg,
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onEditPetition(_petition);
                              },
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text(
                                'Sửa đơn',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      if (canUpdate && canDelete) const SizedBox(width: 12),
                      if (canDelete)
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppColors.dangerBg.withValues(alpha: 0.2) : AppColors.dangerBg,
                                foregroundColor: AppColors.dangerText,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: _confirmDelete,
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text(
                                'Xóa đơn',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
