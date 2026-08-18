import 'package:get/get.dart';
import '../model/notification.dart';
import '../service/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isManualRefreshing = false.obs;

  bool get shouldShowSkeleton => (isLoading.value && notifications.isEmpty) || isManualRefreshing.value;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool isManualPull = false}) async {
    try {
      if (isManualPull) {
        isManualRefreshing.value = true;
      }
      isLoading.value = true;
      final response = await _notificationService.getNotifications();
      if (response != null) {
        notifications.assignAll(response.data);
      }
    } catch (e) {
      print("Lỗi fetchNotifications: $e");
    } finally {
      isLoading.value = false;
      isManualRefreshing.value = false;
    }
  }
}