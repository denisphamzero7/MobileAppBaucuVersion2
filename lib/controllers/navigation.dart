import 'package:get/get.dart';
import 'task_controller.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;

    // Chỉ tự động tải nếu tab đó đang chưa có dữ liệu (tránh load lại 2 lần)
    if (Get.isRegistered<TaskController>()) {
      final taskCtrl = Get.find<TaskController>();
      if (index == 0 && taskCtrl.tasksList.isEmpty) {
        taskCtrl.refreshTasks();
      } else if (index == 1 && taskCtrl.sentTasksList.isEmpty) {
        taskCtrl.getTasksList('sent');
      } else if (index == 2 && taskCtrl.receivedTasksList.isEmpty) {
        taskCtrl.getTasksList('received');
      } else if (index == 5 && taskCtrl.stats.value.total == 0) {
        taskCtrl.fetchStats();
      }
    }
  }
}