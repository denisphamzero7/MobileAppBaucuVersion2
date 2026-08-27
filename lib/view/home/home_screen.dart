import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../core/widgets/app_refresher.dart';
import '../../untils/app_colors.dart';
import 'widgets/home_header_section.dart';
import 'widgets/home_doughnut_charts_section.dart';
import 'widgets/home_distribution_section.dart';
import 'widgets/home_management_menu.dart';
import 'widgets/home_latest_tasks_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TaskController taskController = Get.isRegistered<TaskController>()
      ? Get.find<TaskController>()
      : Get.put(TaskController());

  // Active pill selection for PHÂN BỐ CHI TIẾT (0 = Phòng Ban, 1 = Loại CV)
  final RxInt activeDistributionTab = 0.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHomeScreen();
    });
  }

  Future<void> _refreshHomeScreen() async {
    await Future.wait([
      taskController.refreshTasks(),
      taskController.fetchDepartments(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: AppRefresher(
          onRefresh: _refreshHomeScreen,
          child: Column(
            children: [
              // 1. BLUE HEADER AREA (Contains User Profile & StatusInfoCard)
              HomeHeaderSection(isDark: isDark),

              // 2. MAIN BODY (White-ish background)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    // A. TWO DOUGHNUT CHARTS SIDE-BY-SIDE
                    HomeDoughnutChartsSection(isDark: isDark),

                    const SizedBox(height: 16),

                    // B. PHÂN BỐ CHI TIẾT SECTION
                    HomeDistributionSection(
                      isDark: isDark,
                      activeDistributionTab: activeDistributionTab,
                    ),

                    const SizedBox(height: 16),

                    // C. DANH MỤC QUẢN LÝ
                    HomeManagementMenu(isDark: isDark),

                    const SizedBox(height: 16),

                    // D. CÔNG VIỆC MỚI NHẤT
                    HomeLatestTasksSection(isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
