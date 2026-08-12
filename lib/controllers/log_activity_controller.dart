import 'package:get/get.dart';
import '../model/log_activity.dart';
import '../service/log_activity_service.dart';

class LogActivityController extends GetxController {
  final LogActivityService _service = LogActivityService();

  final RxList<LogActivity> logs = <LogActivity>[].obs;
  final RxMap<String, dynamic> timelineStats = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;

  // Active tab index: 0 = Tổng Quan, 1 = Thông Tin Cá Nhân, 2 = Cài Đặt Bảo Mật
  final RxInt activeTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLogs();
    fetchTimelineStats();
  }

  Future<void> fetchLogs() async {
    try {
      isLoading.value = true;
      final response = await _service.getLogs();
      if (response != null && response.data.isNotEmpty) {
        logs.assignAll(response.data);
      } else {
        _setMockLogs();
      }
    } catch (e) {
      print("Error in fetchLogs: $e");
      _setMockLogs();
    } finally {
      isLoading.value = false;
    }
  }

  void _setMockLogs() {
    logs.assignAll([
      LogActivity(
        id: 1,
        description: "Truy cập danh sách public",
        method: "GET",
        ipAddress: "113.185.109.151",
        createdAt: "10:33:26 08/08/2026",
      ),
      LogActivity(
        id: 2,
        description: "Xem chi tiết Công việc #14",
        method: "GET",
        ipAddress: "206.245.132.79",
        createdAt: "10:33:26 08/08/2026",
      ),
      LogActivity(
        id: 3,
        description: "Truy cập danh sách người dùng",
        method: "GET",
        ipAddress: "113.185.109.151",
        createdAt: "10:33:26 08/08/2026",
      ),
      LogActivity(
        id: 4,
        description: "Truy cập danh sách user",
        method: "GET",
        ipAddress: "113.185.109.151",
        createdAt: "10:33:25 08/08/2026",
      ),
      LogActivity(
        id: 5,
        description: "Xác thực: zalo-login",
        method: "GET",
        ipAddress: "113.185.109.151",
        createdAt: "10:33:24 08/08/2026",
      ),
    ]);
  }

  Future<void> fetchTimelineStats() async {
    try {
      final response = await _service.getTimelineStats();
      if (response != null && response['data'] != null) {
        timelineStats.assignAll(response['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error in fetchTimelineStats: $e");
    }
  }

  void changeTab(int index) {
    activeTabIndex.value = index;
  }
}
