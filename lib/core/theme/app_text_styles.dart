import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../localization/app_fonts.dart';

class AppTextStyles {
  static TextStyle get heading => AppFonts.bangers(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.lightText,
    letterSpacing: 2,
  );

  static TextStyle get subheading => AppFonts.bangers(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.lightText,
    letterSpacing: 1.5,
  );

  static TextStyle get body => AppFonts.bangers(
    fontSize: 16,
    color: AppColors.lightText,
    letterSpacing: 1,
  );

  static TextStyle get button => AppFonts.bangers(
    fontSize: 18,
    color: AppColors.lightText,
    letterSpacing: 1.5,
  );

  static TextStyle get score => AppFonts.bangers(
    fontSize: 24,
    color: AppColors.lightText,
    letterSpacing: 1,
  );

  static TextStyle get timer => AppFonts.bangers(
    fontSize: 20,
    color: AppColors.lightText,
  );

  static TextStyle get herdCount => AppFonts.bangers(
    fontSize: 14,
    color: Colors.white,
  );

  static TextStyle get title => AppFonts.bangers(
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

  static TextStyle get gameButton => AppFonts.bangers(
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

  static TextStyle get cardTitle => AppFonts.bangers(
    fontSize: 18,
    color: AppColors.darkText,
    letterSpacing: 1,
  );
}
