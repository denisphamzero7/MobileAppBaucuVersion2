import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:developer';

import '../model/weather.dart';
import '../service/weather_service.dart';

class WeatherController extends GetxController {
  final WeatherService weatherApi = WeatherService();

  // Dữ liệu thời tiết (Nhiệt độ, Icon, Mô tả)
  final Rx<Weather?> currentWeatherData = Rx<Weather?>(null);

  // Tên địa điểm hiển thị trên UI (Đà Nẵng, Hà Nội...)
  final RxString locationName = 'Đang định vị...'.obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchWeather();
  }

  // --- HÀM CHÍNH: QUẢN LÝ LUỒNG DỮ LIỆU ---
  Future<void> fetchWeather() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // BƯỚC 1: Lấy tọa độ GPS chính xác nhất
      Position position = await _determinePosition();
      double lat = position.latitude;
      double lon = position.longitude;

      log("📍 Tọa độ GPS: Lat=$lat, Lon=$lon");

      // BƯỚC 2: Lấy tên Hành chính (Để hiển thị "TP. Đà Nẵng")
      // Chạy cái này độc lập, không phụ thuộc vào API thời tiết
      await _getCityNameFromGPS(lat, lon);

      // BƯỚC 3: Dùng dữ liệu thời tiết cứng như yêu cầu
      currentWeatherData.value = Weather(
        temperature: 29.5,
        description: 'Mây rải rác',
        iconCode: '02d',
        cityName: 'Thành phố Đà Nẵng',
      );
      
      log("✅ Tải thời tiết thành công (Dữ liệu cứng): 29.5°C");
    } on LocationServiceDisabledException {
      errorMessage.value = 'Vui lòng bật GPS để xem thời tiết.';
    } on PermissionDeniedException {
      errorMessage.value = 'Cần quyền truy cập vị trí.';
    } catch (e) {
      final errorMsg = e.toString().replaceAll("Exception: ", "");
      errorMessage.value = 'Lỗi: $errorMsg';
      log("❌ Lỗi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- HÀM PHỤ 1: LẤY TỌA ĐỘ ---
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw LocationServiceDisabledException();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw PermissionDeniedException('');
      }
    }

    // Sử dụng 'best' để lấy tọa độ chính xác nhất có thể
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  // --- HÀM PHỤ 2: LẤY TÊN ĐỊA ĐIỂM HÀNH CHÍNH ---
  Future<void> _getCityNameFromGPS(double lat, double lon) async {
    try {
      // localeIdentifier: 'vi' để lấy tên tiếng Việt
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon, localeIdentifier: 'vi');

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        log("📍 Geocoding Info: ${place.toJson()}");

        // Ưu tiên lấy 'administrativeArea' (Cấp Tỉnh/Thành phố trực thuộc TW)
        // Ví dụ: "Thành phố Đà Nẵng"
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          locationName.value = place.administrativeArea!;
        }
        // Nếu không có, lấy cấp Quận/Huyện
        else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          locationName.value = place.subAdministrativeArea!;
        }
        // Cuối cùng mới lấy tên địa phương nhỏ (Locality)
        else {
          locationName.value = place.locality ?? 'Vị trí không xác định';
        }
      }
    } catch (e) {
      log("❌ Lỗi Geocoding: $e");
      // Nếu lỗi Geocoding, giữ nguyên giá trị mặc định hoặc set tạm
      locationName.value = "Đang cập nhật...";
    }
  }
}