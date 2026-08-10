import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../untils/app_colors.dart';

class CustomSnackbar {
  static void show(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? AppColors.red : AppColors.snackbarBlue, // Đồng bộ màu sắc chung (hoặc đỏ nếu lỗi)
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: AppColors.white,
      ),
    );
  }
}



