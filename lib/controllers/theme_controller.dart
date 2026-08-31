import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/enums/common_enums.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  ThemeMode get theme => _loadTheme() ? ThemeMode.dark : ThemeMode.light;
  AppThemeMode get appThemeMode => isDarkMode ? AppThemeMode.dark : AppThemeMode.light;
  bool get isDarkMode => _loadTheme();
  bool _loadTheme() => _box.read(_key) ?? false;
  void saveTheme(bool isDarkMode) => _box.write(_key, isDarkMode);

  void toggleTheme() {
    Future.delayed(const Duration(milliseconds: 50), () {
      Get.changeThemeMode(_loadTheme() ? ThemeMode.light : ThemeMode.dark);
      saveTheme(!_loadTheme());
      update();
    });
  }

  void setThemeMode(AppThemeMode mode) {
    final isDark = mode == AppThemeMode.dark;
    Get.changeThemeMode(mode.themeMode);
    saveTheme(isDark);
    update();
  }
}