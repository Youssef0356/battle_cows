import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryAction,
      scaffoldBackgroundColor: AppColors.grassDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryAction,
        secondary: AppColors.secondaryAction,
        surface: AppColors.cardBackground,
        onPrimary: AppColors.lightText,
        onSecondary: AppColors.lightText,
        onSurface: AppColors.darkText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        titleTextStyle: GoogleFonts.bangers(
          fontSize: 24,
          color: AppColors.lightText,
          letterSpacing: 2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAction,
          foregroundColor: AppColors.lightText,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.bangers(
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      textTheme: GoogleFonts.bangersTextTheme().copyWith(
        headlineLarge: GoogleFonts.bangers(
          fontSize: 32,
          color: AppColors.lightText,
          letterSpacing: 2,
        ),
        headlineMedium: GoogleFonts.bangers(
          fontSize: 24,
          color: AppColors.lightText,
          letterSpacing: 1.5,
        ),
        titleLarge: GoogleFonts.bangers(
          fontSize: 20,
          color: AppColors.lightText,
          letterSpacing: 1,
        ),
        bodyLarge: GoogleFonts.bangers(
          fontSize: 16,
          color: AppColors.lightText,
          letterSpacing: 1,
        ),
        bodyMedium: GoogleFonts.bangers(
          fontSize: 14,
          color: AppColors.lightText,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
