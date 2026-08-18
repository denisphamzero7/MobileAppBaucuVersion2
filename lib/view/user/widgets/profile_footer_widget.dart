import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_strings.dart';

/// [ProfileFooterWidget] - Widget chân trang (Footer) thông tin bản quyền & đơn vị phát triển
/// Toàn bộ chuỗi văn bản được lấy từ [AppStrings] để dễ dàng thay đổi và bảo trì.
class ProfileFooterWidget extends StatelessWidget {
  final bool isDark;

  const ProfileFooterWidget({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final orgName = authController.currentOrganizationName.isNotEmpty &&
                    authController.currentOrganizationName != 'Chưa chọn tổ chức'
                ? authController.currentOrganizationName.toUpperCase()
                : AppStrings.defaultOrgName;
            return Text(
              '© ${AppStrings.copyrightYear} · $orgName',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: isDark ? Colors.white70 : AppColors.black87,
              ),
              textAlign: TextAlign.center,
            );
          }),
          const SizedBox(height: 4),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? AppColors.white30 : AppColors.grey[600],
              ),
              children: [
                const TextSpan(text: '${AppStrings.designedBy} '),
                TextSpan(
                  text: AppStrings.developerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
