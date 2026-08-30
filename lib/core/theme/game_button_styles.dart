import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class GameButtonStyles {
  static final primaryGradient = const LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final secondaryGradient = const LinearGradient(
    colors: [Color(0xFFA1887F), Color(0xFF5D4037)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final dangerGradient = const LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFB71C1C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final goldGradient = const LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFF57F17)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ButtonStyle primary(BuildContext context) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 3),
      ),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.5),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFF1B5E20);
          }
          return const Color(0xFF43A047);
        },
      ),
    );
  }

  static ButtonStyle secondary(BuildContext context) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.4),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFF4E342E);
          }
          return const Color(0xFF8D6E63);
        },
      ),
    );
  }

  static ButtonStyle danger(BuildContext context) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.4),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return const Color(0xFF7F0000);
          }
          return const Color(0xFFE53935);
        },
      ),
    );
  }

  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    double? width,
    double height = 56,
    bool isDisabled = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? const LinearGradient(colors: [Colors.grey, Colors.grey])
            : primaryGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.bangers(
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(2, 2),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget secondaryButton({
    required String text,
    required VoidCallback? onPressed,
    double? width,
    double height = 48,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: secondaryGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.bangers(
            fontSize: 16,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  static Widget dangerButton({
    required String text,
    required VoidCallback? onPressed,
    double? width,
    double height = 48,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: dangerGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.bangers(
            fontSize: 16,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  static Widget iconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 56,
    Color? color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color?.withValues(alpha: 0.8) ?? AppColors.secondaryAction,
            color ?? const Color(0xFF5D4037),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: size * 0.5),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
