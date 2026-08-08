import '../core/api_constants.dart';
import '../helper/dio_helper.dart';
import '../model/base_response.dart';
import '../model/notification.dart';

class NotificationService {
  final DioHelper _http = DioHelper();

  Future<BaseResponse<List<NotificationModel>>?> getNotifications() async {
    try {
      final response = await _http.get(
        url: ApiConstants.notification,
      );
      print("in kết quả notifications: $response");
      if (response != null) {
        return BaseResponse.fromJson(
          response,
          (json) {
            final list = json as List? ?? [];
            return list.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
          }
        );
      }
      return null;
    } catch (e) {
      print("Error in repository getNotifications: $e");
      return null;
    }
  }
}
