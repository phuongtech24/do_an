import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MindHealthTheme {
  static ThemeData light() {
    const primary = Color(0xFF0E7A73);
    const secondary = Color(0xFF63B7AF);
    const surface = Color(0xFFF5FBFA);
    const warning = Color(0xFFE7A95B);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: warning,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF5FBFA),
      textTheme: GoogleFonts.nunitoTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.nunitoSans(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.nunitoSans(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
            color: states.contains(WidgetState.selected) ? primary : const Color(0xFF6D8482),
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? primary : const Color(0xFF7A9795),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primary,
        secondarySelectedColor: primary,
        labelStyle: GoogleFonts.nunitoSans(
          color: const Color(0xFF163B3A),
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: GoogleFonts.nunitoSans(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: primary.withOpacity(0.12)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
