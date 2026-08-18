import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/user_controller.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_strings.dart';
import '../../auth/signin_screen.dart';

class UserSecurityTab extends StatefulWidget {
  final bool isDark;

  const UserSecurityTab({
    super.key,
    required this.isDark,
  });

  @override
  State<UserSecurityTab> createState() => _UserSecurityTabState();
}

class _UserSecurityTabState extends State<UserSecurityTab> {
  final UserController userController = Get.find<UserController>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Đổi mật khẩu
        _buildPasswordCard(widget.isDark),
        const SizedBox(height: 14),

        // 2. Chế độ giao diện (Dark / Light Theme)
        _buildThemeCard(widget.isDark),
        const SizedBox(height: 14),

        // 3. Đăng xuất
        _buildLogoutButton(widget.isDark),
      ],
    );
  }

  Widget _buildPasswordCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.changePassword,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  color: isDark ? Colors.white : AppColors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mật khẩu mới
          Obx(() => TextField(
            controller: _passwordController,
            obscureText: _obscurePassword.value,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : AppColors.black87,
            ),
            decoration: InputDecoration(
              labelText: AppStrings.newPassword,
              labelStyle: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.white70 : AppColors.grey[700],
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: isDark ? AppColors.white70 : AppColors.grey[600],
                ),
                onPressed: () => _obscurePassword.toggle(),
              ),
            ),
          )),
          const SizedBox(height: 12),
          // Xác nhận mật khẩu
          Obx(() => TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword.value,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : AppColors.black87,
            ),
            decoration: InputDecoration(
              labelText: AppStrings.confirmPassword,
              labelStyle: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.white70 : AppColors.grey[700],
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: isDark ? AppColors.white70 : AppColors.grey[600],
                ),
                onPressed: () => _obscureConfirmPassword.toggle(),
              ),
            ),
          )),
          const SizedBox(height: 16),
          // Nút bấm Đổi mật khẩu
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () async {
                final pwd = _passwordController.text.trim();
                final confirmPwd = _confirmPasswordController.text.trim();

                if (pwd.isEmpty || confirmPwd.isEmpty) {
                  Get.snackbar(AppStrings.notificationTitle, 'Vui lòng nhập đầy đủ thông tin mật khẩu', snackPosition: SnackPosition.TOP);
                  return;
                }
                if (pwd != confirmPwd) {
                  Get.snackbar(AppStrings.notificationTitle, 'Mật khẩu xác nhận không khớp', snackPosition: SnackPosition.TOP);
                  return;
                }

                final success = await userController.changePassword(pwd, confirmPwd);
                if (success) {
                  _passwordController.clear();
                  _confirmPasswordController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Obx(() => userController.isChangingPassword.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      AppStrings.changePassword,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: isDark ? Colors.amber : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.themeMode,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.black87,
                  ),
                ),
                Text(
                  isDark ? AppStrings.themeDark : AppStrings.themeLight,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.white70 : AppColors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isDark,
            activeColor: AppColors.primary,
            onChanged: (val) {
              Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Xác nhận đăng xuất'),
              content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text(AppStrings.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(AppStrings.logout, style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await userController.logout();
            Get.offAll(() => const SigninScreen());
          }
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
        label: const Text(
          AppStrings.logout,
          style: TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.red.withValues(alpha: 0.04),
        ),
      ),
    );
  }
}
