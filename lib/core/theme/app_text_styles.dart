import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AppTextStyles {
  static TextStyle heading = GoogleFonts.bangers(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.lightText,
    letterSpacing: 2,
  );

  static TextStyle subheading = GoogleFonts.bangers(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.lightText,
    letterSpacing: 1.5,
  );

  static TextStyle body = GoogleFonts.bangers(
    fontSize: 16,
    color: AppColors.lightText,
    letterSpacing: 1,
  );

  static TextStyle button = GoogleFonts.bangers(
    fontSize: 18,
    color: AppColors.lightText,
    letterSpacing: 1.5,
  );

  static TextStyle score = GoogleFonts.bangers(
    fontSize: 24,
    color: AppColors.lightText,
    letterSpacing: 1,
  );

  static TextStyle timer = GoogleFonts.bangers(
    fontSize: 20,
    color: AppColors.lightText,
  );

  static TextStyle herdCount = GoogleFonts.bangers(
    fontSize: 14,
    color: Colors.white,
  );

  static TextStyle title = GoogleFonts.bangers(
    fontSize: 48,
    color: AppColors.lightText,
    letterSpacing: 4,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.8),
        offset: const Offset(3, 3),
        blurRadius: 6,
      ),
    ],
  );

  static TextStyle gameButton = GoogleFonts.bangers(
    fontSize: 20,
    color: AppColors.lightText,
    letterSpacing: 2,
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.5),
        offset: const Offset(2, 2),
        blurRadius: 3,
      ),
    ],
  );

  static TextStyle cardTitle = GoogleFonts.bangers(
    fontSize: 18,
    color: AppColors.darkText,
    letterSpacing: 1,
  );
}
