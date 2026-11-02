import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;
import '../../game/models/hex_position.dart';
import '../../game/models/pasture_tile.dart';
import '../../game/board/board_generator.dart';

class PlacementPreviewComponent extends PositionComponent {
  List<HexPosition> _previewHexes = [];
  bool _isValid = false;
  double hexSize;
  final List<HexPosition> Function()? getPlacedHexes;

  PlacementPreviewComponent({
    super.position,
    this.hexSize = 30,
    this.getPlacedHexes,
  });

  void updatePreview({
    required PastureTile? tile,
    required HexPosition offset,
    required bool isValid,
  }) {
    _isValid = isValid;
    if (tile == null) {
      _previewHexes = [];
      return;
    }
    final translated = tile.translate(offset);
    _previewHexes = List.from(translated.hexes);
  }


  @override
  void render(Canvas canvas) {
    final placed = getPlacedHexes?.call() ?? const [];

    // 1. If no tiles placed yet, render prominent, inviting starting zone
    if (placed.isEmpty) {
      _drawCenterStartingGuide(canvas);
    } else {
      // 2. Render visible, friendly docking slots on outer boundary
      _drawDockingSlots(canvas, placed);
    }

    // 3. Render current dragged/positioned tile preview
    if (_previewHexes.isNotEmpty) {
      final previewRadius = hexSize * 0.98;
      for (final pos in _previewHexes) {
        final px = hexSize * (sqrt(3) * pos.q + sqrt(3) / 2 * pos.r);
        final py = hexSize * (3.0 / 2 * pos.r);
        _drawPreviewHex(canvas, Offset(px, py), previewRadius);
      }
    }
  }

  void _drawCenterStartingGuide(Canvas canvas) {
    final center = Offset.zero;
    final path = _createHexPath(center, hexSize * 0.98);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );

    _drawDashedHex(
      canvas,
      path,
      Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void _drawDockingSlots(Canvas canvas, List<HexPosition> placed) {
    final outer = BoardGenerator.getOuterHexes(placed);
    final previewSet = _previewHexes.toSet();

    for (final hex in outer) {
      // Don't draw docking slot underneath the preview tile
      if (previewSet.contains(hex)) continue;

      final px = hexSize * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
      final py = hexSize * (3.0 / 2 * hex.r);
      final center = Offset(px, py);
      final path = _createHexPath(center, hexSize * 0.95);

      _drawDashedHex(
        canvas,
        path,
        Paint()
          ..color = const Color(0xFF81C784).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  void _drawDashedHex(Canvas canvas, Path path, Paint paint) {
    const dashLength = 8.0;
    const dashGap = 5.0;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final length = draw ? dashLength : dashGap;
        if (draw) {
          final extract = metric.extractPath(distance, min(distance + length, metric.length));
          canvas.drawPath(extract, paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  void _drawPreviewHex(Canvas canvas, Offset center, double radius) {
    final path = _createHexPath(center, radius);

    // Subtle contact shadow
    final shadowPath = _createHexPath(Offset(center.dx, center.dy + 1.5), radius);
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Natural pasture preview fill
    final fillColor = _isValid
        ? const Color(0xFF66BB6A).withValues(alpha: 0.32)
        : const Color(0xFFEF5350).withValues(alpha: 0.32);

    canvas.drawPath(path, Paint()..color = fillColor);

    // Clean, crisp border accurately matching final placed hex cell border
    final borderColor = _isValid
        ? const Color(0xFF4CAF50)
        : const Color(0xFFE53935);

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
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
}
