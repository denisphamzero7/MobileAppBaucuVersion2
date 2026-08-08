import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/weather_controller.dart';
import '../../untils/app_textstyles.dart';

class WeatherInfoCard extends StatelessWidget {
  final WeatherController controller = Get.find<WeatherController>();
  final Color primaryColor;

  WeatherInfoCard({super.key, required this.primaryColor});

  // Hàm ánh xạ Icon chuẩn xác (bao gồm Ban ngày/Ban đêm)
  IconData _mapWeatherIcon(String iconCode) {
    // 1. Trời quang (Clear)
    if (iconCode == '01d') return Icons.wb_sunny_rounded;      // Ngày: Mặt trời
    if (iconCode == '01n') return Icons.nightlight_round;      // Đêm: Mặt trăng

    // 2. Mây thưa (Few Clouds)
    if (iconCode == '02d') return Icons.wb_cloudy;             // Ngày có mây
    if (iconCode == '02n') return Icons.nightlight_round;      // Đêm có mây (hoặc dùng icon mây đêm nếu có)

    // 3. Nhiều mây (Scattered/Broken Clouds)
    if (iconCode.startsWith('03') || iconCode.startsWith('04')) return Icons.cloud;

    // 4. Mưa (Rain)
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) return Icons.water_drop;

    // 5. Giông bão (Thunderstorm)
    if (iconCode.startsWith('11')) return Icons.thunderstorm;

    // 6. Tuyết (Snow)
    if (iconCode.startsWith('13')) return Icons.ac_unit;

    // 7. Sương mù (Mist)
    if (iconCode.startsWith('50')) return Icons.foggy;

    return Icons.cloud_queue; // Mặc định
  }

  Widget _buildStatusCard(String message, {IconData icon = Icons.timer}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: AppTextStyle.bodyMedium.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildStatusCard('Đang định vị & cập nhật thời tiết...');
      }

      if (controller.errorMessage.isNotEmpty) {
        return _buildStatusCard(controller.errorMessage.value, icon: Icons.warning_amber_rounded);
      }

      final weather = controller.currentWeatherData.value;
      final location = controller.locationName.value; // Lấy tên từ Geocoding

      if (weather == null) {
        return _buildStatusCard('Không có dữ liệu', icon: Icons.cloud_off);
      }

      // --- HIỂN THỊ DỮ LIỆU THÀNH CÔNG ---
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng 1: Địa điểm & Ngày
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Dùng Expanded để tên dài không bị lỗi giao diện
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          location, // "Thành phố Đà Nẵng"
                          style: AppTextStyle.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    style: AppTextStyle.bodySmall.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Dòng 2: Nhiệt độ, Icon, Mô tả
            Row(
              children: [
                Icon(_mapWeatherIcon(weather.iconCode), color: Colors.white, size: 54),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${weather.temperature.round()}°C",
                      style: AppTextStyle.h1.copyWith(color: Colors.white, fontSize: 42, height: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.description.capitalizeFirst ?? "",
                      style: AppTextStyle.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9), fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}