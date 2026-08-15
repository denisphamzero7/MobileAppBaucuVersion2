import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/log_activity_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../model/profile.dart';
import '../../untils/app_textstyles.dart';
import '../../../untils/app_colors.dart';
import '../../core/api_constants.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/organization_selection_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();
  late final LogActivityController logController;
  
  

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<LogActivityController>()) {
      logController = Get.put(LogActivityController());
    } else {
      logController = Get.find<LogActivityController>();
    }

    if (userController.userProfile.value == null) {
      userController.fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF5F6FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await userController.refreshProfile();
            await logController.fetchLogs();
            await logController.fetchTimelineStats();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Obx(() {
              if (userController.isLoading.value || userController.userProfile.value == null) {
                return _buildSkeletonLoader(context);
              }
              final profile = userController.userProfile.value!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopCard(context, profile, isDark),
                  const SizedBox(height: 16),
                  _buildTabBar(isDark),
                  const SizedBox(height: 16),
                  _buildTabContent(context, profile, isDark),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard(BuildContext context, ProfileData profile, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B58FF), Color(0xFF5A44E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B58FF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white24,
                ),
                child: ClipOval(
                  child: (profile.avatar != null && profile.avatar!.isNotEmpty)
                      ? Image.network(
                          ApiConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '') + profile.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40, color: Colors.white),
                        )
                      : const Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${profile.email != 'N/A' && profile.email.contains('@') ? profile.email.split('@').first : profile.id}',
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        profile.role?.name ?? 'Cán bộ / Nhân viên',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 16),
          Text(
            'Tổ chức hiện tại:',
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.business, color: Color(0xFFFFD700), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => Text(
                    authController.currentOrganizationName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đăng nhập lần cuối:',
                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
              ),
              Text(
                '08/08/2026 10:33:24', // Có thể thay bằng profile.lastLoginAt nếu model có
                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showOrganizationSelection(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chuyển tổ chức làm việc',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Đổi tổ chức >',
                      style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showOrganizationSelection(BuildContext context) {
    final orgs = authController.getAvailableOrganizations();
    
    Get.dialog(
      OrganizationSelectionDialog(
        organizations: orgs,
        isCancellable: true,
        onSelect: (orgId) {
          Get.back();
          if (orgId != authController.currentOrganizationId.value) {
            authController.changeOrganization(orgId);
          }
        },
        onCancel: () {
          Get.back();
        },
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildTabBar(bool isDark) {

    return Obx(() {
      final activeTab = logController.activeTabIndex.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabItem(0, 'Tổng Quan', Icons.show_chart, activeTab, isDark),
            const SizedBox(width: 8),
            _buildTabItem(1, 'Thông Tin Cá Nhân', Icons.person_outline, activeTab, isDark),
            const SizedBox(width: 8),
            _buildTabItem(2, 'Cài Đặt Bảo Mật', Icons.security, activeTab, isDark),
          ],
        ),
      );
    });
  }

  Widget _buildTabItem(int index, String label, IconData icon, int activeTab, bool isDark) {
    final isActive = index == activeTab;
    return GestureDetector(
      onTap: () => logController.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2B58FF) : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [BoxShadow(color: const Color(0xFF2B58FF).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, ProfileData profile, bool isDark) {
    return Obx(() {
      switch (logController.activeTabIndex.value) {
        case 0:
          return _buildOverviewTab(isDark);
        case 1:
          return _buildPersonalInfoTab(context, profile, isDark);
        case 2:
          return _buildSecurityTab(context, isDark);
        default:
          return const SizedBox();
      }
    });
  }

  Widget _buildOverviewTab(bool isDark) {
    return Column(
      children: [
        _buildTrendChart(isDark),
        const SizedBox(height: 16),
        _buildRecentActivities(isDark),
      ],
    );
  }

  Widget _buildTrendChart(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: Color(0xFF8A2BE2), size: 18),
              const SizedBox(width: 8),
              Text(
                'XU HƯỚNG HOẠT ĐỘNG',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1000,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
                  getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'T${value.toInt()}/26',
                            style: const TextStyle(color: Colors.grey, fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1000,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value == 0 ? '0' : '${(value / 1000).toStringAsFixed(0)}.000',
                          style: const TextStyle(color: Colors.grey, fontSize: 9),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    left: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    right: const BorderSide(color: Colors.transparent),
                    top: const BorderSide(color: Colors.transparent),
                  ),
                ),
                minX: 1,
                maxX: 12,
                minY: 0,
                maxY: 6000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 0), FlSpot(2, 0), FlSpot(3, 0), FlSpot(4, 0),
                      FlSpot(5, 0), FlSpot(6, 0), FlSpot(7, 5200), FlSpot(8, 3600),
                      FlSpot(9, 0), FlSpot(10, 0), FlSpot(11, 0), FlSpot(12, 0),
                    ],
                    isCurved: true,
                    color: const Color(0xFF8A2BE2),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 2,
                          color: const Color(0xFF8A2BE2),
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8A2BE2).withOpacity(0.3),
                          const Color(0xFF8A2BE2).withOpacity(0.01),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Color(0xFF00ACC1), size: 18),
              const SizedBox(width: 8),
              Text(
                'HOẠT ĐỘNG GẦN ĐÂY',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (logController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (logController.logs.isEmpty) {
              return const Center(child: Text("Không có hoạt động nào", style: TextStyle(color: Colors.grey)));
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logController.logs.length > 5 ? 5 : logController.logs.length,
              separatorBuilder: (context, index) => const Divider(height: 24, color: Colors.black12),
              itemBuilder: (context, index) {
                final log = logController.logs[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, color: Color(0xFF00ACC1), size: 8),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00ACC1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.method,
                        style: const TextStyle(color: Color(0xFF00ACC1), fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.description,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            log.ipAddress,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      log.createdAt,
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(BuildContext context, ProfileData profile, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THÔNG TIN CÁ NHÂN',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _InfoItem(icon: Icons.alternate_email, label: 'Email', value: profile.email),
          _InfoItem(icon: Icons.fingerprint, label: 'ID Người dùng', value: profile.id),
          // _InfoItem(icon: Icons.security, label: 'Admin', value: profile.role?.name.toLowerCase() == 'admin' ? 'Có' : 'Không'),
        ],
      ),
    );
  }

  Widget _buildSecurityTab(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CÀI ĐẶT BẢO MẬT',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 16),
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
                style: AppTextStyle.bodySmall.copyWith(fontSize: 11, color: AppColors.grey),
              ),
              subtitle: Text(
                themeController.isDarkMode ? 'Giao diện tối' : 'Giao diện sáng',
                style: AppTextStyle.bodyLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              trailing: Switch(
                value: themeController.isDarkMode,
                onChanged: (val) => themeController.toggleTheme(),
                activeThumbColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const Divider(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar('Thông báo', 'Đang thực hiện đăng xuất...', snackPosition: SnackPosition.TOP);
                userController.logout();
              },
              icon: const Icon(Icons.logout, size: 18, color: Colors.white),
              label: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

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
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}