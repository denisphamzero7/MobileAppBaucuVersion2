import '../untils/app_colors.dart';
import 'package:app_baucu_version1/controllers/auth_controller.dart';
import 'package:app_baucu_version1/untils/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth/signin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController  = PageController();
  int _currentPage = 0;
  final List<OnboardingItem> _item= [
    OnboardingItem(image: 'assets/images/dabieu.jpg', title: 'Tiến độ', description: 'You can change your apps source code, run the hot reload command in VS Code, then see the change in your running app'),
    OnboardingItem(image: 'assets/images/dabieu.jpg', title: 'Thông báo', description: 'Explore the Flutter sidebar'),
    OnboardingItem(image: 'assets/images/dabieu.jpg', title: 'Thời tiếc', description: 'To share colors and font styles throughout an app, use themes.'),
  ];
  @override
  Widget build(BuildContext context)
  {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _item.length,
            onPageChanged: (index){
              setState(() {
                _currentPage = index;
              });
            }, itemBuilder: (BuildContext context, int index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _item[index].image,
                    height: MediaQuery.of(context).size.height*0.4,
                  ),
                  const SizedBox(height: 40,),
                  Text(
                    _item[index].title,
                    style: AppTextStyle.withColor(AppTextStyle.h1, Theme.of(context).textTheme.bodyLarge!.color!),
                  ),
                  const SizedBox(height: 16,),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _item[index].description,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.withColor(AppTextStyle.bodyLarge, isDark? AppColors.grey[400]!: AppColors.grey[600]!),
                    ),
                  )

                ],
              );
          },
          ),
          Positioned(
            bottom: 80,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _item.length,
                    (index)=> AnimatedContainer(duration:Duration(microseconds: 300),
                    margin:EdgeInsets.symmetric(horizontal: 4) ,
                      height: 8,
                      width:_currentPage == index? 24:8 ,
                      decoration: BoxDecoration(
                        color: _currentPage == index? Theme.of(context).primaryColor:
                        (isDark?AppColors.grey[700]:AppColors.grey[300]),
                        borderRadius: BorderRadius.circular(4),
                      ) ,
                    )
                )
          )),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nút Skip
                TextButton(
                  onPressed: () => _handleGetStarted(),
                  child: Text(
                    "Skip",
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      isDark ? AppColors.grey[400]! : AppColors.grey[600]!,
                    ),
                  ),
                ),

                // Nút Next / Get Started (ĐÃ SỬA)
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _item.length - 1) {
                      // SỬA LẠI: Dùng _pageController thay vì _currentPage
                      // SỬA LẠI: microseconds quá nhanh, đổi thành milliseconds
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _handleGetStarted();
                    }
                  },
                  // SỬA LẠI: Thêm widget cho child (Text hoặc Icon)
                  child: Text(_currentPage == _item.length - 1 ? "Bắt đầu" : "Tiếp theo"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

}

void _handleGetStarted() {
  final AuthController authController = Get.find<AuthController>();
  authController.setFirstTimeDone();
  Get.off(()=> const SigninScreen());

}
class OnboardingItem{
  final String image;
  final String title;
  final String description;
  OnboardingItem({
    required this.image,
    required this.title,
    required this.description
});
}


