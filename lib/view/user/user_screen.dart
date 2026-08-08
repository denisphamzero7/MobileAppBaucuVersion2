import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../model/profile.dart';

// --- STYLES CƠ BẢN ---
final TextStyle h4 = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
final TextStyle bodyMedium = const TextStyle(fontSize: 16);
final TextStyle bodySmall = const TextStyle(fontSize: 14);


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
        title: Text('Hồ sơ Người dùng', style: h4.copyWith(color: isDark ? Colors.white : Colors.black)),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : Colors.white,
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
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 16),

        // Tên người dùng
        Text(
          profile.name ?? 'Chưa cập nhật tên',
          style: h4.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Vai trò (Role)
        Text(
          'Vai trò: ${profile.role?.name ?? 'Khách'}',
          style: bodyMedium.copyWith(color: Theme.of(context).primaryColor),
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

        const SizedBox(height: 32),

        // Nút Đăng xuất
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.snackbar(
                  'Thông báo',
                  'Đang thực hiện đăng xuất...',
                  backgroundColor: Colors.blue,
                  snackPosition: SnackPosition.BOTTOM
              );
              // Sử dụng authController đã được truyền vào
              authController.logout();

            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          Text(
            'Lỗi tải dữ liệu!',
            style: h4.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: bodyMedium,
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
                  style: bodySmall.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}