import '../untils/app_colors.dart';
import 'package:app_baucu_version1/controllers/auth_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth/signin_screen.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';


class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});
  final AuthController authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    // navigate base on auth state after 2.5 seconds
    // CHÚ Ý: Phiên bản này có lỗi logic về thời gian (microseconds: 2500)
    Future.delayed(const Duration(milliseconds: 2500), (){
      // Cần dùng .value cho RxBool
      if(authController.isFirstTime.value){
        Get.off(()=> const OnboardingScreen());
      }else if(authController.isLoggedIn.value){
        Get.off(()=> const MainScreen());
      }else{
        Get.off(()=> const SigninScreen());
      }
    }
    );


    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.6)
            ],
          ),
        ),
        child: Stack(
          children: [
            // background pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: const GridPattern(color: AppColors.white),
              ),
            ),
            // main content (Icon, Title, Subtitle)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Túi Xách (Icon Bag)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    builder: (context, value, child) {
                      return Opacity(opacity: value,
                        child: Transform.translate(offset: Offset(0, 20*(1-value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Theme.of(context).primaryColor, // Màu icon dùng themePrimaryColor
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Text "FASHION STORE"
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    builder: (context, value, child) {
                      return Opacity(opacity: value,
                        child: Transform.translate(offset: Offset(0, 20*(1-value)),
                          child: child,
                        ),
                      );
                    },
                    child: const Column(
                      children: [
                        Text(
                          "FASHION",
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 8
                          ),
                        ),
                        Text(
                          "STORE",
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 8
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Subtitle "Style Meets Simplicity" (Đặt ở dưới cùng)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                builder: (context, value, child) {
                  return Opacity(opacity: value,
                    child: Transform.translate(offset: Offset(0, 20*(1-value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'Style Meets Simplicity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Giữ nguyên các lớp Grid
class GridPattern extends StatelessWidget {
  final Color color;
  const GridPattern({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(color: color),
      size: Size.infinite,
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    final spacing = 20.0;

    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


