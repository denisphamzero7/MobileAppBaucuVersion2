import 'package:flutter/material.dart';

class AppThemes {
  // Light Theme
  static final light = ThemeData(
    primaryColor: const Color(0xFF007fff),
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(
          color: Colors.black
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF007fff),
      primary: const Color(0xFF007fff),
      brightness: Brightness.light,
      surface: Colors.white,
    ),
    cardColor: Colors.white,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF007fff),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

  );

  // Dark Theme
  static final dark = ThemeData(
    primaryColor: const Color(0xFF007fff),
    scaffoldBackgroundColor: Color(0xFF121212),
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(
          color: Colors.white
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF007fff),
      primary: const Color(0xFF007fff),
      brightness: Brightness.dark,
      surface: const Color(0xFF121212),
    ),
    cardColor: const Color(0xFF007fff),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF121212),
      selectedItemColor: Color(0xFF007fff),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

  );
}