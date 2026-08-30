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
  final VoidCallback? onTap;

  const HexCellWidget({
    super.key,
    required this.size,
    required this.cell,
    this.herd,
    this.isSelected = false,
    this.isValidMove = false,
    this.onTap,
  });

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

  _HexPainter({
    required this.cell,
    this.herd,
    this.isSelected = false,
    this.isValidMove = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final hexRadius = size.width / 2;

    final path = _createHexPath(center, hexRadius);

    _drawHexFill(canvas, path, hexRadius);
    _drawHexBorder(canvas, path);

    if (isSelected) {
      _drawSelectionGlow(canvas, path);
    }

    if (isValidMove) {
      _drawValidMoveOutline(canvas, path);
    }

    if (herd != null && herd!.size > 0) {
      _drawHerd(canvas, center, hexRadius);
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

  void _drawHexFill(Canvas canvas, Path path, double radius) {
    Paint paint;

    if (cell.isObstacle) {
      paint = Paint()..color = AppColors.obstacle;
    } else if (herd != null && herd!.size > 0) {
      paint = Paint()..color = AppColors.getPlayerPrimary(herd!.owner);
    } else {
      final grassShades = [AppColors.grassMid, AppColors.grassLight, AppColors.grassDark];
      paint = Paint()..color = grassShades[cell.position.q.abs() % 3];
    }

    canvas.drawPath(path, paint);
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
      ..color = AppColors.selectionGlow.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);
  }

  void _drawValidMoveOutline(Canvas canvas, Path path) {
    final movePaint = Paint()
      ..color = AppColors.validMoveOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(path, movePaint);
  }

  void _drawHerd(Canvas canvas, Offset center, double radius) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: radius * 0.6,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(
      text: '${herd!.size}',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
