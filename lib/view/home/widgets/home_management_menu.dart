import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/navigation.dart';
import '../../../untils/app_colors.dart';
import '../../user/user_screen.dart';

class HomeManagementMenu extends StatelessWidget {
  final bool isDark;

  const HomeManagementMenu({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DANH MỤC QUẢN LÝ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: [
              _buildDirectoryButton(
                'Công việc đang giao',
                Icons.send_outlined,
                AppColors.badgeBlueBg,
                AppColors.primary,
                () => Get.find<NavigationController>().changeIndex(1),
                isDark,
              ),
              _buildDirectoryButton(
                'Công việc được giao',
                Icons.mail_outline,
                AppColors.badgeGreenBg,
                AppColors.done,
                () => Get.find<NavigationController>().changeIndex(2),
                isDark,
              ),
              _buildDirectoryButton(
                'Đơn thư & Kiến nghị',
                Icons.description_outlined,
                AppColors.bgYellowLight,
                AppColors.paused,
                () => Get.find<NavigationController>().changeIndex(3),
                isDark,
              ),
              _buildDirectoryButton(
                'Văn bản giao việc',
                Icons.insert_drive_file_outlined,
                AppColors.badgeBlueBg,
                AppColors.primary,
                () => Get.find<NavigationController>().changeIndex(4),
                isDark,
              ),
              _buildDirectoryButton(
                'Thống kê & Báo cáo',
                Icons.pie_chart_outline,
                AppColors.bgPurpleLight,
                AppColors.todo,
                () => Get.find<NavigationController>().changeIndex(5),
                isDark,
              ),
              _buildDirectoryButton(
                'Thông tin cá nhân',
                Icons.person_outline,
                AppColors.badgeBlueBg,
                AppColors.inProgress,
                () => Get.to(() => const ProfileScreen()),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryButton(
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardItemDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.white10 : AppColors.black.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.white10 : bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDark ? AppColors.white : iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
