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
      ByteData data;
      try {
        data = await rootBundle.load('assets/images/Background/background.jpg');
      } catch (_) {
        data = await rootBundle.load('assets/images/Background/MainMenu_Background.jpg');
      }
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
      final imgW = _bgImage!.width.toDouble();
      final imgH = _bgImage!.height.toDouble();
      final scaleX = size.x / imgW;
      final scaleY = size.y / imgH;
      final scale = scaleX > scaleY ? scaleX : scaleY;
      final scaledW = imgW * scale;
      final scaledH = imgH * scale;
      final offsetX = (size.x - scaledW) / 2;
      final offsetY = (size.y - scaledH) / 2;

      final src = Rect.fromLTWH(0, 0, imgW, imgH);
      final dst = Rect.fromLTWH(offsetX, offsetY, scaledW, scaledH);
      canvas.drawImageRect(_bgImage!, src, dst, Paint()..filterQuality = FilterQuality.low);

      final fadePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), fadePaint);

      final fadePaintV = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.2),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.2),
            Colors.black.withValues(alpha: 0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), fadePaintV);
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
