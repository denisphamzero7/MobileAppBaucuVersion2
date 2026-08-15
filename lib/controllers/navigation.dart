import 'package:get/get.dart';
import 'task_controller.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;

    // Tự động tải lại dữ liệu khi nhấn vào tab tương ứng
    if (Get.isRegistered<TaskController>()) {
      final taskCtrl = Get.find<TaskController>();
      if (index == 0) {
        taskCtrl.refreshTasks();
      } else if (index == 1) {
        taskCtrl.fetchTasks(type: 'sent');
      } else if (index == 2) {
        taskCtrl.fetchTasks(type: 'received');
      } else if (index == 4) {
        taskCtrl.fetchStats();
      }
    }
  }
}