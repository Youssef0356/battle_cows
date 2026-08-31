import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math';
import '../../game/models/hex_cell.dart';
import '../../game/models/herd.dart';
import '../../core/constants/colors.dart';

class HexCellWidget extends StatelessWidget {
  final double size;
  final HexCell cell;
  final Herd? herd;
  final bool isSelected;
  final bool isValidMove;
  final ui.Image? texture;
  final int flipMode;
  final double pulseValue;
  final VoidCallback? onTap;

  const HexCellWidget({
    super.key,
    required this.size,
    required this.cell,
    this.herd,
    this.isSelected = false,
    this.isValidMove = false,
    this.texture,
    this.flipMode = 0,
    this.pulseValue = 0.0,
    this.onTap,
  });

  static int getFlipMode(int q, int r) {
    return (q * 7 + r * 13 + q * r * 3).abs() % 4;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(size, size),
        painter: _HexPainter(
          cell: cell,
          herd: herd,
          isSelected: isSelected,
          isValidMove: isValidMove,
          texture: texture,
          flipMode: flipMode,
          pulseValue: pulseValue,
        ),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  final HexCell cell;
  final Herd? herd;
  final bool isSelected;
  final bool isValidMove;
  final ui.Image? texture;
  final int flipMode;
  final double pulseValue;

  _HexPainter({
    required this.cell,
    this.herd,
    this.isSelected = false,
    this.isValidMove = false,
    this.texture,
    this.flipMode = 0,
    this.pulseValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final hexRadius = size.width / 2;

    final path = _createHexPath(center, hexRadius);

    _draw3DDepth(canvas, path, center, hexRadius, size);
    _drawHexFill(canvas, path, center, hexRadius);
    _drawHexBorder(canvas, path);

    if (isSelected) {
      _drawSelectionGlow(canvas, path);
    }

    if (isValidMove) {
      _drawValidMoveOutline(canvas, path);
    }

    if (herd != null && herd!.size > 0) {
      _drawCoinStack(canvas, center, hexRadius);
    }
  }

  Path _createHexPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
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

  void _draw3DDepth(Canvas canvas, Path path, Offset center, double radius, Size size) {
    final depthOffset = radius * 0.12;
    final sidePath = Path();

    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final topPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
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
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle) + depthOffset,
      );
      sidePath.lineTo(bottomPoint.dx, bottomPoint.dy);
    }
    sidePath.close();

