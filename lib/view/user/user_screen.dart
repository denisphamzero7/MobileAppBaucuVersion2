import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../model/profile.dart';
import '../../helper/custom_snackbar.dart';
import '../../untils/app_textstyles.dart';
import '../../../untils/app_colors.dart';



class ProfileScreen extends GetView<UserController> {
  const ProfileScreen({super.key});

  // ⚠️ KHẮC PHỤC RACE CONDITION:
  // Biến static để đảm bảo fetchProfile chỉ được gọi một lần duy nhất
  static bool _hasFetched = false;

  @override
  Widget build(BuildContext context) {

    // 1. GỌI API CHỈ MỘT LẦN KHI MÀN HÌNH ĐƯỢC DỰNG LẦN ĐẦU
    if (!_hasFetched) {
      // Gọi fetchProfile() (đã được xóa khỏi onInit()) ở một thời điểm an toàn hơn.
      controller.fetchProfile();
      _hasFetched = true;
    }

    // Lấy AuthController (đã fix lỗi scope)
    final AuthController authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ sơ Người dùng', style: AppTextStyle.h3.copyWith(fontSize: 14, color: isDark ? AppColors.white : AppColors.black)),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.black : AppColors.white,
      ),
      body: SafeArea(
        // Sử dụng RefreshIndicator để kéo xuống làm mới
        child: RefreshIndicator(
          onRefresh: controller.fetchProfile, // Gọi lại hàm tải dữ liệu
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),

            // Obx để lắng nghe thay đổi từ Controller
            child: Obx(() {
              if (controller.isLoading.value && controller.userProfile.value == null) {
                // Hiển thị loading chỉ khi chưa có dữ liệu nào (lần tải đầu tiên)
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.errorMessage.isNotEmpty) {
                // Hiển thị lỗi nếu có
                return Center(
                  child: _buildErrorWidget(
                      context,
                      controller.errorMessage.value,
                      controller.fetchProfile
                  ),
                );
              }

              final profile = controller.userProfile.value;
              if (profile == null) {
                // Trường hợp profile là null và không phải loading
                return Center(
                  child: _buildErrorWidget(
                      context,
                      'Không tìm thấy dữ liệu hồ sơ.',
                      controller.fetchProfile
                  ),
                );
              }

              // 2. TRUYỀN AuthController XUỐNG HÀM HIỂN THỊ
              return _buildProfileData(context, profile, authController);
            }),
          ),
        ),
      ),
    );
  }

  // Widget hiển thị dữ liệu hồ sơ (ĐÃ CẬP NHẬT CHỮ KÝ HÀM)
  Widget _buildProfileData(BuildContext context, ProfileData profile, AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ảnh đại diện (Placeholder)
        const CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.blueGrey,
          child: Icon(Icons.person, size: 60, color: AppColors.white),
        ),
        const SizedBox(height: 16),

        // Tên người dùng
        Text(
          profile.name ?? 'Chưa cập nhật tên',
          style: AppTextStyle.h2.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Vai trò (Role)
        Text(
          'Vai trò: ${profile.role?.name ?? 'Khách'}',
          style: AppTextStyle.bodyLarge.copyWith(fontSize: 11, color: Theme.of(context).primaryColor),
        ),

        const Divider(height: 32),

        // Danh sách thông tin chi tiết
        _InfoItem(
          icon: Icons.alternate_email,
          label: 'Email',
          value: profile.email ?? 'N/A',
        ),
        _InfoItem(
          icon: Icons.fingerprint,
          label: 'ID Người dùng',
          value: profile.id ?? 'N/A',
        ),
        _InfoItem(
          icon: Icons.security,
          label: 'Admin',
          value: profile.role?.name?.toLowerCase() == 'admin' ? 'Có' : 'Không',
        ),
        
        const Divider(height: 16),

        // Cài đặt giao diện tối
        GetBuilder<ThemeController>(
          builder: (themeController) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            title: Text(
              'Chế độ giao diện',
              style: AppTextStyle.bodySmall.copyWith(fontSize: 9, color: AppColors.grey),
            ),
            subtitle: Text(
              themeController.isDarkMode ? 'Giao diện tối' : 'Giao diện sáng',
              style: AppTextStyle.bodyLarge.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
            ),
            trailing: Switch(
              value: themeController.isDarkMode,
              onChanged: (val) => themeController.toggleTheme(),
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Nút Đăng xuất
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              CustomSnackbar.show('Thông báo', 'Đang thực hiện đăng xuất...');
              // Sử dụng authController đã được truyền vào
              authController.logout();

            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget hiển thị lỗi và nút thử lại (GIỮ NGUYÊN)
  Widget _buildErrorWidget(BuildContext context, String message, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 80),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.red, size: 50),
          const SizedBox(height: 16),
          Text(
            'Lỗi tải dữ liệu!',
            style: AppTextStyle.h3.copyWith(fontSize: 14, color: AppColors.red),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyle.bodyMedium.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

// Widget con để hiển thị từng mục thông tin (GIỮ NGUYÊN)
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 9, color: AppColors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyle.bodyLarge.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


