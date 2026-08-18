import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/api_constants.dart';
import '../../../core/widgets/app_divider.dart';
import '../../../model/profile.dart';
import '../../../untils/app_strings.dart';
import '../../widgets/organization_selection_dialog.dart';

class ProfileTopCard extends StatelessWidget {
  final ProfileData profile;
  final bool isDark;

  const ProfileTopCard({
    super.key,
    required this.profile,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final String initialLetter = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U';
    final String nowStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2155FA), Color(0xFF4A34D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2155FA).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar & User Info
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                alignment: Alignment.center,
                child: (profile.avatar != null && profile.avatar!.isNotEmpty)
                    ? ClipOval(
                        child: Image.network(
                          ApiConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '') + profile.avatar!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            initialLetter,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        initialLetter,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'ID: ${profile.id}  •  ${profile.role?.name ?? AppStrings.defaultRole}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Dòng kẻ phân cách mỏng bán trong suốt
          AppDivider.white(
            height: 20,
            thickness: 0.8,
            opacity: 0.2,
          ),

          // Row 2: Tổ chức hiện tại Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.currentOrganization,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.apartment_rounded, color: Color(0xFFFFD700), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => Text(
                        authController.currentOrganizationName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showOrganizationSelection(context, authController),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sync_rounded, size: 13, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                AppStrings.change,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Row 3: Đăng nhập lần cuối
          Row(
            children: [
              Text(
                AppStrings.lastLogin,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Text(
                nowStr,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrganizationSelection(BuildContext context, AuthController authController) {
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
}
