import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.lightText,
    fontFamily: 'Fredoka',
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.lightText,
    fontFamily: 'Fredoka',
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.lightText,
    fontFamily: 'Nunito',
  );

  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.lightText,
    fontFamily: 'Nunito',
  );

  static const TextStyle score = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'Fredoka',
  );

  static const TextStyle timer = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: 'Fredoka',
  );

  static const TextStyle herdCount = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    fontFamily: 'Nunito',
  );
}
