import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../../game/models/hex_position.dart';
import '../../game/models/pasture_tile.dart';

class PlacementPreviewComponent extends PositionComponent {
  List<HexPosition> _previewHexes = [];
  bool _isValid = false;
  double hexSize;
  double _pulse = 0;

  PlacementPreviewComponent({
    super.position,
    this.hexSize = 30,
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
  void update(double dt) {
    super.update(dt);
    _pulse += dt;
  }

  @override
  void render(Canvas canvas) {
    if (_previewHexes.isEmpty) return;

    for (final pos in _previewHexes) {
      final px = hexSize * (sqrt(3) * pos.q + sqrt(3) / 2 * pos.r);
      final py = hexSize * (3.0 / 2 * pos.r);

      _drawHex(canvas, Offset(px, py), hexSize);
    }
  }

  void _drawHex(Canvas canvas, Offset center, double radius) {
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

    final glow = _isValid ? (sin(_pulse * 4) + 1) / 2 : 0.0;
    final fillColor = _isValid
        ? const Color(0xFF66BB6A).withValues(alpha: 0.32 + glow * 0.18)
        : const Color(0xFFEF5350).withValues(alpha: 0.35);

    canvas.drawPath(path, Paint()..color = fillColor);

    final borderColor = _isValid
        ? const Color(0xFF66BB6A)
        : const Color(0xFFEF5350);

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _isValid ? 2.5 + glow * 1.5 : 2.5,
    );
  }
}
