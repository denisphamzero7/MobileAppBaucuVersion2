import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class CanAccess extends StatelessWidget {
  final String action;
  final String subject;
  final Widget child;
  final Widget? fallback;

  const CanAccess({
    Key? key,
    required this.action,
    required this.subject,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Obx(() {
      // Gọi hàm can() từ AuthController
      if (authController.can(action, subject)) {
        return child; // Có quyền -> Vẽ ra Widget
      }
      return fallback ?? const SizedBox.shrink(); // Không quyền -> Ẩn đi hoàn toàn
    });
  }
}
