// Trong file weather_service.dart

import '../core/api_constants.dart';
import '../helper/dio_helper.dart';
import '../model/base_response.dart';
import '../model/weather.dart';

class WeatherService {
  final DioHelper _http = DioHelper();

  Future<BaseResponse<Weather>?> getCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await _http.get(
          url: ApiConstants.weather,
          queryParameters: {
            'lat': lat,
            'lon': lon,
          }
      );

      // 🚀 KHẮC PHỤC: Truyền response.data (là Map<String, dynamic> JSON)
      if (response != null) {
        // Giả định response là đối tượng của Dio, có thuộc tính 'data'
        final responseData = response as Map<String, dynamic>; // Ép kiểu an toàn

        return BaseResponse.fromJson(
            responseData, // <-- Chỉ truyền nội dung JSON
                (json) => Weather.fromJson(json)
        );
      }
      return null;
    } catch (e) {
      // ... (Phần xử lý lỗi giữ nguyên)
      rethrow; // Ném lại lỗi để Controller xử lý
    }
  }
}