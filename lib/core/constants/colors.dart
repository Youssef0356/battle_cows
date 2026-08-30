import 'package:flutter/material.dart';

class AppColors {
  // Team Colors
  static const Color blue = Color(0xFF2E86DE);
  static const Color blueLight = Color(0xFF5DADE2);
  static const Color blueDark = Color(0xFF1B4F72);

  static const Color red = Color(0xFFE74C3C);
  static const Color redLight = Color(0xFFF1948A);
  static const Color redDark = Color(0xFF922B21);

  static const Color yellow = Color(0xFFF5B400);
  static const Color yellowLight = Color(0xFFFCD34D);
  static const Color yellowDark = Color(0xFF92600B);

  static const Color purple = Color(0xFF8E44AD);
  static const Color purpleLight = Color(0xFFC39BD3);
  static const Color purpleDark = Color(0xFF4A235A);

  // Board Colors
  static const Color grassMid = Color(0xFF7CB342);
  static const Color grassLight = Color(0xFF8BC34A);
  static const Color grassDark = Color(0xFF689F38);
  static const Color tileBorder = Color(0xFF5D4037);
  static const Color dirt = Color(0xFFA1887F);
  static const Color obstacle = Color(0xFF6D4C41);

  // UI Colors
  static const Color cardBackground = Color(0xFFFFF8E1);
  static const Color primaryAction = Color(0xFF43A047);
  static const Color secondaryAction = Color(0xFF8D6E63);
  static const Color darkText = Color(0xFF3E2723);
  static const Color lightText = Color(0xFFFFFFFF);

  // Selection/Accent Colors
  static const Color selectionGlow = Color(0xFFFFFFFF);
  static const Color selectionPulse = Color(0xFFFFECB3);
  static const Color validMoveOutline = Color(0xB3FFFFFF);

  // Timer Colors
  static const Color timerGreen = Color(0xFF43A047);
  static const Color timerAmber = Color(0xFFFBC02D);
  static const Color timerRed = Color(0xFFE53935);

  // Player Color Getters
  static Color getPlayerPrimary(PlayerColor color) {
    switch (color) {
      case PlayerColor.blue:
        return blue;
      case PlayerColor.red:
        return red;
      case PlayerColor.yellow:
        return yellow;
      case PlayerColor.purple:
        return purple;
    }
  }

  static Color getPlayerLight(PlayerColor color) {
    switch (color) {
      case PlayerColor.blue:
        return blueLight;
      case PlayerColor.red:
        return redLight;
      case PlayerColor.yellow:
        return yellowLight;
      case PlayerColor.purple:
        return purpleLight;
    }
  }

  static Color getPlayerDark(PlayerColor color) {
    switch (color) {
      case PlayerColor.blue:
        return blueDark;
      case PlayerColor.red:
        return redDark;
      case PlayerColor.yellow:
        return yellowDark;
      case PlayerColor.purple:
        return purpleDark;
    }
  }
}

enum PlayerColor { blue, red, yellow, purple }