    final sidePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF4E7A25),
          const Color(0xFF2D5016),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, center.dy, size.width, depthOffset));

    canvas.drawPath(sidePath, sidePaint);

    final shadowPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle) + depthOffset + 2,
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
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _drawHexFill(Canvas canvas, Path path, Offset center, double radius) {
    canvas.save();
    canvas.clipPath(path);

    if (texture != null && !cell.isObstacle) {
      _drawTexture(canvas, path, center, radius);
    } else if (cell.isObstacle) {
      canvas.drawPath(path, Paint()..color = AppColors.obstacle);
    } else if (herd != null && herd!.size > 0) {
      canvas.drawPath(path, Paint()..color = AppColors.getPlayerPrimary(herd!.owner));
    } else {
      final grassShades = [AppColors.grassMid, AppColors.grassLight, AppColors.grassDark];
      canvas.drawPath(path, Paint()..color = grassShades[cell.position.q.abs() % 3]);
    }

    if (herd != null && herd!.size > 0 && texture != null) {
      final tint = AppColors.getPlayerPrimary(herd!.owner).withValues(alpha: 0.35);
      canvas.drawPath(path, Paint()..color = tint);
    }

    canvas.restore();
  }

  void _drawTexture(Canvas canvas, Path path, Offset center, double radius) {
    if (texture == null) return;

    final imgSize = radius * 2.0;
    final src = Rect.fromLTWH(0, 0, texture!.width.toDouble(), texture!.height.toDouble());
    final dst = Rect.fromLTWH(
      center.dx - radius,
      center.dy - radius,
      imgSize,
      imgSize,
    );

    canvas.save();

    canvas.translate(center.dx, center.dy);

    switch (flipMode) {
      case 1:
        canvas.scale(-1.0, 1.0);
        break;
      case 2:
        canvas.scale(1.0, -1.0);
        break;
      case 3:
        canvas.scale(-1.0, -1.0);
        break;
    }

    canvas.translate(-center.dx, -center.dy);

    canvas.drawImageRect(texture!, src, dst, Paint()..filterQuality = FilterQuality.low);

    canvas.restore();
  }

  void _drawHexBorder(Canvas canvas, Path path) {
    final borderPaint = Paint()
      ..color = AppColors.tileBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
  }

  void _drawSelectionGlow(Canvas canvas, Path path) {
    final glowPaint = Paint()
      ..color = AppColors.selectionGlow.withValues(alpha: 0.3 + pulseValue * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 + pulseValue * 3
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + pulseValue * 4);

    canvas.drawPath(path, glowPaint);

    final innerGlow = Paint()
      ..color = AppColors.selectionGlow.withValues(alpha: 0.15 + pulseValue * 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, innerGlow);
  }

  void _drawValidMoveOutline(Canvas canvas, Path path) {
    final movePaint = Paint()
      ..color = AppColors.validMoveOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(path, movePaint);
  }

  void _drawCoinStack(Canvas canvas, Offset center, double radius) {
    final herdSize = herd!.size;
    final playerColor = AppColors.getPlayerPrimary(herd!.owner);
    final playerDark = AppColors.getPlayerDark(herd!.owner);

    final coinRadius = radius * 0.38;
    final coinSpacing = radius * 0.22;
    final totalHeight = coinRadius + (herdSize - 1) * coinSpacing;
    final startY = center.dy + totalHeight / 2 - coinRadius;

    for (int i = herdSize - 1; i >= 0; i--) {
      final coinCenter = Offset(
        center.dx,
        startY - i * coinSpacing,
      );
      _drawSingleCoin(canvas, coinCenter, coinRadius, playerColor, playerDark, i);
    }
  }

  void _drawSingleCoin(Canvas canvas, Offset center, double radius, Color faceColor, Color edgeColor, int index) {
    final edgeHeight = radius * 0.3;

    final edgePath = Path()
      ..addOval(Rect.fromCircle(center: Offset(center.dx, center.dy + edgeHeight), radius: radius))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    final edgePaint = Paint()..color = edgeColor;
    canvas.drawPath(edgePath, edgePaint);

    final faceGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [
        _lightenColor(faceColor, 0.3),
        faceColor,
        _darkenColor(faceColor, 0.2),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    canvas.drawOval(
      Rect.fromCircle(center: center, radius: radius),
      Paint()..shader = faceGradient.createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawOval(
      Rect.fromCircle(center: center, radius: radius * 0.85),
      rimPaint,
    );

    final innerDark = Paint()
      ..color = _darkenColor(faceColor, 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawOval(
      Rect.fromCircle(center: center, radius: radius * 0.7),
      innerDark,
    );

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawOval(
      Rect.fromCircle(center: center, radius: radius * 0.9),
      highlightPaint,
    );

    if (herd!.size > 1) {
      final cowIcon = _getHerdIcon();
      final iconPainter = TextPainter(
        text: TextSpan(
          text: cowIcon,
          style: TextStyle(
            fontSize: radius * 0.9,
            color: _darkenColor(faceColor, 0.3),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(
          center.dx - iconPainter.width / 2,
          center.dy - iconPainter.height / 2,
        ),
      );
    }
  }

  String _getHerdIcon() {
    switch (herd!.owner) {
      case PlayerColor.blue:
        return '\u2740';
      case PlayerColor.red:
        return '\u2741';
      case PlayerColor.yellow:
        return '\u2742';
      case PlayerColor.purple:
        return '\u2743';
    }
  }

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightened.toColor();
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
