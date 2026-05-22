import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2C3E50); // Dark Blue for Professionalism
  static const Color secondary = Color(0xFF18BC9C); // Teal for Healthcare
  static const Color background = Color(0xFFF8F9FA); // Light Gray Background
  static const Color surface = Colors.white;
  
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  
  static const Color alert = Color(0xFFE74C3C); // Red for Alerts
  static const Color warning = Color(0xFFF39C12); // Yellow for Warning
  static const Color success = Color(0xFF2ECC71); // Green for Success
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
  );
}
