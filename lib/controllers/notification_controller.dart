import 'package:get/get.dart';
import '../model/notification.dart';
import '../service/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final response = await _notificationService.getNotifications();
      if (response != null) {
        notifications.assignAll(response.data);
      }
    } catch (e) {
      print("Lỗi fetchNotifications: $e");
    } finally {
      isLoading.value = false;
    }
  }
}