import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../game/models/hex_position.dart';

class BoardBorderComponent extends PositionComponent {
  final List<HexPosition> hexPositions;
  final double hexSize;

  BoardBorderComponent({
    required this.hexPositions,
    required this.hexSize,
    super.position,
    super.size,
  });

  @override
  void render(Canvas canvas) {
    if (hexPositions.isEmpty || hexSize <= 0) return;

    final bounds = _computeBounds();
    const padding = 12.0;
    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        bounds.left - padding,
        bounds.top - padding,
        bounds.width + padding * 2,
        bounds.height + padding * 2,
      ),
      const Radius.circular(16),
    );

    _drawFrame(canvas, borderRect);
  }

  Rect _computeBounds() {
    var minX = double.infinity, maxX = double.negativeInfinity;
    var minY = double.infinity, maxY = double.negativeInfinity;

    for (final hex in hexPositions) {
      final px = hexSize * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
      final py = hexSize * (3.0 / 2 * hex.r);
      minX = min(minX, px - hexSize);
      maxX = max(maxX, px + hexSize);
      minY = min(minY, py - hexSize);
      maxY = max(maxY, py + hexSize);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  void _drawFrame(Canvas canvas, RRect borderRect) {
    // Outer wooden frame
    final outerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5D4037), Color(0xFF3E2723), Color(0xFF5D4037)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(borderRect.outerRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawRRect(borderRect, outerPaint);

    // Inner highlight line
    final innerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8D6E63), Color(0xFF6D4C41), Color(0xFF8D6E63)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(borderRect.outerRect.deflate(6))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(borderRect.outerRect.deflate(6), const Radius.circular(12)),
      innerPaint,
    );

    // Subtle golden glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawRRect(borderRect, glowPaint);
  }
}
