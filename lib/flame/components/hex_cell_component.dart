import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../game/models/hex_cell.dart';
import '../../game/models/herd.dart';
import '../../game/models/player_color.dart';
import '../../core/constants/colors.dart';

class HexCellComponent extends PositionComponent with TapCallbacks {
  final HexCell cell;
  Herd? herd;
  bool isSelected;
  bool isValidMove;
  double pulseValue;
  final int flipMode;
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
    final depthOffset = radius * 0.12;
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
        colors: [Color(0xFF4E7A25), Color(0xFF2D5016)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, center.y, size.x, depthOffset));

    canvas.drawPath(sidePath, sidePaint);

    final shadowPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.x + radius * cos(angle),
        center.y + radius * sin(angle) + depthOffset + 2,
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

  void _drawHexFill(Canvas canvas, Path path, Vector2 center, double radius) {
    canvas.save();
    canvas.clipPath(path);

    if (cell.isObstacle) {
      canvas.drawPath(path, Paint()..color = AppColors.obstacle);
    } else if (herd != null && herd!.size > 0) {
      canvas.drawPath(path, Paint()..color = AppColors.getPlayerPrimary(herd!.owner));
    } else {
      final grassShades = [AppColors.grassMid, AppColors.grassLight, AppColors.grassDark];
      canvas.drawPath(path, Paint()..color = grassShades[cell.position.q.abs() % 3]);
    }

    if (herd != null && herd!.size > 0) {
      final tint = AppColors.getPlayerPrimary(herd!.owner).withValues(alpha: 0.35);
      canvas.drawPath(path, Paint()..color = tint);
    }

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

  void _drawCoinStack(Canvas canvas, Vector2 center, double radius) {
    final herdSize = herd!.size;
    final playerColor = AppColors.getPlayerPrimary(herd!.owner);
    final playerDark = AppColors.getPlayerDark(herd!.owner);

    final coinRadius = radius * 0.38;
    final coinSpacing = radius * 0.22;
    final totalHeight = coinRadius + (herdSize - 1) * coinSpacing;
    final startY = center.y + totalHeight / 2 - coinRadius;

    for (int i = herdSize - 1; i >= 0; i--) {
      final coinCenter = Offset(
        center.x,
        startY - i * coinSpacing,
      );
      _drawSingleCoin(canvas, coinCenter, coinRadius, playerColor, playerDark);
    }
  }

  void _drawSingleCoin(Canvas canvas, Offset center, double radius, Color faceColor, Color edgeColor) {
    final edgeHeight = radius * 0.3;

    final edgePath = Path()
      ..addOval(Rect.fromCircle(center: Offset(center.dx, center.dy + edgeHeight), radius: radius))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(edgePath, Paint()..color = edgeColor);

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
