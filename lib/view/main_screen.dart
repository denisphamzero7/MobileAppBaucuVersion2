import 'package:app_baucu_version1/controllers/navigation.dart';
import 'package:app_baucu_version1/controllers/theme_controller.dart';
import 'package:app_baucu_version1/view/document/document_screen.dart';
import 'package:app_baucu_version1/view/task_document/task_document_screen.dart';
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
  final NavigationController navigationController = Get.isRegistered<NavigationController>()
      ? Get.find<NavigationController>()
      : Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Obx(
          () => IndexedStack(
            index: navigationController.currentIndex.value,
            children: const [
              HomeScreen(),
              TaskScreen(type: 'sent'),
              TaskScreen(type: 'received'),
              DocumentScreen(),
              TaskDocumentScreen(),
              StatisticScreen(),
              ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavbar(),
      ),
    );
  }
}
