import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A premium wood-carved style button matching the Battle Cows rustic aesthetic.
/// Features authentic wood grain, bevelled edges, carved text, and press animation.
class WoodButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final Color baseColor;
  final Color? borderColor;
  final double fontSize;
  final bool isSmall;

  const WoodButton({
    super.key,
    required this.label,
    this.icon,
    this.emoji,
    this.onPressed,
    this.width,
    this.height = 56,
    this.baseColor = const Color(0xFF6B4F12),
    this.borderColor,
    this.fontSize = 20,
    this.isSmall = false,
  });

  /// Gold/amber primary CTA button
  static WoodButton gold({
    required String label,
    IconData? icon,
    String? emoji,
    VoidCallback? onPressed,
    double? width,
    double height = 60,
    double fontSize = 26,
  }) =>
      WoodButton(
        label: label,
        icon: icon,
        emoji: emoji,
        onPressed: onPressed,
        width: width,
        height: height,
        fontSize: fontSize,
        baseColor: const Color(0xFFB8860B),
        borderColor: const Color(0xFFFFE082),
      );

  /// Green positive action button
  static WoodButton green({
    required String label,
    IconData? icon,
    String? emoji,
    VoidCallback? onPressed,
    double? width,
    double height = 52,
    double fontSize = 20,
  }) =>
      WoodButton(
        label: label,
        icon: icon,
        emoji: emoji,
        onPressed: onPressed,
        width: width,
        height: height,
        fontSize: fontSize,
        baseColor: const Color(0xFF2E7D32),
        borderColor: const Color(0xFF81C784),
      );

  /// Red danger/exit button
  static WoodButton red({
    required String label,
    IconData? icon,
    String? emoji,
    VoidCallback? onPressed,
    double? width,
    double height = 52,
    double fontSize = 20,
  }) =>
      WoodButton(
        label: label,
        icon: icon,
        emoji: emoji,
        onPressed: onPressed,
        width: width,
        height: height,
        fontSize: fontSize,
        baseColor: const Color(0xFF8B1010),
        borderColor: const Color(0xFFFFCDD2),
      );

  /// Purple secondary button
  static WoodButton purple({
    required String label,
    IconData? icon,
    String? emoji,
    VoidCallback? onPressed,
    double? width,
    double height = 52,
    double fontSize = 20,
  }) =>
      WoodButton(
        label: label,
        icon: icon,
        emoji: emoji,
        onPressed: onPressed,
        width: width,
        height: height,
        fontSize: fontSize,
        baseColor: const Color(0xFF6A1B9A),
        borderColor: const Color(0xFFCE93D8),
      );

  @override
  State<WoodButton> createState() => _WoodButtonState();
}

