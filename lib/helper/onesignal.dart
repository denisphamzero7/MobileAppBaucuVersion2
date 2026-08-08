import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:developer'; // Dùng để in log ra console

const oneSignalAppId = "f32a6fd2-084c-40bb-ae20-d542db85c7af";

Future<void> initOneSignal() async {
  // 1. Bật log để dễ dàng gỡ lỗi (chỉ nên dùng trong môi trường dev)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  // 2. Khởi tạo OneSignal với App ID của bạn
  OneSignal.initialize(oneSignalAppId);


  await OneSignal.Notifications.requestPermission(true);

  // 4. Lắng nghe sự kiện KHI USER CLICK VÀO THÔNG BÁO
  OneSignal.Notifications.addClickListener((event) {
    log("Notification clicked: ${event.notification.body}");

    // TODO: Xử lý logic khi người dùng click
    // Ví dụ: điều hướng đến một màn hình cụ thể
    // String? screen = event.notification.additionalData?['screen'];
    // if (screen != null) {
    //   navigatorKey.currentState.pushNamed(screen);
    // }
  });

  // 5. Lắng nghe sự kiện KHI NHẬN ĐƯỢC THÔNG BÁO (lúc app đang mở)
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    log("Notification received in foreground: ${event.notification.body}");

    // Mặc định, thông báo sẽ KHÔNG hiển thị khi app đang mở
    // Để cho phép hiển thị, gọi:
    event.notification.display();

    // Để KHÔNG hiển thị (ví dụ: bạn muốn tự làm 1 banner trong app):
    // event.complete(null);
  });

  // 6. (Tùy chọn) Lấy Player ID để gửi cho backend
  // Player ID là mã định danh duy nhất của OneSignal cho thiết bị này
  _getOneSignalPlayerId();
}

void _getOneSignalPlayerId() async {
  // Chờ cho đến khi user đồng ý nhận thông báo
  final state = OneSignal.User.pushSubscription.optedIn;
  if (state==true) {
    final String? playerId = OneSignal.User.pushSubscription.id;
    log("OneSignal Player ID: $playerId");

    // TODO: Gửi playerId này về máy chủ của bạn để lưu lại
    // await ApiService.updatePlayerId(playerId);
  }
}