import 'package:flutter/material.dart';

class AppColors {
  // Soothing color palette for mental health app
  static const Color primary = Color(0xFF81B29A); // Calm Green
  static const Color secondary = Color(0xFFE07A5F); // Warm Terracotta
  static const Color background = Color(0xFFF4F1DE); // Soft Cream
  static const Color surface = Colors.white;
  
  static const Color textPrimary = Color(0xFF3D405B); // Deep Navy
  static const Color textSecondary = Color(0xFF7A7D9C);
  
  static const Color alert = Color(0xFFE56B6F); // Soft Red for alerts
  static const Color success = Color(0xFF81B29A);
}

ThemeData buildAppTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.alert,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
  );
}
