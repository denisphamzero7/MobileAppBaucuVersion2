import 'package:get/get.dart';
import 'task_controller.dart';
import 'notification_controller.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;

    // Tự động tải lại dữ liệu khi nhấn vào tab tương ứng
    if (index == 3) {
      if (Get.isRegistered<TaskController>()) {
        Get.find<TaskController>().fetchTasks();
      }
    } else if (index == 2) {
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().fetchNotifications();
      }
    }
  }
}