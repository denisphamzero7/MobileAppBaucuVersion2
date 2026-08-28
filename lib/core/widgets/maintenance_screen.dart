import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../untils/app_colors.dart';

class MaintenanceScreen extends StatefulWidget {
  final String? title;
  final String? message;
  final String? expectedEndTime;
  final String? supportContact;
  final Future<bool> Function()? onCheckStatus;

  const MaintenanceScreen({
    super.key,
    this.title,
    this.message,
    this.expectedEndTime,
    this.supportContact,
    this.onCheckStatus,
  });

  /// Phương thức tiện ích để chuyển hướng toàn cục tới trang bảo trì
  static void open({
    String? title,
    String? message,
    String? expectedEndTime,
    String? supportContact,
    Future<bool> Function()? onCheckStatus,
  }) {
    Get.offAll(
      () => MaintenanceScreen(
        title: title,
        message: message,
        expectedEndTime: expectedEndTime,
        supportContact: supportContact,
        onCheckStatus: onCheckStatus,
      ),
      transition: Transition.fadeIn,
    );
  }

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  bool _isChecking = false;

  Future<void> _handleRetry() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      if (widget.onCheckStatus != null) {
        final isRestored = await widget.onCheckStatus!();
        if (isRestored) {
          Get.snackbar(
            'Thành công',
            'Hệ thống đã hoạt động trở lại!',
            backgroundColor: AppColors.done,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
      }
      // Giả lập kiểm tra mạng nếu không truyền callback
      await Future.delayed(const Duration(milliseconds: 1200));

      Get.snackbar(
        'Thông báo',
        'Hệ thống vẫn đang trong quá trình bảo trì. Vui lòng thử lại sau ít phút.',
        backgroundColor: AppColors.paused,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (_) {
      Get.snackbar(
        'Lỗi',
        'Không thể kết nối tới máy chủ. Vui lòng kiểm tra đường truyền mạng.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => false, // Chặn nút back vật lý khi đang bảo trì
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. ICON MINH HỌA BẢO TRÌ HIỆN ĐẠI
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.badgeBlueBg,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderBlue,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.build_circle_outlined,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 2. TIÊU ĐỀ
                  Text(
                    widget.title ?? 'Hệ thống đang bảo trì',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. NỘI DUNG THÔNG ĐIỆP
                  Text(
                    widget.message ??
                        'Chúng tôi đang tiến hành nâng cấp máy chủ để cải thiện tốc độ và mang đến trải nghiệm tốt nhất cho bạn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: isDark ? AppColors.white70 : AppColors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. THÔNG TIN THỜI GIAN DỰ KIẾN (NẾU CÓ)
                  if (widget.expectedEndTime != null && widget.expectedEndTime!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.warningOrange),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Dự kiến: ${widget.expectedEndTime}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warningOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ] else ...[
                    const SizedBox(height: 12),
                  ],

                  // 5. NÚT THỬ LẠI KẾT NỐI
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isChecking ? null : _handleRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isChecking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(
                        _isChecking ? 'Đang kiểm tra kết nối...' : 'Kiểm tra lại',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // 6. THÔNG TIN HỖ TRỢ DƯỚI CÙNG
                  if (widget.supportContact != null && widget.supportContact!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Hỗ trợ kỹ thuật: ${widget.supportContact}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.white30 : AppColors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
