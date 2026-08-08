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
              color: Colors.black.withOpacity(0.1),
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
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Cố định vị trí các nút (quan trọng nếu có > 3 nút)
          elevation: 0,

          // Danh sách các tab
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.how_to_vote_outlined),
              activeIcon: Icon(Icons.how_to_vote),
              label: 'Bầu cử',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Thông báo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'Tài liệu',
            ),
          ],
        ),
      ),
    );
  }
}