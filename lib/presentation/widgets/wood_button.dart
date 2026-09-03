import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WoodButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Color baseColor;
  final Color? borderColor;
  final double fontSize;
  final bool isSmall;

  const WoodButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.width = 120,
    this.height = 52,
    this.baseColor = const Color(0xFF6B4F12),
    this.borderColor,
    this.fontSize = 16,
    this.isSmall = false,
  });

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
      duration: const Duration(milliseconds: 100),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _pressController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pressController.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _pressController.reverse();
      },
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnim.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isPressed ? 0.3 : 0.5),
                    offset: Offset(0, _isPressed ? 1 : 4),
                    blurRadius: _isPressed ? 2 : 6,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _WoodPlankPainter(
                  baseColor: widget.baseColor,
                  borderColor: widget.borderColor ?? _darker(widget.baseColor),
                  isPressed: _isPressed,
                  seed: widget.label.hashCode,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: const Color(0xFFFFF3D6),
                            size: widget.isSmall ? 16 : 20,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          widget.label.toUpperCase(),
                          style: GoogleFonts.bangers(
                            fontSize: widget.isSmall ? widget.fontSize * 0.8 : widget.fontSize,
                            color: const Color(0xFFFFF3D6),
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
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
          );
        },
      ),
    );
  }

  Color _darker(Color c) {
    return HSLColor.fromColor(c)
        .withLightness((HSLColor.fromColor(c).lightness - 0.15).clamp(0, 1))
        .toColor();
  }
}

class _WoodPlankPainter extends CustomPainter {
  final Color baseColor;
  final Color borderColor;
  final bool isPressed;
  final int seed;

  _WoodPlankPainter({
    required this.baseColor,
    required this.borderColor,
    required this.isPressed,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final path = _createIrregularPlank(size, rng);

    // Shadow layer
    final shadowPath = _createIrregularPlank(size, rng);
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Main fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          _lighten(baseColor, 0.12),
          baseColor,
          _darken(baseColor, 0.1),
          baseColor,
          _lighten(baseColor, 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, fillPaint);

    // Wood grain lines
    final grainPaint = Paint()
      ..color = _darken(baseColor, 0.2).withValues(alpha: 0.2)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.height; i += 3 + rng.nextInt(3)) {
      final grainPath = Path();
      grainPath.moveTo(0, i.toDouble());
      for (var x = 0.0; x < size.width; x += 2) {
        grainPath.lineTo(x, i + sin(x * 0.08 + i * 0.15 + seed) * 1.8);
      }
      canvas.drawPath(grainPath, grainPaint);
    }

    // Highlight streaks
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.2 + rng.nextDouble() * 0.6);
      final highlightPath = Path();
      highlightPath.moveTo(size.width * 0.1, y);
      highlightPath.quadraticBezierTo(
        size.width * 0.5,
        y - 2 + rng.nextDouble() * 4,
        size.width * 0.9,
        y + 1,
      );
      canvas.drawPath(highlightPath, highlightPaint);
    }

    // Dark knot
    if (rng.nextDouble() > 0.5) {
      final knotX = size.width * (0.2 + rng.nextDouble() * 0.6);
      final knotY = size.height * (0.3 + rng.nextDouble() * 0.4);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(knotX, knotY),
          width: 4 + rng.nextDouble() * 4,
          height: 3 + rng.nextDouble() * 3,
        ),
        Paint()..color = _darken(baseColor, 0.3).withValues(alpha: 0.3),
      );
    }

    // Border (irregular)
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(path, borderPaint);

    // Inner highlight edge (top-left light)
    final innerHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final innerPath = Path();
    innerPath.moveTo(4, 2);
    innerPath.lineTo(size.width - 4, 2);
    canvas.drawPath(innerPath, innerHighlight);

    // Pressed overlay
    if (isPressed) {
      canvas.drawPath(
        path,
        Paint()..color = Colors.black.withValues(alpha: 0.15),
      );
    }
  }

  Path _createIrregularPlank(Size size, Random rng) {
    final w = size.width;
    final h = size.height;
    final jitter = 2.0;

    return Path()
      ..moveTo(
        rng.nextDouble() * jitter,
        rng.nextDouble() * jitter,
      )
      ..lineTo(
        w - rng.nextDouble() * jitter,
        rng.nextDouble() * jitter,
      )
      ..lineTo(
        w - rng.nextDouble() * jitter,
        h - rng.nextDouble() * jitter,
      )
      ..lineTo(
        rng.nextDouble() * jitter,
        h - rng.nextDouble() * jitter,
      )
      ..close();
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0, 1)).toColor();
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0, 1)).toColor();
  }

  @override
  bool shouldRepaint(covariant _WoodPlankPainter old) =>
      isPressed != old.isPressed || seed != old.seed;
}
