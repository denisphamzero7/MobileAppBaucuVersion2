import '../../untils/app_colors.dart';
import '../../core/enums/common_enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation.dart';


class CustomBottomNavbar extends StatefulWidget {
  const CustomBottomNavbar({super.key});

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  // Gọi Controller đã tạo
  final NavigationController navigationController = Get.find<NavigationController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // Sử dụng Obx để giao diện tự vẽ lại khi selectedIndex thay đổi
    return Obx(
          () => Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          // Các thuộc tính cơ bản
          currentIndex: navigationController.currentIndex.value,
          onTap: (index) => navigationController.changeIndex(index),

          // Style cho thanh menu
          backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: isDark ? AppColors.grey[600] : AppColors.grey[400],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Cố định vị trí các nút (quan trọng nếu có > 3 nút)
          elevation: 0,
          iconSize: 20,
          selectedFontSize: 9,
          unselectedFontSize: 9,
          selectedLabelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),

          // Danh sách các tab tự động sinh từ Enum
          items: AppNavigationTab.values.map((tab) {
            return BottomNavigationBarItem(
              icon: Icon(tab.icon),
              activeIcon: Icon(tab.activeIcon),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}


