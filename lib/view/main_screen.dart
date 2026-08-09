import 'package:app_baucu_version1/controllers/navigation.dart';
import 'package:app_baucu_version1/controllers/theme_controller.dart';
import 'package:app_baucu_version1/view/document/document_screen.dart';
import 'package:app_baucu_version1/view/home/home_screen.dart';
import 'package:app_baucu_version1/view/task/task_screen.dart';
import 'package:app_baucu_version1/view/statistic/statistic_screen.dart';
import 'package:app_baucu_version1/view/user/user_screen.dart';
import 'package:app_baucu_version1/view/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.put( NavigationController());
    return GetBuilder<ThemeController>(builder: (themeController)=> Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedSwitcher(duration: Duration(milliseconds: 200),
        child: Obx(
            ()=> IndexedStack(
              key: ValueKey(navigationController.currentIndex.value),
              index: navigationController.currentIndex.value,
              children: [
                const HomeScreen(),
                TaskScreen(type: 'sent'),
                TaskScreen(type: 'received'),
                const DocumentScreen(),
                const StatisticScreen(),
                const ProfileScreen(),
              ],
            )
        ),
      ),
      bottomNavigationBar: CustomBottomNavbar(),
    ),);
  }
}
