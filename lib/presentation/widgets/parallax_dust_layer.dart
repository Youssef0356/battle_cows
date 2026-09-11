import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ParallaxDustLayer extends StatefulWidget {
  const ParallaxDustLayer({super.key});

  @override
  State<ParallaxDustLayer> createState() => _ParallaxDustLayerState();
}

class _ParallaxDustLayerState extends State<ParallaxDustLayer>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late final AnimationController _controller;
  Animation<double> _drift = const AlwaysStoppedAnimation(0);
  double _currentPosition = 0;
  Timer? _nextDrift;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _startDrift();
  }

  void _startDrift() {
    if (!mounted) return;

    final nextPosition = (_random.nextDouble() * 2) - 1;
    final duration = Duration(milliseconds: 9000 + _random.nextInt(9000));
    _controller.duration = duration;
    _drift = Tween<double>(
      begin: _currentPosition,
      end: nextPosition,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      _currentPosition = nextPosition;
      _nextDrift = Timer(Duration(milliseconds: 700 + _random.nextInt(1800)), _startDrift);
    });
    setState(() {});
  }

  @override
  void dispose() {
    _nextDrift?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final position = _drift.value * width * 0.28;
          return Stack(
            children: [
              Positioned(
                top: MediaQuery.sizeOf(context).height * 0.22,
                left: width * 0.12 + position,
                child: Opacity(
                  opacity: 0.18,
                  child: Image.asset(
                    'assets/images/Effects/stampede_dust.png',
                    width: min(330, width * 0.58),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.sizeOf(context).height * 0.52,
                left: width * 0.55 + position * 0.55,
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset(
                    'assets/images/Effects/stampede_dust.png',
                    width: min(250, width * 0.44),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
