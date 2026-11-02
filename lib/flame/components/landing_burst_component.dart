import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../assets/asset_paths.dart';
import 'hex_cell_component.dart';

/// VFX dust & grass burst that plays when a cow herd lands on a hex tile.
class LandingBurstComponent extends PositionComponent {
  static const double duration = 0.36;
  double _life = 0.0;
  ui.Image? _image;

  LandingBurstComponent({
    required Vector2 position,
    required double radius,
  }) : super(
          position: position,
          size: Vector2.all(radius * 2.4),
          anchor: Anchor.center,
          priority: 85,
        );

  @override
  Future<void> onLoad() async {
    const path = AssetPaths.landingDustBurst;
    if (HexCellComponent.imageCache.containsKey(path)) {
      _image = HexCellComponent.imageCache[path];
    } else {
      try {
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        _image = (await codec.getNextFrame()).image;
        HexCellComponent.imageCache[path] = _image!;
      } catch (_) {}
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    if (_life >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_image == null) return;
    final progress = (_life / duration).clamp(0.0, 1.0);
    // Juicy pop: starts at 0.5, expands with ease-out bounce, fades away
    final scale = 0.5 + 0.65 * Curves.easeOutBack.transform(progress);
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(scale, scale);

    final src = Rect.fromLTWH(0, 0, _image!.width.toDouble(), _image!.height.toDouble());
    final dst = Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y);

    canvas.drawImageRect(
      _image!,
      src,
      dst,
      Paint()
        ..filterQuality = FilterQuality.medium
        ..color = Colors.white.withValues(alpha: alpha),
    );
    canvas.restore();
  }
}
