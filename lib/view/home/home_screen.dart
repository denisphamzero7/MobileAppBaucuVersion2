import 'package:app_baucu_version1/controllers/theme_controller.dart';
import 'package:app_baucu_version1/untils/app_textstyles.dart'; // Import AppTextStyle
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:intl/intl.dart'; // Cần thêm intl vào pubspec.yaml để format ngày

import 'package:app_baucu_version1/view/user/user_screen.dart';
import 'package:app_baucu_version1/view/widgets/weather_info_card.dart';
import 'package:app_baucu_version1/controllers/navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Lấy theme hiện tại
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Màu primary từ AppThemes
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER SECTION
              _buildHeader(context, isDark),

              const SizedBox(height: 24),

              // 2. WEATHER & INFO CARD (Hero Section)
              WeatherInfoCard(primaryColor: primaryColor),

              const SizedBox(height: 24),

              // 3. MARQUEE (Tin tức chạy)
              _buildNewsTicker(context, isDark, primaryColor),

              const SizedBox(height: 24),

              // 4. MENU CHỨC NĂNG (Ví dụ các tính năng của app bầu cử)
              Text(
                "Dịch vụ trực tuyến",
                style: AppTextStyle.h3.copyWith(
                    color: theme.textTheme.bodyLarge?.color
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureGrid(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET CON: HEADER ---
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(2), // Border width
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                'assets/images/logo.png',
                errorBuilder: (ctx, err, stack) => Icon(Icons.how_to_vote, color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, Cử tri!',
                style: AppTextStyle.bodySmall.copyWith(color: Colors.grey),
              ),
              Text(
                'TP. Đà Nẵng',
                style: AppTextStyle.h2.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        // Actions
        Row(
          children: [
            _buildIconButton(
              icon: Icons.notifications_outlined,
              onTap: () {
                try {
                  final navigationController = Get.find<NavigationController>();
                  navigationController.changeIndex(2); // 2 is NotificationScreen tab
                } catch (e) {
                  // Fallback
                }
              },
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            GetBuilder<ThemeController>(
              builder: (controller) => _buildIconButton(
                icon: controller.isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined,
                onTap: () => controller.toggleTheme(),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              icon: Icons.person_outline,
              onTap: () => Get.to(() => const ProfileScreen()),
              isDark: isDark,
            ),
          ],
        )
      ],
    );
  }

  // Helper button cho header
  Widget _buildIconButton({required IconData icon, required VoidCallback onTap, required bool isDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }

  // --- WIDGET CON: NEWS TICKER ---
  Widget _buildNewsTicker(BuildContext context, bool isDark, Color primaryColor) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.blue[100]!,
          )
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: double.infinity,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                bottomLeft: Radius.circular(11),
              ),
            ),
            child: Center(
              child: Text(
                "TIN TỨC",
                style: AppTextStyle.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Marquee(
              text: "Ủy ban bầu cử thành phố Đà Nẵng thông báo về việc niêm yết danh sách cử tri tại các khu vực bỏ phiếu...",
              style: AppTextStyle.bodyMedium.copyWith(
                color: isDark ? Colors.white : Colors.blue[900],
              ),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 20.0,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 1),
              startPadding: 10.0,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: GRID CHỨC NĂNG ---
  Widget _buildFeatureGrid(BuildContext context, bool isDark) {
    // Danh sách các tính năng giả định
    final features = [
      {'icon': Icons.qr_code_scanner, 'label': 'Quét thẻ', 'color': Colors.orange},
      {'icon': Icons.person_search, 'label': 'Cử tri', 'color': Colors.blue},
      {'icon': Icons.description_outlined, 'label': 'Văn bản', 'color': Colors.green},
      {'icon': Icons.how_to_vote, 'label': 'Điểm bầu cử', 'color': Colors.purple},
      {'icon': Icons.bar_chart, 'label': 'Kết quả', 'color': Colors.red},
      {'icon': Icons.support_agent, 'label': 'Hỗ trợ', 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 cột
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final item = features[index];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                item['label'] as String,
                style: AppTextStyle.labelMedium.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
      },
    );
  }
}