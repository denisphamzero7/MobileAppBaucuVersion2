import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../untils/app_colors.dart';

class CustomSnackbar {
  static void show(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? AppColors.red : AppColors.snackbarBlue,
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

  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.done,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
    );
  }

  static void showError(String title, String message) {
    show(title, message, isError: true);
  }

  static void showWarning(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.paused,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.warning_amber_outlined, color: AppColors.white),
    );
  }
}




