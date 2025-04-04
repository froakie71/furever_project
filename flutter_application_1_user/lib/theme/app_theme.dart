import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF32649B);
  static const Color secondaryBlue = Color(0xFF38B6FF);
  static const Color accentOrange = Color(0xFFF0A32F);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
