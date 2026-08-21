import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/api_constants.dart';
import '../../../untils/app_colors.dart';
import '../../../untils/app_textstyles.dart';
import '../../widgets/Status_info_card.dart';

class HomeHeaderSection extends StatelessWidget {
  final bool isDark;

  const HomeHeaderSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepBlue, AppColors.darkBlue, AppColors.primary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(top: 10, left: 12, right: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Profile Header row
          Obx(() {
            final user = authController.currentUser.value;
            return Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.badgeRedBg, width: 1.5),
                    color: AppColors.blueGrey,
                  ),
                  child: ClipOval(
                    child: (user != null && user.avatar.isNotEmpty)
                        ? Image.network(
                            user.avatar.startsWith('http')
                                ? user.avatar
                                : '${ApiConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '')}${user.avatar}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, color: AppColors.white, size: 30),
                          )
                        : const Icon(Icons.person, color: AppColors.white, size: 30),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'XIN CHÀO',
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.waving_hand, color: AppColors.textOrangeAlert, size: 12),
                        ],
                      ),
                      Text(
                        user?.name ?? 'Admin',
                        style: AppTextStyle.bodyLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 10),

          // Overview Statistics Card Overlay
          StatusInfoCard(whiteColor: AppColors.white),
        ],
      ),
    );
  }
}
