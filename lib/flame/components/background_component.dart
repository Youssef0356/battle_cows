import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundComponent extends PositionComponent {
  ui.Image? _bgImage;
  bool _loaded = false;

  BackgroundComponent({
    required super.position,
    required super.size,
  });

  @override
  Future<void> onLoad() async {
    try {
      final data = await rootBundle.load('assets/images/Background/Background.jpg');
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _bgImage = frame.image;
      _loaded = true;
    } catch (_) {
      _loaded = false;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_loaded && _bgImage != null) {
      final src = Rect.fromLTWH(0, 0, _bgImage!.width.toDouble(), _bgImage!.height.toDouble());
      final dst = Rect.fromLTWH(0, 0, size.x, size.y);
      canvas.drawImageRect(_bgImage!, src, dst, Paint()..filterQuality = FilterQuality.low);

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.black.withValues(alpha: 0.3),
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..shader = const LinearGradient(
          colors: [Color(0xFF1B3A1B), Color(0xFF0D2B0D), Color(0xFF1B3A1B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
      );
    }
  }
}
