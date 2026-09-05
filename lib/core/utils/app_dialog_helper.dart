import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../untils/app_colors.dart';

/// ============================================================================
/// 💬 [AppDialogHelper] - TIỆN ÍCH DIALOG & POPUP TOÀN ỨNG DỤNG
/// ============================================================================
class AppDialogHelper {
  AppDialogHelper._();

  /// Hiển thị Dialog xác nhận xóa chuẩn
  static Future<bool> confirmDelete({
    String title = 'Xác nhận xóa',
    required String message,
    String confirmText = 'Xóa',
    String cancelText = 'Hủy',
    Color buttonColor = Colors.red,
    Color confirmTextColor = Colors.white,
    Color? cancelTextColor,
  }) async {
    final result = await Get.defaultDialog<bool>(
      title: title,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      middleText: message,
      middleTextStyle: const TextStyle(fontSize: 13.5),
      textConfirm: confirmText,
      textCancel: cancelText,
      confirmTextColor: confirmTextColor,
      buttonColor: buttonColor,
      cancelTextColor: cancelTextColor ?? AppColors.textMain,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    return result ?? false;
  }

  /// Hiển thị Dialog xác nhận hành động bất kỳ
  static Future<bool> confirm({
    String title = 'Xác nhận',
    required String message,
    String confirmText = 'Đồng ý',
    String cancelText = 'Hủy',
    Color confirmColor = AppColors.primary,
    Color confirmTextColor = Colors.white,
    Color? cancelTextColor,
  }) async {
    final result = await Get.defaultDialog<bool>(
      title: title,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      middleText: message,
      middleTextStyle: const TextStyle(fontSize: 13.5),
      textConfirm: confirmText,
      textCancel: cancelText,
      confirmTextColor: confirmTextColor,
      buttonColor: confirmColor,
      cancelTextColor: cancelTextColor ?? AppColors.textMain,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    return result ?? false;
  }

  /// Hiển thị Loading Dialog toàn màn hình
  static void showLoading({String message = 'Đang xử lý...'}) {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 14),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black87,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Đóng Loading Dialog
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Hiển thị Snackbar thành công
  static void showSuccess(String message, {String title = 'Thành công'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.done,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  /// Hiển thị Snackbar lỗi
  static void showError(String message, {String title = 'Lỗi'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
