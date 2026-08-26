import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/task_controller.dart';
import '../../untils/app_colors.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/smart_skeleton_wrapper.dart';
import 'widgets/statistic_top_filters_widget.dart';
import 'widgets/statistic_status_grid_widget.dart';
import 'widgets/statistic_timing_grid_widget.dart';
import 'widgets/statistic_doughnut_charts_widget.dart';
import 'widgets/statistic_distribution_widget.dart';
import 'widgets/statistic_task_documents_widget.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final TaskController taskController = Get.isRegistered<TaskController>()
      ? Get.find<TaskController>()
      : Get.put(TaskController());

  final RxInt activeDistributionTab = 0.obs;
  final RxInt _documentPage = 1.obs;
  static const int _docsPerPage = 5;

  @override
  void initState() {
    super.initState();
    taskController.fetchStats();
  }

  Future<void> _refreshStats() async {
    await taskController.fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'Thống kê công việc',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        foregroundColor: isDark ? AppColors.white : AppColors.black87,
      ),
      body: SafeArea(
        child: Obx(() {
          final isSkeleton = taskController.isStatsLoading.value;

          return SmartSkeletonWrapper(
            showSkeleton: isSkeleton,
            skeleton: AppSkeleton.statisticPageLayout(),
            onRefresh: _refreshStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Bộ lọc thời gian & đơn vị
                  StatisticTopFiltersWidget(
                    taskController: taskController,
                    isDark: isDark,
                    onRefresh: _refreshStats,
                  ),
                  const SizedBox(height: 12),

                  // 2. Lưới trạng thái xử lý
                  StatisticStatusGridWidget(
                    taskController: taskController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // 3. Lưới tiến độ công việc
                  StatisticTimingGridWidget(
                    taskController: taskController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // 4. Biểu đồ tròn Doughnut charts
                  StatisticDoughnutChartsWidget(
                    taskController: taskController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // 5. Phân bố chi tiết theo Phòng ban / Loại CV
                  StatisticDistributionWidget(
                    taskController: taskController,
                    activeDistributionTab: activeDistributionTab,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // 6. Danh sách văn bản giao việc (kèm phân trang)
                  StatisticTaskDocumentsWidget(
                    taskController: taskController,
                    documentPage: _documentPage,
                    docsPerPage: _docsPerPage,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