class _WoodButtonState extends State<WoodButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: isDisabled
          ? null
          : (_) {
              HapticFeedback.lightImpact();
              setState(() => _isPressed = true);
              _pressController.forward();
            },
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              _pressController.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: isDisabled
          ? null
          : () {
              setState(() => _isPressed = false);
              _pressController.reverse();
            },
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (context, child) => Transform.scale(
          scale: _pressAnim.value,
          child: child,
        ),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: _WoodPlankPainter(
              baseColor: isDisabled
                  ? const Color(0xFF4A4A4A)
                  : widget.baseColor,
              borderColor: isDisabled
                  ? const Color(0xFF666666)
                  : (widget.borderColor ?? _darker(widget.baseColor)),
              isPressed: _isPressed,
              seed: widget.label.hashCode,
              isDisabled: isDisabled,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.emoji != null) ...[
                      Text(
                        widget.emoji!,
                        style: TextStyle(
                          fontSize: widget.isSmall
                              ? widget.fontSize * 0.85
                              : widget.fontSize - 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: isDisabled
                            ? const Color(0xFFFFF3D6).withValues(alpha: 0.35)
                            : const Color(0xFFFFF3D6),
                        size: widget.isSmall ? widget.fontSize * 0.9 : widget.fontSize + 2,
                        shadows: isDisabled
                            ? null
                            : [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  offset: const Offset(1, 1.5),
                                  blurRadius: 2,
                                ),
                              ],
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label.toUpperCase(),
                      style: GoogleFonts.bangers(
                        fontSize: widget.isSmall
                            ? widget.fontSize * 0.8
                            : widget.fontSize,
                        color: isDisabled
                            ? const Color(0xFFFFF3D6).withValues(alpha: 0.35)
                            : const Color(0xFFFFF3D6),
                        letterSpacing: 1.5,
                        shadows: isDisabled
                            ? null
                            : [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  offset: const Offset(1.5, 2),
                                  blurRadius: 3,
                                ),
                              ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _darker(Color c) {
    return HSLColor.fromColor(c)
        .withLightness((HSLColor.fromColor(c).lightness - 0.15).clamp(0.0, 1.0))
        .toColor();
  }
}

class _WoodPlankPainter extends CustomPainter {
  final Color baseColor;
  final Color borderColor;
  final bool isPressed;
  final bool isDisabled;
  final int seed;

  _WoodPlankPainter({
    required this.baseColor,
    required this.borderColor,
    required this.isPressed,
    required this.seed,
    this.isDisabled = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final radius = size.height * 0.38;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    // Outer drop shadow
    if (!isPressed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 6, size.width, size.height),
          Radius.circular(radius),
        ),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    // Bottom edge (3D depth)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, isPressed ? 1 : 3, size.width, size.height),
        Radius.circular(radius),
      ),
      Paint()
        ..color = _darken(baseColor, 0.3).withValues(alpha: 0.8),
    );

    // Main wood grain fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          _lighten(baseColor, 0.18),
          _lighten(baseColor, 0.05),
          baseColor,
          _darken(baseColor, 0.08),
          _lighten(baseColor, 0.04),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(rrect, fillPaint);

    if (!isDisabled) {
      // Subtle wood grain lines
      canvas.save();
      canvas.clipRRect(rrect);
      final grainPaint = Paint()
        ..color = _darken(baseColor, 0.18).withValues(alpha: 0.18)
        ..strokeWidth = 0.9
        ..style = PaintingStyle.stroke;

      for (var i = 0; i < size.height; i += 2 + rng.nextInt(4)) {
        final grainPath = Path();
        grainPath.moveTo(0, i.toDouble());
        for (var x = 0.0; x < size.width; x += 2) {
          grainPath.lineTo(
            x,
            i + sin(x * 0.06 + i * 0.12 + seed * 0.001) * 1.5,
          );
        }
        canvas.drawPath(grainPath, grainPaint);
      }

      // Occasional knot
      if (rng.nextDouble() > 0.6) {
        final kx = size.width * (0.2 + rng.nextDouble() * 0.6);
        final ky = size.height * (0.25 + rng.nextDouble() * 0.5);
        for (var ring = 0; ring < 3; ring++) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(kx, ky),
              width: (5 + ring * 4).toDouble(),
              height: (3 + ring * 2.5),
            ),
            Paint()
              ..color = _darken(baseColor, 0.25 + ring * 0.05)
                  .withValues(alpha: 0.2 - ring * 0.05)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
        }
      }

      canvas.restore();
    }

    // Top edge highlight (bevel)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.35),
        Radius.circular(radius),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: isDisabled ? 0.06 : 0.22),
            Colors.white.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.35)),
    );

    // Border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor.withValues(alpha: isDisabled ? 0.3 : 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Inner bright ring
    if (!isDisabled) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
          Radius.circular(radius - 2),
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    // Press darkening
    if (isPressed) {
      canvas.drawRRect(
        rrect,
        Paint()..color = Colors.black.withValues(alpha: 0.18),
      );
    }
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant _WoodPlankPainter old) =>
      isPressed != old.isPressed ||
      isDisabled != old.isDisabled ||
      seed != old.seed;
}
