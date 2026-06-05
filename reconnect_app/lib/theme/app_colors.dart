import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0E7A73);
  static const Color secondary = Color(0xFF63B7AF);
  static const Color background = Color(0xFFF5FBFA);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF163B3A);
  static const Color textSecondary = Color(0xFF6D8482);

  static const Color alert = Color(0xFFD95D5D);
  static const Color warning = Color(0xFFE7A95B);
  static const Color success = Color(0xFF2D9D78);
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
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
  );
}
