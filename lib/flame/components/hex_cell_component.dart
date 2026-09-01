import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../game/models/hex_cell.dart';
import '../../game/models/herd.dart';
import '../../core/constants/colors.dart';

class HexCellComponent extends PositionComponent with TapCallbacks {
  final HexCell cell;
  Herd? herd;
  bool isSelected;
  bool isValidMove;
  double pulseValue;
  final int flipMode;
  final ui.Image? texture;
  final void Function()? onTapCallback;

  HexCellComponent({
    required this.cell,
    this.herd,
    this.isSelected = false,
    this.isValidMove = false,
    this.pulseValue = 0.0,
    required super.position,
    required super.size,
    this.flipMode = 0,
    this.texture,
    this.onTapCallback,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {}

  @override
  void render(Canvas canvas) {
    final center = Vector2(size.x / 2, size.y / 2);
    final hexRadius = size.x / 2;

    final path = _createHexPath(center, hexRadius);

    _draw3DDepth(canvas, path, center, hexRadius);
    _drawHexFill(canvas, path, center, hexRadius);
    _drawHexBorder(canvas, path);

    if (cell.isObstacle) {
      _drawObstacleFenceOrRock(canvas, center, hexRadius);
    }

    if (isSelected) {
      _drawSelectionGlow(canvas, path);
    }

    if (isValidMove) {
      _drawValidMoveDashedOutline(canvas, center, hexRadius);
    }

    if (herd != null && herd!.size > 0) {
      _drawCowPieceWithShield(canvas, center, hexRadius);
    }
  }

  Path _createHexPath(Vector2 center, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.x + radius * cos(angle),
        center.y + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  void _draw3DDepth(Canvas canvas, Path path, Vector2 center, double radius) {
    final depthOffset = radius * 0.14;
    final sidePath = Path();

    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final topPoint = Offset(
        center.x + radius * cos(angle),
        center.y + radius * sin(angle),
      );

      if (i == 0) {
        sidePath.moveTo(topPoint.dx, topPoint.dy);
      } else {
        sidePath.lineTo(topPoint.dx, topPoint.dy);
      }
    }
    for (var i = 5; i >= 0; i--) {
      final angle = (pi / 3) * i - pi / 6;
      final bottomPoint = Offset(
        center.x + radius * cos(angle),
        center.y + radius * sin(angle) + depthOffset,
      );
      sidePath.lineTo(bottomPoint.dx, bottomPoint.dy);
    }
    sidePath.close();

    final sidePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5A3D1E), Color(0xFF321E0B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, center.y, size.x, depthOffset));

    canvas.drawPath(sidePath, sidePaint);

    final shadowPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.x + radius * cos(angle),
        center.y + radius * sin(angle) + depthOffset + 3,
      );
      if (i == 0) {
        shadowPath.moveTo(point.dx, point.dy);
      } else {
        shadowPath.lineTo(point.dx, point.dy);
      }
    }
    shadowPath.close();

    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _drawHexFill(Canvas canvas, Path path, Vector2 center, double radius) {
    canvas.save();
    canvas.clipPath(path);

    if (texture != null && !cell.isObstacle) {
      _drawTexture(canvas, center, radius);
    } else if (cell.isObstacle) {
      canvas.drawPath(path, Paint()..color = const Color(0xFF4E342E));
    } else {
      final grassShades = [
        const Color(0xFF689F38),
        const Color(0xFF7CB342),
        const Color(0xFF558B2F),
      ];
      canvas.drawPath(path, Paint()..color = grassShades[cell.position.q.abs() % 3]);
    }

    if (herd != null && herd!.size > 0) {
      final tint = AppColors.getPlayerPrimary(herd!.owner).withValues(alpha: 0.3);
      canvas.drawPath(path, Paint()..color = tint);
    }

    canvas.restore();
  }

  void _drawTexture(Canvas canvas, Vector2 center, double radius) {
    if (texture == null) return;

    final imgSize = radius * 2.0;
    final src = Rect.fromLTWH(0, 0, texture!.width.toDouble(), texture!.height.toDouble());
    final dst = Rect.fromLTWH(
      center.x - radius,
      center.y - radius,
      imgSize,
      imgSize,
    );

    canvas.save();
    if (flipMode == 1) {
      canvas.translate(center.x, center.y);
      canvas.scale(-1, 1);
      canvas.translate(-center.x, -center.y);
    } else if (flipMode == 2) {
      canvas.translate(center.x, center.y);
      canvas.scale(1, -1);
      canvas.translate(-center.x, -center.y);
    } else if (flipMode == 3) {
      canvas.translate(center.x, center.y);
      canvas.scale(-1, -1);
      canvas.translate(-center.x, -center.y);
    }

    canvas.drawImageRect(texture!, src, dst, Paint()..filterQuality = FilterQuality.medium);
    canvas.restore();
  }

  void _drawHexBorder(Canvas canvas, Path path) {
    final borderPaint = Paint()
      ..color = const Color(0xFF33691E).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  void _drawObstacleFenceOrRock(Canvas canvas, Vector2 center, double radius) {
    final isFence = (cell.position.q + cell.position.r) % 2 == 0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: isFence ? '🪵' : '🪨',
        style: TextStyle(fontSize: radius * 0.9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.x - textPainter.width / 2, center.y - textPainter.height / 2),
    );
  }

  void _drawSelectionGlow(Canvas canvas, Path path) {
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.6 + pulseValue * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 + pulseValue * 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);
  }

  void _drawValidMoveDashedOutline(Canvas canvas, Vector2 center, double radius) {
    final dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Draw dashed hex perimeter
    final innerRadius = radius * 0.9;
    for (var i = 0; i < 6; i++) {
      final a1 = (pi / 3) * i - pi / 6;
      final a2 = (pi / 3) * (i + 1) - pi / 6;
      final p1 = Offset(center.x + innerRadius * cos(a1), center.y + innerRadius * sin(a1));
      final p2 = Offset(center.x + innerRadius * cos(a2), center.y + innerRadius * sin(a2));

      final mid1 = Offset(p1.dx * 0.65 + p2.dx * 0.35, p1.dy * 0.65 + p2.dy * 0.35);
      final mid2 = Offset(p1.dx * 0.35 + p2.dx * 0.65, p1.dy * 0.35 + p2.dy * 0.65);

      canvas.drawLine(p1, mid1, dashPaint);
      canvas.drawLine(mid2, p2, dashPaint);
    }
  }

  void _drawCowPieceWithShield(Canvas canvas, Vector2 center, double radius) {
    final herdSize = herd!.size;
    final primaryColor = AppColors.getPlayerPrimary(herd!.owner);
    final darkColor = AppColors.getPlayerDark(herd!.owner);
    final pieceRadius = radius * 0.55;

    // 1. 3D Hexagonal / Octagonal Pedestal Base
    final pedestalPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i;
      final point = Offset(
        center.x + pieceRadius * cos(angle),
        center.y + pieceRadius * sin(angle),
      );
      if (i == 0) {
        pedestalPath.moveTo(point.dx, point.dy);
      } else {
        pedestalPath.lineTo(point.dx, point.dy);
      }
    }
    pedestalPath.close();

    // Pedestal Depth / Shadow
    final pedDepth = pieceRadius * 0.25;
    final pedSidePath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i;
      final point = Offset(center.x + pieceRadius * cos(angle), center.y + pieceRadius * sin(angle));
      if (i == 0) pedSidePath.moveTo(point.dx, point.dy);
      else pedSidePath.lineTo(point.dx, point.dy);
    }
    for (var i = 5; i >= 0; i--) {
      final angle = (pi / 3) * i;
      final point = Offset(center.x + pieceRadius * cos(angle), center.y + pieceRadius * sin(angle) + pedDepth);
      pedSidePath.lineTo(point.dx, point.dy);
    }
    pedSidePath.close();

    canvas.drawPath(pedSidePath, Paint()..color = darkColor);

    // Pedestal Face Gradient
    final faceGradient = RadialGradient(
      center: const Alignment(-0.2, -0.3),
      colors: [
        _lightenColor(primaryColor, 0.3),
        primaryColor,
        darkColor,
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    canvas.drawPath(
      pedestalPath,
      Paint()..shader = faceGradient.createShader(Rect.fromCircle(center: Offset(center.x, center.y), radius: pieceRadius)),
    );

    // White Pedestal Rim
    canvas.drawPath(
      pedestalPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 2. Cow Face Center Avatar
    final cowPainter = TextPainter(
      text: TextSpan(
        text: '🐮',
        style: TextStyle(fontSize: pieceRadius * 1.1),
      ),
      textDirection: TextDirection.ltr,
    );
    cowPainter.layout();
    cowPainter.paint(
      canvas,
      Offset(center.x - cowPainter.width / 2, center.y - cowPainter.height / 2 - 2),
    );

    // 3. Shield Badge with Stack Count (Bottom-Right / Center-Bottom)
    final shieldWidth = pieceRadius * 0.75;
    final shieldHeight = pieceRadius * 0.85;
    final shieldCenter = Offset(center.x + pieceRadius * 0.35, center.y + pieceRadius * 0.3);

    _drawShieldBadge(canvas, shieldCenter, shieldWidth, shieldHeight, herdSize, primaryColor);
  }

  void _drawShieldBadge(Canvas canvas, Offset center, double width, double height, int count, Color teamColor) {
    final hw = width / 2;
    final hh = height / 2;

    final shieldPath = Path()
      ..moveTo(center.dx - hw, center.dy - hh)
      ..lineTo(center.dx + hw, center.dy - hh)
      ..lineTo(center.dx + hw, center.dy)
      ..quadraticBezierTo(center.dx + hw, center.dy + hh, center.dx, center.dy + hh)
      ..quadraticBezierTo(center.dx - hw, center.dy + hh, center.dx - hw, center.dy)
      ..close();

    // Shield shadow & fill
    canvas.drawPath(
      shieldPath,
      Paint()..color = const Color(0xFF1B0000).withValues(alpha: 0.85),
    );

    // Shield border
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Count text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$count',
        style: TextStyle(
          fontSize: height * 0.65,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontFamily: 'Bangers',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2 - 1),
    );
  }

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTapCallback?.call();
  }

  static int getFlipMode(int q, int r) {
    return (q * 7 + r * 13 + q * r * 3).abs() % 4;
  }
}
