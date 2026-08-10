import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../../untils/app_colors.dart';


class AppThemes {
  // Light Theme
  static final light = ThemeData(
    primaryColor: AppColors.themePrimary,
    scaffoldBackgroundColor: AppColors.white,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      iconTheme: IconThemeData(
          color: AppColors.black
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.themePrimary,
      primary: AppColors.themePrimary,
      brightness: Brightness.light,
      surface: AppColors.white,
    ),
    cardColor: AppColors.white,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.themePrimary,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

  );

  // Dark Theme
  static final dark = ThemeData(
    primaryColor: AppColors.themePrimary,
    scaffoldBackgroundColor: AppColors.darkBg,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      iconTheme: IconThemeData(
          color: AppColors.white
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.themePrimary,
      primary: AppColors.themePrimary,
      brightness: Brightness.dark,
      surface: AppColors.darkBg,
    ),
    cardColor: AppColors.themePrimary,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBg,
      selectedItemColor: AppColors.themePrimary,
      unselectedItemColor: AppColors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

  );
}


