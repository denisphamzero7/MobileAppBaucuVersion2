import 'dart:io';
import 'package:app_baucu_version1/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// 1. Import các Controller
import 'package:app_baucu_version1/controllers/auth_controller.dart';
import 'package:app_baucu_version1/controllers/theme_controller.dart';
import 'package:app_baucu_version1/controllers/navigation.dart';

// 2. Import giao diện (Views)
import 'package:app_baucu_version1/view/splash_screen.dart';
import 'package:app_baucu_version1/view/auth/signin_screen.dart';
import 'package:app_baucu_version1/view/main_screen.dart';
import 'package:app_baucu_version1/untils/app_themes.dart';

// 3. IMPORT FILE ONESIGNAL CỦA BẠN
// (Lưu ý: Hãy sửa đường dẫn này cho đúng với nơi bạn đặt file onesignal.dart)
// Ví dụ nếu bạn để ở thư mục lib/helper/onesignal.dart thì import như sau:
// import 'package:app_baucu_version1/helper/onesignal.dart';

import 'package:app_baucu_version1/controllers/voter_controller.dart';
import 'package:app_baucu_version1/controllers/weather_controller.dart';
import 'package:app_baucu_version1/controllers/notification_controller.dart';
import 'package:app_baucu_version1/controllers/log_activity_controller.dart';
import 'package:app_baucu_version1/controllers/task_controller.dart';

import 'core/widgets/maintenance_screen.dart';
// Hoặc nếu để ngay ngoài lib thì: import 'onesignal.dart';

void main() async {

  // A. Cấu hình Proxy chuyển tiếp cho tên miền local để tương thích với điện thoại thật qua USB
  HttpOverrides.global = MyHttpOverrides();
  
  // B. Bắt buộc phải có dòng này để chạy các hàm async trước runApp
  WidgetsFlutterBinding.ensureInitialized();

  // B. Khởi tạo Storage (Lưu token, user info)
  await GetStorage.init();

  // C. Khởi tạo OneSignal (Gọi hàm từ file onesignal.dart của bạn)
  // Tạm ẩn OneSignal chưa dùng tới
  // await initOneSignal();

  // D. Inject (Tiêm) các Controller vào bộ nhớ
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(NavigationController());
  Get.put(VoterController());
  Get.put(UserController());
  Get.put(WeatherController());
  Get.put(NotificationController());
  Get.put(TaskController());
  Get.put(LogActivityController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Bầu cử thành phố Đà Nẵng',
      debugShowCheckedModeBanner: false, // Tắt chữ debug

      // Cấu hình Theme
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade, // Hiệu ứng chuyển trang

      // Màn hình đầu tiên
      home: SplashScreen(),
      // home: const MaintenanceScreen(
      //   title: 'Hệ thống đang nâng cấp',
      //   message: 'Chúng tôi đang tiến hành bảo trì cơ sở dữ liệu định kỳ.',
      //   expectedEndTime: '03:00 - 29/08/2026',
      //   supportContact: 'hotline@danatec.vn - 1900 6868',
      // ),


      // E. CẤU HÌNH ROUTES (QUAN TRỌNG)
      // AuthController dùng Get.toNamed('/home') nên phải khai báo ở đây
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => const SigninScreen()),
        GetPage(name: '/home', page: () => const MainScreen()),
      ],
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // Bỏ qua lỗi SSL Certificate nếu dùng IP nội bộ hoặc HTTPS tự ký
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    
    // ĐÃ XÓA TÍNH NĂNG ÉP PROXY (findProxy) 127.0.0.1:8080
    // Để khi bạn gọi URL https://danatec-test.theworkpc.com/... nó sẽ kết nối trực tiếp Internet thay vì tìm proxy ảo trong điện thoại
    return client;
  }
}