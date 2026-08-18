import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../controllers/log_activity_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/navigation.dart';
import '../../model/profile.dart';
import '../../untils/app_colors.dart';
import '../../untils/app_strings.dart';
import '../widgets/skeleton_loader.dart';

import 'widgets/profile_top_card.dart';
import 'widgets/profile_footer_widget.dart';
import 'widgets/user_overview_tab.dart';
import 'widgets/user_personal_info_tab.dart';
import 'widgets/user_security_tab.dart';

import 'widgets/user_activity_log_tab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController userController = Get.find<UserController>();
  late final LogActivityController logController;
  late final NotificationController notificationController;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<LogActivityController>()) {
      logController = Get.put(LogActivityController());
    } else {
      logController = Get.find<LogActivityController>();
    }

    if (!Get.isRegistered<NotificationController>()) {
      notificationController = Get.put(NotificationController());
    } else {
      notificationController = Get.find<NotificationController>();
    }

    if (userController.userProfile.value == null) {
      userController.fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP APP BAR
            _buildCustomAppBar(context, isDark),

            // 2. MAIN SCROLLABLE BODY
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await userController.refreshProfile();
                  await logController.fetchLogs();
                  await logController.fetchTimelineStats();
                  await notificationController.fetchNotifications();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 30.0),
                  child: Obx(() {
                    if (userController.isLoading.value || userController.userProfile.value == null) {
                      return _buildSkeletonLoader(context);
                    }
                    final profile = userController.userProfile.value!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Profile Header
                        ProfileTopCard(profile: profile, isDark: isDark),
                        const SizedBox(height: 14),

                        // Tab Bar Selector
                        _buildTabBar(isDark),
                        const SizedBox(height: 14),

                        // Tab Content Router
                        _buildTabContent(context, profile, isDark),
                        const SizedBox(height: 14),

                        // Footer bản quyền & đơn vị phát triển dùng chung
                        ProfileFooterWidget(isDark: isDark),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. TOP APP BAR ---
  Widget _buildCustomAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (Get.isRegistered<NavigationController>()) {
                Get.find<NavigationController>().changeIndex(0);
              } else {
                Navigator.maybePop(context);
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 26,
                color: isDark ? Colors.white : AppColors.black87,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              AppStrings.userOverviewTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Nút Capsule Right Actions (... | X)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _showMoreOptions(context, isDark),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                      color: isDark ? AppColors.white70 : AppColors.black87,
                    ),
                  ),
                ),
                Container(
                  height: 14,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: isDark ? AppColors.white24 : AppColors.black12,
                ),
                InkWell(
                  onTap: () {
                    if (Get.isRegistered<NavigationController>()) {
                      Get.find<NavigationController>().changeIndex(0);
                    } else {
                      Navigator.maybePop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark ? AppColors.white70 : AppColors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              title: const Text('Làm mới thông tin'),
              onTap: () {
                Navigator.pop(ctx);
                userController.refreshProfile();
                logController.fetchLogs();
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. TAB BAR SELECTOR ---
  Widget _buildTabBar(bool isDark) {
    return Obx(() {
      final activeTab = logController.activeTabIndex.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildTabItem(0, 'Tổng Quan', Icons.show_chart_rounded, activeTab, isDark),
            const SizedBox(width: 8),
            _buildTabItem(1, 'Thông Tin Cá Nhân', Icons.person_outline_rounded, activeTab, isDark),
            const SizedBox(width: 8),
            _buildTabItem(2, 'Cài Đặt Bảo Mật', Icons.security_rounded, activeTab, isDark),
            const SizedBox(width: 8),
            _buildTabItem(3, 'Nhật Ký Cá Nhân', Icons.verified_user_outlined, activeTab, isDark),
          ],
        ),
      );
    });
  }

  Widget _buildTabItem(int index, String label, IconData icon, int activeTab, bool isDark) {
    final isActive = index == activeTab;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => logController.changeTab(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF2155FA)
                : (isDark ? AppColors.cardDark : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF2155FA)
                  : (isDark ? AppColors.white10 : AppColors.black.withValues(alpha: 0.05)),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF2155FA).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    )
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : (isDark ? Colors.white70 : AppColors.grey[700]),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  color: isActive ? Colors.white : (isDark ? Colors.white70 : AppColors.black87),
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 3. TAB CONTENT ROUTER ---
  Widget _buildTabContent(BuildContext context, ProfileData profile, bool isDark) {
    return Obx(() {
      switch (logController.activeTabIndex.value) {
        case 0:
          return UserOverviewTab(isDark: isDark);
        case 1:
          return UserPersonalInfoTab(profile: profile, isDark: isDark);
        case 2:
          return UserSecurityTab(isDark: isDark);
        case 3:
          return UserActivityLogTab(isDark: isDark);
        default:
          return const SizedBox();
      }
    });
  }

  // --- SKELETON LOADER CHUẨN ---
  Widget _buildSkeletonLoader(BuildContext context) {
    return AppSkeleton.profilePageLayout();
  }
}